---@diagnostic disable: undefined-global

local M = {}

local job = require("util.job")
local buffer = require("util.buffer")

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

local current_git_dir = function()
  local dir = buffer.current_dir()
  if not dir then
    dir = LazyVim.root.git()
  end
  return dir
end

-- git commit and push
function M.git_commit_and_push()
  local cwd = current_git_dir()
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
    cwd = cwd,
  })
end

function M.git_add_all()
  local cwd = LazyVim.root.git()
  job.run_script("git add -A", {
    cwd = cwd,
    on_exit = function()
      refresh_git_status()
    end,
  })
end

function M.git_commit_amend()
  local cwd = LazyVim.root.git()
  job.run_script("git add -A && git commit --amend --no-edit", {
    cwd = cwd,
    on_exit = function()
      refresh_git_status()
    end,
  })
end

-- tig
function M.open_tig()
  local cwd = current_git_dir()
  LazyVim.terminal.open({ "tig" }, { cwd = cwd, esc_esc = false, ctrl_hjkl = false })
end

function M.open_yadm()
  local lazygit_dir = vim.fn.expand("$HOME/.local/share/yadm/lazygit")
  local home_dir = vim.fn.expand("$HOME")
  local git_dir = vim.fn.expand("$HOME/.local/share/yadm/repo.git")
  LazyVim.terminal.open(
    { "lazygit", "-ucd", lazygit_dir, "-w", home_dir, "-g", git_dir },
    { esc_esc = false, ctrl_hjkl = false }
  )
end

return M
