local M = {}

local buffer = require("util.buffer")

local function copy_and_notify(str)
  vim.fn.setreg("+", str)
  vim.fn.setreg('"', str)
  if not vim.g.vscode then
    vim.notify(string.format("Copied %s to system clipboard!", str))
  end
end

function M.copy_absolute_path()
  copy_and_notify(buffer.absolute_path())
end

function M.copy_current_directory()
  copy_and_notify(buffer.current_dir())
end

function M.copy_filename()
  copy_and_notify(buffer.file_name())
end

function M.copy_relative_path()
  copy_and_notify(buffer.relative_path())
end

function M.copy_current_root_directory()
  copy_and_notify(LazyVim.root())
end

return M
