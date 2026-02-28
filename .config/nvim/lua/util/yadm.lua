local M = {}

local function git_dir(type)
  return vim.fn.expand("$HOME/.local/share/yadm-" .. type .. "/repo.git")
end

local function yadm_data(type)
  return vim.fn.expand("$HOME/.local/share/yadm-" .. type)
end

local function yadm_dir(type)
  return vim.fn.expand("$HOME/.config/yadm-" .. type)
end

local function work_tree()
  return vim.fn.expand("$HOME")
end

function M.open_lazygit(type)
  return function()
    local lazygit_config_file = vim.fn.expand("$HOME/.config/yadm/lazygit.yml")
    Snacks.terminal(
      { "lazygit", "--use-config-file", lazygit_config_file, "--work-tree", work_tree(), "--git-dir", git_dir(type) },
      { win = { width = 0, height = 0 } }
    )
  end
end

local current_git_work_tree = nil
local current_git_dir = nil

function M.set_git_env(type)
  current_git_work_tree = vim.env.GIT_WORK_TREE
  current_git_dir = vim.env.GIT_DIR
  vim.env.GIT_WORK_TREE = work_tree()
  vim.env.GIT_DIR = git_dir(type)
end

function M.remove_git_env()
  vim.env.GIT_WORK_TREE = current_git_work_tree
  vim.env.GIT_DIR = current_git_dir
end

function M.add_current_file(type)
  return function()
    local filepath = vim.fn.expand("%:p")
    if filepath == "" then
      vim.notify("No file in current buffer", vim.log.levels.WARN)
      return
    end
    local output =
      vim.fn.system({ "yadm", "--yadm-dir", yadm_dir(type), "--yadm-data", yadm_data(type), "add", filepath })
    if vim.v.shell_error == 0 then
      vim.notify(string.format("Yadm added (%s): %s", type, filepath), vim.log.levels.INFO)
    else
      vim.notify(string.format("Yadm add failed (%s): %s\n%s", type, filepath, vim.trim(output)), vim.log.levels.ERROR)
    end
  end
end

local function yadm_prefix(type)
  return string.format("yadm --yadm-dir %s --yadm-data %s", yadm_dir(type), yadm_data(type))
end

function M.sync(type)
  return function()
    local prefix = type == "private" and "yadm-private" or "yadm-public"
    local yadm_cmd = yadm_prefix(type)
    local home = work_tree()
    vim.notify(string.format("[%s] syncing...", prefix))

    ---@param args string
    ---@param on_done fun(ok: boolean, stdout: string, stderr: string)
    local function run(args, on_done)
      vim.system({ "bash", "-c", yadm_cmd .. " " .. args }, { text = true, cwd = home }, function(result)
        vim.schedule(function()
          on_done(result.code == 0, result.stdout or "", vim.trim(result.stderr or ""))
        end)
      end)
    end

    local function do_push()
      run("push", function(ok, _, stderr)
        if not ok then
          vim.notify(string.format("[%s] push failed:\n%s", prefix, stderr), vim.log.levels.ERROR)
        else
          vim.notify(string.format("[%s] sync done", prefix), vim.log.levels.INFO)
        end
      end)
    end

    local function do_pull_and_push()
      run("pull --rebase", function(ok, _, stderr)
        if not ok then
          vim.notify(string.format("[%s] pull failed:\n%s", prefix, stderr), vim.log.levels.ERROR)
          return
        end
        do_push()
      end)
    end

    local function do_commit(msg)
      local escaped = msg:gsub('"', '\\"')
      run(string.format('commit -m "%s"', escaped), function(ok, _, stderr)
        if not ok then
          vim.notify(string.format("[%s] commit failed:\n%s", prefix, stderr), vim.log.levels.ERROR)
          return
        end
        do_pull_and_push()
      end)
    end

    -- Step 1: check status
    run("status --porcelain", function(ok, stdout)
      if not ok then
        vim.notify(string.format("[%s] status check failed", prefix), vim.log.levels.ERROR)
        return
      end

      local has_changes = vim.trim(stdout) ~= ""

      if not has_changes then
        do_pull_and_push()
        return
      end

      run("add -u", function(ok2, _, stderr2)
        if not ok2 then
          vim.notify(string.format("[%s] add failed:\n%s", prefix, stderr2), vim.log.levels.ERROR)
          return
        end

        if type == "private" then
          do_commit("update at " .. os.date("%Y-%m-%d %H:%M:%S"))
        else
          -- 获取 diff stat 后打开 commit 编辑窗口
          run("diff --cached --stat", function(_, diff_stat)
            local lines = { "" }
            table.insert(lines, "")
            table.insert(lines, "# 请为你的变更输入提交说明。以 '#' 开始的行将被忽略。")
            table.insert(lines, "#")
            if vim.trim(diff_stat) ~= "" then
              table.insert(lines, "# 变更：")
              for stat_line in diff_stat:gmatch("[^\n]+") do
                table.insert(lines, "#   " .. stat_line)
              end
            end

            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.bo[buf].buftype = "acwrite"
            vim.bo[buf].filetype = "gitcommit"
            vim.api.nvim_buf_set_name(buf, "yadm-public-commit-msg")

            vim.cmd("topleft split")
            local win = vim.api.nvim_get_current_win()
            vim.api.nvim_win_set_buf(win, buf)
            vim.api.nvim_win_set_height(win, #lines)
            vim.api.nvim_win_set_cursor(win, { 1, 0 })
            vim.cmd("startinsert")

            local committed = false
            vim.api.nvim_create_autocmd("BufWriteCmd", {
              buffer = buf,
              callback = function()
                if committed then
                  return
                end
                local buf_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
                local msg_lines = {}
                for _, l in ipairs(buf_lines) do
                  if not l:match("^#") then
                    table.insert(msg_lines, l)
                  end
                end
                -- 去掉首尾空行
                while #msg_lines > 0 and vim.trim(msg_lines[1]) == "" do
                  table.remove(msg_lines, 1)
                end
                while #msg_lines > 0 and vim.trim(msg_lines[#msg_lines]) == "" do
                  table.remove(msg_lines)
                end
                local msg = table.concat(msg_lines, "\n")
                if msg == "" then
                  vim.notify(string.format("[%s] commit message 为空，取消提交", prefix), vim.log.levels.WARN)
                  return
                end
                committed = true
                vim.bo[buf].modified = false
                if vim.api.nvim_win_is_valid(win) then
                  vim.api.nvim_win_close(win, true)
                end
                do_commit(msg)
              end,
            })

            vim.api.nvim_create_autocmd("BufWipeout", {
              buffer = buf,
              callback = function()
                if not committed then
                  vim.notify(string.format("[%s] sync cancelled", prefix), vim.log.levels.WARN)
                end
              end,
            })
          end)
        end
      end)
    end)
  end
end

return M
