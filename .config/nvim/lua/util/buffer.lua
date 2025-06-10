---@diagnostic disable: undefined-global

local M = {}

---@return string
function M.current_dir()
  if vim.bo.buftype == "" then
    local absolute_path = vim.fn.expand("%:p")
    return string.match(absolute_path, "(.+)/[^/]+$")
  end
  return ""
end

---@return string
function M.absolute_path()
  return vim.fn.expand("%:p")
end

---@return string
function M.file_name()
  return vim.fn.expand("%:t")
end

---@return string
function M.relative_path()
  return vim.fn.fnamemodify(vim.fn.expand("%:p"), ":.")
end

---@return string
function M.root_dir()
  if LazyVim then
    return LazyVim.root()
  end
  return ""
end

return M
