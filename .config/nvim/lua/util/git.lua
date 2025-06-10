---@diagnostic disable: undefined-global

local M = {}

local job = require("util.job")

local refresh_git_status = function()
  local events = package.loaded["neo-tree.events"]
  if events then
    events.fire_event(events.GIT_EVENT)
  end
end

function M.toggle_git_diff()
  local gs = package.loaded.gitsigns
  gs.toggle_deleted()
  gs.toggle_numhl()
  gs.toggle_linehl()
  gs.toggle_word_diff()
end

local commit_script = [[
  set -e
	git add -A
	msg="update at $(date '+%Y-%m-%d %H:%M:%S')"
	git commit -m "$msg"
]]

local push_script = [[
  set -e
  git pull --rebase 1>/dev/null
	git push
]]

-- git commit and push
function M.git_commit_and_push()
  local cwd = LazyVim.root.git()
  vim.notify("git commit and push at " .. cwd)
  job.run_script(commit_script, {
    cwd = cwd,
    on_exit = function()
      refresh_git_status()
      job.run_script(push_script, { cwd = cwd })
    end,
  })
end

-- git push only
function M.git_push()
  local script = [[
  set -e
	git push
]]
  local cwd = LazyVim.root.git()
  vim.notify("git push at " .. cwd)
  job.run_script(script, {
    cwd = LazyVim.root.git(),
  })
end

function M.git_add_all()
  local cwd = LazyVim.root.git()
  job.run_script("git add .", {
    cwd = cwd,
    on_exit = function()
      refresh_git_status()
    end,
  })
end

function M.git_commit_amend()
  local cwd = LazyVim.root.git()
  job.run_script("git add . && git commit --amend --no-edit", {
    cwd = cwd,
    on_exit = function()
      refresh_git_status()
    end,
  })
end

-- tig
function M.open_tig_root_dir()
  LazyVim.terminal.open({ "tig" }, { cwd = LazyVim.root.git(), esc_esc = false, ctrl_hjkl = false })
end
function M.open_tig()
  LazyVim.terminal.open({ "tig" }, { esc_esc = false, ctrl_hjkl = false })
end

return M
