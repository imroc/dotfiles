-- CJK 感知的 gx 打开：修复裸 URL 前有中文标点时 <cfile> 误将前缀纳入的问题
-- SSH 环境下通过 mac-bridge 回调 Mac 浏览器打开 URL

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

--- Resolve URLs under cursor via built-in sources, falling back to regex extraction.
---@return string[] urls list of URLs found
function M.get_urls()
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

  return final
end

---@param uri string
---@return string|nil error message
local function do_open(uri)
  -- SSH 环境：通过 mac-bridge 回调 Mac 浏览器打开
  local mac_bridge = require("util.mac_bridge")
  if mac_bridge.available() then
    mac_bridge.send("url", { url = uri })
    return nil
  end

  -- 本地环境：直接用 vim.ui.open
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
  -- 光标处是否有 http(s) URL：
  -- 1. 内置 source（LSP/extmark/treesitter，光标位置相关）
  local urls = require("vim.ui")._get_urls()
  local final = {}
  for _, u in ipairs(urls) do
    if u:match("^https?://") then
      final[#final + 1] = u
    end
  end
  -- 2. CJK-aware regex 提取（裸 URL 前有中文标点时修正 <cfile> 误判）
  if #final == 0 then
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    local extracted = url_at(line, cursor[2])
    if extracted then
      final = { extracted }
    end
  end

  for _, u in ipairs(final) do
    local err = do_open(u)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end

  -- 光标不在 URL 上：用 flash.nvim 标注屏幕内所有 URL 供选择
  if #final == 0 then
    M.gx_select()
  end
end

--- gx fallback: flash.nvim 标注可视区域内所有 URL，按 label 选择后打开（不移动光标）。
function M.gx_select()
  local ok, Flash = pcall(require, "flash")
  if not ok then
    vim.notify("flash.nvim not available for URL selection", vim.log.levels.WARN)
    return
  end

  local notified_empty = false

  Flash.jump({
    search = { multi_window = false },
    prompt = { enabled = false },
    labeler = function() end, -- label 在 matcher 中直接分配
    matcher = function(win, state, opts)
      -- opts.from/to 是 flash 传入的可视区域（(1,0)-indexed，to 为 botline+1）
      local from_lnum = opts.from and opts.from[1] or vim.fn.line("w0")
      local to_lnum = opts.to and (opts.to[1] - 1) or vim.fn.line("w$")
      local buf = vim.api.nvim_win_get_buf(win)
      local matches = {}
      for lnum = from_lnum, to_lnum do
        local line = (vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false))[1]
        if line then
          local pos = 1
          while true do
            local s, e = line:find(url_pattern, pos)
            if not s then
              break
            end
            matches[#matches + 1] = {
              pos = { lnum, s - 1 },
              end_pos = { lnum, e - 1 },
              url = line:sub(s, e), -- 自定义字段，action 中原样拿到
            }
            pos = e + 1
          end
        end
      end

      if #matches == 0 then
        if not notified_empty then
          notified_empty = true
          vim.schedule(function()
            vim.notify("No URLs on screen", vim.log.levels.INFO)
          end)
        end
        return {}
      end

      -- 分配 label（同 flash 内置 treesitter 模式的做法）
      local labels = state:labels()
      for i, m in ipairs(matches) do
        m.label = labels[i]
      end
      return matches
    end,
    action = function(match, state)
      state:restore() -- 恢复视图，光标不动
      local err = do_open(match.url)
      if err then
        vim.notify(err, vim.log.levels.ERROR)
      end
    end,
  })
end

return M
