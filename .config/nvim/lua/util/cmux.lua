-- cmux 终端集成：环境检测、浏览器打开、pane zoom 控制。
-- 通过 cmux CLI 和 RPC 接口操作，zoom 检测使用 AppleScript 触发快捷键。
local M = {}

--- Check if running inside cmux
---@return boolean
function M.is_cmux()
  return vim.env.CMUX_SOCKET_PATH ~= nil
end

--- Open a URL in cmux browser.
--- same_pane=true: open as new tab in the caller's pane (nvim's pane).
--- Multi-pane: open as new tab in another pane (prefer rightmost).
--- Single-pane: create a right-side browser split.
--- Returns the surface ref string, or nil on failure.
---@param url string
---@param opts? { focus?: boolean, same_pane?: boolean } default: { focus = true, same_pane = false }
---@return string|nil surface_ref
function M.open_browser(url, opts)
  opts = vim.tbl_extend("keep", opts or {}, { focus = true, same_pane = false })
  -- Get caller's pane ref
  local id_out = vim.fn.system({ "cmux", "identify", "--surface", vim.env.CMUX_SURFACE_ID })
  local caller_pane = id_out:match('"pane_ref"%s*:%s*"(pane:%d+)"')

  local cmd
  if opts.same_pane and caller_pane then
    -- Open in the same pane as nvim (new tab)
    cmd = { "cmux", "new-surface", "--type", "browser", "--pane", caller_pane, "--url", url }
  else
    -- List all panes in current workspace
    local panes_out = vim.fn.system("cmux list-panes")
    local panes = {}
    for ref in panes_out:gmatch("(pane:%d+)") do
      table.insert(panes, ref)
    end

    local target_pane = nil
    if #panes > 1 and caller_pane then
      for i = #panes, 1, -1 do
        if panes[i] ~= caller_pane then
          target_pane = panes[i]
          break
        end
      end
    end

    if target_pane then
      cmd = { "cmux", "new-surface", "--type", "browser", "--pane", target_pane, "--url", url }
    else
      cmd = { "cmux", "new-pane", "--type", "browser", "--direction", "right", "--url", url }
    end
  end

  local output = vim.fn.system(cmd)
  local surface = output:match("(surface:%d+)")
  local pane = output:match("(pane:%d+)")
  if opts.focus then
    local focus_target = surface or pane
    if focus_target then
      vim.fn.jobstart({ "cmux", "focus-panel", "--panel", focus_target })
    end
  end
  return surface
end

--- Close a cmux browser surface by ref.
---@param surface_ref string e.g. "surface:17"
function M.close_surface(surface_ref)
  vim.fn.jobstart({ "cmux", "close-surface", "--surface", surface_ref })
end

--- Zoom the current pane if workspace has multiple panes and not already zoomed.
--- Uses AppleScript to trigger Cmd+Return (toggleSplitZoom).
function M.zoom_if_split()
  if not M.is_cmux() then
    return
  end
  local output = vim.fn.system("cmux rpc pane.list")
  local ok, data = pcall(vim.json.decode, output)
  if not ok or not data or not data.panes then
    return
  end
  if #data.panes <= 1 then
    return
  end
  -- Detect zoom state: cmux freezes pixel_frame on zoom but updates columns/rows
  -- to reflect the actual (full-container) size. Use a non-focused pane to derive
  -- the display scale factor, then check if focused pane's columns exceed what
  -- its pixel_frame can hold at that scale.
  local focused = nil
  local ref_pane = nil -- a non-focused pane to derive scale factor
  for _, pane in ipairs(data.panes) do
    if pane.focused then
      focused = pane
    elseif not ref_pane and (pane.pixel_frame or {}).width and pane.pixel_frame.width > 0 then
      ref_pane = pane
    end
  end
  if focused and ref_pane then
    local cell_w = focused.cell_width_px or 0
    if cell_w > 0 then
      -- scale = columns * cell_width / pixel_width (≈2.0 on Retina)
      local scale = (ref_pane.columns * ref_pane.cell_width_px) / ref_pane.pixel_frame.width
      local expected_cols = (focused.pixel_frame or {}).width and focused.pixel_frame.width * scale / cell_w or 0
      -- If actual columns exceed expected by >30%, pane is zoomed
      if expected_cols > 0 and focused.columns > expected_cols * 1.3 then
        return
      end
    end
  end
  -- Trigger toggleSplitZoom via AppleScript
  vim.fn.jobstart({
    "osascript",
    "-e",
    'tell application "System Events" to tell process "cmux" to keystroke return using command down',
  })
end

return M
