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

return M
