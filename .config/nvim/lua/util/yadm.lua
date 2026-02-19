local M = {}

-- use lazygit to open dotfiles which managed by yadm
function M.open_lazygit(type)
  return function()
    local lazygit_config_file = vim.fn.expand("$HOME/.config/yadm/lazygit.yml")
    local work_tree = vim.fn.expand("$HOME")
    local git_dir = vim.fn.expand("$HOME/.local/share/yadm-" .. type .. "/repo.git")
    Snacks.terminal(
      { "lazygit", "--use-config-file", lazygit_config_file, "--work-tree", work_tree, "--git-dir", git_dir },
      { win = { width = 0, height = 0 } }
    )
  end
end

local current_git_work_tree = nil
local current_git_dir = nil

function M.set_git_env(type)
  current_git_work_tree = vim.env.GIT_WORK_TREE
  current_git_dir = vim.env.GIT_DIR
  vim.env.GIT_WORK_TREE = vim.fn.expand("$HOME")
  vim.env.GIT_DIR = vim.fn.expand("$HOME/.local/share/yadm-" .. type .. "/repo.git")
end

function M.remove_git_env()
  vim.env.GIT_WORK_TREE = current_git_work_tree
  vim.env.GIT_DIR = current_git_dir
end

-- add file to yadm
function M.git_add(filepath)
  vim.fn.system({ "yadm", "add", filepath })
  if vim.v.shell_error == 0 then
    vim.notify(string.format("Added to yadm: %s", filepath), vim.log.levels.INFO)
  else
    vim.notify(string.format("Failed to add to yadm: %s", filepath), vim.log.levels.ERROR)
  end
end

return M
