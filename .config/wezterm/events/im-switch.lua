---@diagnostic disable: undefined-field

-- 远程 SSH 输入法自动切换
--
-- 原理：远程 nvim 通过 OSC 1337 SetUserVar 序列发送指令到 WezTerm，
-- WezTerm 拦截后在本机执行 macism 切换输入法。

local wezterm = require("wezterm")

local M = {}

local saved_im = nil
local original_im = nil

local function is_macos()
  return wezterm.target_triple and wezterm.target_triple:find("apple") ~= nil
end

local function macism(args)
  local success, stdout, stderr = wezterm.run_child_process(args)
  -- DEBUG: 写日志到文件
  local f = io.open("/tmp/wezterm-im-switch.log", "a")
  if f then
    f:write(string.format("[%s] macism(%s) -> success=%s stdout=%q stderr=%q\n",
      os.date("%H:%M:%S"), table.concat(args, " "), tostring(success), stdout or "", stderr or ""))
    f:close()
  end
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
    -- DEBUG
    local f = io.open("/tmp/wezterm-im-switch.log", "a")
    if f then
      f:write(string.format("[%s] setup: not macos (triple=%s), skipping\n",
        os.date("%H:%M:%S"), tostring(wezterm.target_triple)))
      f:close()
    end
    return
  end

  -- DEBUG: 记录 setup 被调用
  local f = io.open("/tmp/wezterm-im-switch.log", "a")
  if f then
    f:write(string.format("[%s] setup: im-switch enabled on macos\n", os.date("%H:%M:%S")))
    f:close()
  end

  wezterm.on("user-var-changed", function(window, pane, name, value)
    -- DEBUG: 记录所有 user-var-changed 事件
    local dbg = io.open("/tmp/wezterm-im-switch.log", "a")
    if dbg then
      dbg:write(string.format("[%s] user-var-changed: name=%q value=%q\n",
        os.date("%H:%M:%S"), tostring(name), tostring(value)))
      dbg:close()
    end

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
