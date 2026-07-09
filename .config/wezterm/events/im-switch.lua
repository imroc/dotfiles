---@diagnostic disable: undefined-field

local wezterm = require("wezterm")

local M = {}

local saved_im = nil
local original_im = nil

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
  log("macism() called: " .. table.concat(args, " "))
  local ok, success, stdout, stderr = pcall(wezterm.run_child_process, args)
  if not ok then
    log("macism() pcall FAILED: " .. tostring(success))
    return nil
  end
  log(string.format("macism() -> success=%s stdout=%q stderr=%q",
    tostring(success), stdout or "", stderr or ""))
  if success and stdout then
    return stdout:gsub("%s+", "")
  end
  return nil
end

local function switch_to(im)
  macism({ "macism", im })
end

local function get_current_im()
  return macism({ "macism" })
end

M.setup = function()
  if not is_macos() then
    log("setup: not macos (triple=" .. tostring(wezterm.target_triple) .. "), skipping")
    return
  end
  log("setup: im-switch enabled on macos")

  wezterm.on("user-var-changed", function(window, pane, name, value)
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
