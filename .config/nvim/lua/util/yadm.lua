-- Yadm dotfiles 管理：支持 public/private 双仓库。
-- type 参数为 "public" 或 "private"，对应不同的 GIT_DIR 和 YADM_DATA。
-- 核心功能：lazygit 集成、文件暂存、异步同步（add → commit → pull → push）。
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

function M.set_git_env(type)
  vim.env.GIT_WORK_TREE = work_tree()
  vim.env.GIT_DIR = git_dir(type)
end

function M.remove_git_env()
  vim.env.GIT_WORK_TREE = nil
  vim.env.GIT_DIR = nil
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
                do_commit(msg)
              end,
            })

            vim.api.nvim_create_autocmd("BufUnload", {
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

--- 用 codediff.nvim 打开 yadm diff（explorer 模式）。
--- 核心难点：codediff 的 get_status 硬编码 `-uall`，在 $HOME 下会扫描所有
--- 未跟踪文件（>= 数千个）导致超时。此函数自行运行 `git status --porcelain -M`
--- （不带 `-uall`），然后复用 codediff 内部 status 解析逻辑手动构造 session。
--- 需要临时设置 GIT_DIR/GIT_WORK_TREE 供 codediff 内部 git 调用使用，
--- diff 加载完成后自动清除。
function M.open_codediff(type)
  return function()
    -- 确保 codediff 已初始化（lazy 插件可能未加载）
    local ok_cd, _ = pcall(require, "codediff")
    if not ok_cd then
      vim.notify("codediff.nvim not loaded", vim.log.levels.ERROR)
      return
    end

    local gd = git_dir(type)
    local wt = work_tree()

    -- 异步获取 status（不带 -uall 避免在 $HOME 下扫描未跟踪文件）
    vim.system({ "git", "--git-dir=" .. gd, "--work-tree=" .. wt, "status", "--porcelain", "-M" }, {
      text = true,
    }, function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          vim.notify("yadm status failed: " .. (result.stderr or ""), vim.log.levels.ERROR)
          return
        end

        -- 解析 porcelain output
        local status_result = { unstaged = {}, staged = {}, conflicts = {} }
        for line in (result.stdout or ""):gmatch("[^\r\n]+") do
          if #line >= 3 then
            local index_status = line:sub(1, 1)
            local worktree_status = line:sub(2, 2)
            local path_part = line:sub(4)
            -- 去除 git 引号
            if path_part:match('^"') then
              path_part = path_part:gsub('^"', ""):gsub('"$', "")
              path_part = path_part:gsub("\\(.)", function(c)
                local map = { n = "\n", t = "\t", ["\\"] = "\\", ['"'] = '"' }
                return map[c] or c
              end)
            end
            -- 处理重命名
            local old_path, new_path = path_part:match("^(.+) %-> (.+)$")
            local path = new_path or path_part
            -- staged 变更
            if index_status ~= " " and index_status ~= "?" then
              table.insert(status_result.staged, {
                path = path,
                status = index_status,
                old_path = old_path,
              })
            end
            -- unstaged 变更
            if worktree_status ~= " " and worktree_status ~= "?" then
              table.insert(status_result.unstaged, {
                path = path,
                status = worktree_status,
                old_path = old_path,
              })
            end
          end
        end

        if #status_result.unstaged == 0 and #status_result.staged == 0 then
          vim.notify("No changes to show", vim.log.levels.INFO)
          return
        end

        -- 设置环境变量供 codediff 内部 git 调用使用
        M.set_git_env(type)

        local current_file = vim.api.nvim_buf_get_name(0)
        local focus_file = nil
        if current_file ~= "" then
          local abs = vim.fn.fnamemodify(current_file, ":p"):gsub("\\", "/")
          local prefix = wt:gsub("\\", "/")
          if not prefix:match("/$") then
            prefix = prefix .. "/"
          end
          if abs:sub(1, #prefix) == prefix then
            focus_file = abs:sub(#prefix + 1)
          end
        end

        ---@type SessionConfig
        local session_config = {
          mode = "explorer",
          git_root = wt,
          original_path = "",
          modified_path = "",
          original_revision = nil,
          modified_revision = nil,
          explorer_data = {
            status_result = status_result,
            focus_file = focus_file,
          },
        }

        local view = require("codediff.ui.view")
        local lifecycle = require("codediff.ui.lifecycle")
        view.create(session_config, "")

        -- 禁用 auto-refresh：codediff 的 refresh 会调 get_status(-uall)，
        -- 在 $HOME 下会扫描数百万文件。通过清理 auto-refresh 解决。
        vim.defer_fn(function()
          local tp = vim.api.nvim_get_current_tabpage()
          local explorer_obj = lifecycle.get_explorer(tp)
          if explorer_obj and explorer_obj._cleanup_auto_refresh then
            explorer_obj._cleanup_auto_refresh()
          end
        end, 50)

        -- tab 关闭时清除环境变量，避免影响其他 git 操作。
        local codediff_tabpage = nil
        vim.defer_fn(function()
          codediff_tabpage = vim.api.nvim_get_current_tabpage()
          vim.api.nvim_create_autocmd("TabClosed", {
            once = true,
            callback = function()
              vim.defer_fn(function()
                if codediff_tabpage and not lifecycle.get_session(codediff_tabpage) then
                  M.remove_git_env()
                end
              end, 100)
            end,
          })
        end, 100)
      end)
    end)
  end
end

return M
