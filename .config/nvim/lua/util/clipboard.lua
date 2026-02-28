---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-global

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

--- Generate @ reference text for the current file or visual selection
---@param is_visual? boolean whether called from a visual mode mapping
---@return string|nil reference text, or nil if no file
function M.get_ai_ref_text(is_visual)
  local file_path = vim.fn.expand("%:p")
  if file_path == "" then
    return nil
  end

  if is_visual then
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    return string.format('@"%s:%d-%d" ', file_path, start_line, end_line)
  else
    return '@"' .. file_path .. '" '
  end
end

---@param is_visual? boolean
function M.copy_ai_ref_text(is_visual)
  local text = M.get_ai_ref_text(is_visual)
  if not text then
    vim.notify("No file to copy", vim.log.levels.WARN)
    return
  end
  copy_and_notify(text)
end

return M
