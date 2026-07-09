---@diagnostic disable: undefined-field

local wezterm = require("wezterm")

local M = {}

local saved_im = nil
local original_im = nil

local MACISM = "/opt/homebrew/bin/macism"

local function is_macos()
  return wezterm.target_triple and wezterm.target_triple:find("apple") ~= nil
end

local function log(msg)
  local f = io.open("/tmp/wezterm-im-switch.log", "a")
  if f then
    f:write(string.format("[%s] %s\n", os.date("%H:%M:%S"), msg))
    f:close()
  end
end

local function macism(args)
  local success, stdout, stderr = wezterm.run_child_process(args)
  log(string.format("macism(%s) -> success=%s stdout=%q stderr=%q",
    table.concat(args, " "), tostring(success), stdout or "", stderr or ""))
  if success and stdout then
    return stdout:gsub("%s+", "")
  end
  return nil
end

local function switch_to(im)
  macism({ MACISM, im })
end

local function get_current_im()
  return macism({ MACISM })
end

M.setup = function()
  if not is_macos() then
    return
  end
  log("setup: im-switch enabled")

  wezterm.on("user-var-changed", function(_window, _pane, name, value)
    log(string.format("user-var-changed: name=%q value=%q", tostring(name), tostring(value)))
    if name ~= "im_select" then
      return
    end

    if value == "init" then
      original_im = get_current_im()
      switch_to("com.apple.keylayout.ABC")
    elseif value == "save_abc" then
      saved_im = get_current_im()
      switch_to("com.apple.keylayout.ABC")
    elseif value == "restore" then
      if saved_im and saved_im ~= "com.apple.keylayout.ABC" then
        switch_to(saved_im)
      end
    elseif value == "abc" then
      switch_to("com.apple.keylayout.ABC")
    elseif value == "save" then
      saved_im = get_current_im()
    elseif value == "exit" then
      if original_im then
        switch_to(original_im)
      end
    end
  end)
end

return M
