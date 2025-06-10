---@diagnostic disable: undefined-global

local M = {}

---@return string
M.current_dir = function()
  local absolute_path = vim.fn.expand("%:p")
  return string.match(absolute_path, "(.+)/[^/]+$")
end

---@return string
M.absolute_path = function()
  return vim.fn.expand("%:p")
end

---@return string
M.file_name = function()
  return vim.fn.expand("%:t")
end

---@return string
M.relative_path = function()
  return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
end

---@return string
M.root_dir = function()
  if LazyVim then
    return LazyVim.root()
  end
  return ""
end

return M
