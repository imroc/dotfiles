---@diagnostic disable: undefined-global

local M = {}

--- Pretty-print a path: un-resolve symlinks under HOME and replace HOME with ~
--- e.g. /data/dev/project/file.lua -> ~/dev/project/file.lua
---@param path string|nil
---@return string
function M.pretty_path(path)
  if path == nil or path == "" then
    return path or ""
  end

  local home = vim.env.HOME
  if home and vim.fn.isdirectory(home) == 1 then
    -- Scan HOME for symlinks and un-resolve them in the path
    local entries = vim.fn.readdir(home)
    for _, entry in ipairs(entries) do
      local link_path = home .. "/" .. entry
      if vim.fn.getftype(link_path) == "link" then
        local target = vim.fn.resolve(link_path)
        target = target:gsub("/+$", "")
        if path == target then
          path = link_path
        elseif path:sub(1, #target + 1) == target .. "/" then
          path = link_path .. path:sub(#target + 1)
        end
      end
    end
  end

  -- Replace HOME prefix with ~
  if home and #path >= #home and path:sub(1, #home) == home then
    if path == home then
      path = "~"
    elseif path:sub(#home + 1, #home + 1) == "/" then
      path = "~" .. path:sub(#home + 1)
    end
  end

  return path
end

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
