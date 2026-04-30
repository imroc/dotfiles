local M = {}

--- Check if running inside cmux
---@return boolean
function M.is_cmux()
  return vim.env.CMUX_SOCKET ~= nil
end

--- Open a URL in cmux browser.
--- Multi-pane: open as new tab in another pane (prefer rightmost).
--- Single-pane: create a right-side browser split.
--- Returns the surface ref string, or nil on failure.
---@param url string
---@param opts? { focus?: boolean } default: { focus = true }
---@return string|nil surface_ref
function M.open_browser(url, opts)
  opts = vim.tbl_extend("keep", opts or {}, { focus = true })
  -- Get caller's pane ref
  local id_out = vim.fn.system({ "cmux", "identify", "--surface", vim.env.CMUX_SURFACE_ID })
  local caller_pane = id_out:match('"pane_ref"%s*:%s*"(pane:%d+)"')

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

  local cmd
  if target_pane then
    cmd = { "cmux", "new-surface", "--type", "browser", "--pane", target_pane, "--url", url }
  else
    cmd = { "cmux", "new-pane", "--type", "browser", "--direction", "right", "--url", url }
  end

  local output = vim.fn.system(cmd)
  local surface = output:match("(surface:%d+)")
  local pane = output:match("(pane:%d+)")
  if surface and pane and opts.focus then
    vim.fn.jobstart({ "cmux", "focus-pane", "--pane", pane })
  end
  return surface
end

--- Close a cmux browser surface by ref.
---@param surface_ref string e.g. "surface:17"
function M.close_surface(surface_ref)
  vim.fn.jobstart({ "cmux", "close-surface", "--surface", surface_ref })
end

return M
