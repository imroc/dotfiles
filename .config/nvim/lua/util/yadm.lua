local M = {}

-- use lazygit to open dotfiles which managed by yadm
function M.open_lazygit()
  local lazygit_config_file = vim.fn.expand("$HOME/.config/yadm/lazygit.yml")
  local work_tree = vim.fn.expand("$HOME")
  local git_dir = vim.fn.expand("$HOME/.local/share/yadm/repo.git")
  Snacks.terminal(
    { "lazygit", "--use-config-file", lazygit_config_file, "--work-tree", work_tree, "--git-dir", git_dir },
    { win = { width = 0, height = 0 } }
  )
end

function M.open_diffview()
  local work_tree = vim.fn.expand("$HOME")
  local git_dir = vim.fn.expand("$HOME/.local/share/yadm/repo.git")
  local cmd = "DiffviewOpen --git-dir=" .. git_dir .. " --work-tree=" .. work_tree
  vim.cmd(cmd)
end

return M
