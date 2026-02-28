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

    --- Run a yadm command asynchronously via vim.system
    ---@param args string
    ---@param on_done fun(ok: boolean, stdout: string, stderr: string)
    local function run(args, on_done)
      local cmd = yadm_cmd .. " " .. args
      vim.notify(string.format("[%s][DEBUG] running: %s", prefix, cmd))
      vim.system({ "bash", "-c", cmd }, { text = true, cwd = home }, function(result)
        vim.schedule(function()
          vim.notify(
            string.format(
              "[%s][DEBUG] done: code=%s stdout=%s stderr=%s",
              prefix,
              result.code,
              result.stdout,
              result.stderr
            )
          )
          on_done(result.code == 0, result.stdout or "", vim.trim(result.stderr or ""))
        end)
      end)
    end

    local function do_push()
      vim.notify(string.format("[%s] pushing...", prefix))
      run("push", function(ok, _, stderr)
        if not ok then
          vim.notify(string.format("[%s] push failed:\n%s", prefix, stderr), vim.log.levels.ERROR)
        else
          vim.notify(string.format("[%s] sync done", prefix), vim.log.levels.INFO)
        end
      end)
    end

    local function do_pull_and_push()
      vim.notify(string.format("[%s] pulling...", prefix))
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
        vim.notify(string.format("[%s] committed: %s", prefix, msg))
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
        vim.notify(string.format("[%s] no local changes", prefix))
        do_pull_and_push()
        return
      end

      -- Step 2: add changed files (not -A, which scans entire $HOME)
      -- Parse status output to extract file paths
      -- status --porcelain format: "XY filename" (XY = 2 char status, then space, then path)
      local files = {}
      for line in stdout:gmatch("[^\n]+") do
        local file = line:sub(4)
        if file ~= "" then
          -- Handle renames: "old -> new"
          local renamed = file:match("-> (.+)$")
          if renamed then
            file = renamed
          end
          table.insert(files, file)
        end
      end

      local add_args = "add"
      for _, f in ipairs(files) do
        add_args = add_args .. " '" .. f:gsub("'", "'\\''") .. "'"
      end

      run(add_args, function(ok2, _, stderr2)
        if not ok2 then
          vim.notify(string.format("[%s] add failed:\n%s", prefix, stderr2), vim.log.levels.ERROR)
          return
        end

        if type == "private" then
          do_commit("update at " .. os.date("%Y-%m-%d %H:%M:%S"))
        else
          vim.ui.input({ prompt = string.format("[%s] Commit message: ", prefix) }, function(input)
            if not input or input == "" then
              vim.notify(string.format("[%s] sync cancelled", prefix), vim.log.levels.WARN)
              return
            end
            do_commit(input)
          end)
        end
      end)
    end)
  end
end

return M
