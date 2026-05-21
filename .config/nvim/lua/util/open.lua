-- CJK 感知的 gx 打开：修复裸 URL 前有中文标点时 <cfile> 误将前缀纳入的问题
local M = {}

local url_pattern = "https?://[%w_.~!*:@&+$/?%%#-]*[%w/]"

--- Extract the URL covering the given byte column from a line, or nil.
---@param line string
---@param col number 0-based byte offset
---@return string|nil
local function url_at(line, col)
  local pos = 1
  while true do
    local s, e = line:find(url_pattern, pos)
    if not s then
      return nil
    end
    -- s,e are 1-based; col is 0-based
    if col >= s - 1 and col < e then
      return line:sub(s, e)
    end
    pos = e + 1
  end
end

---@param uri string
---@return string|nil error message
local function do_open(uri)
  local cmd, err = vim.ui.open(uri)
  local rv = cmd and cmd:wait(1000) or nil
  if cmd and rv and rv.code ~= 0 then
    err = ("vim.ui.open: command %s (%d): %s"):format(
      (rv.code == 124 and "timeout" or "failed"),
      rv.code,
      vim.inspect(cmd.cmd)
    )
  end
  return err
end

--- gx handler: resolve URLs via built-in sources, falling back to regex extraction.
function M.gx()
  local urls = require("vim.ui")._get_urls()

  -- keep only valid URLs from built-in sources
  local final = {}
  for _, u in ipairs(urls) do
    if u:match("^https?://") then
      final[#final + 1] = u
    end
  end

  -- if none, try regex extraction from current line
  if #final == 0 then
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local extracted = url_at(line, cursor[2])
    if extracted then
      final = { extracted }
    else
      final = urls
    end
  end

  for _, u in ipairs(final) do
    local err = do_open(u)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end
end

return M
