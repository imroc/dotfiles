---@diagnostic disable: undefined-field

-- 远程 SSH 输入法自动切换
--
-- 原理：远程 nvim 通过 OSC 1337 SetUserVar 序列发送指令到 WezTerm，
-- WezTerm 拦截后在本机执行 macism 切换输入法。
--
-- 指令通过 OSC 1337;SetUserVar=im_select=<base64(action)> 发送：
--   init      → 保存当前 IM 为原始状态，切英文       (nvim 启动)
--   save_abc  → 保存当前 IM，切英文                   (InsertLeave)
--   restore   → 恢复之前保存的 IM                     (InsertEnter)
--   abc       → 切英文（不保存）                      (WinEnter 等)
--   save      → 保存当前 IM（不切换）                  (FocusLost)
--   exit      → 恢复 nvim 启动前的 IM                  (VimLeave)

local wezterm = require("wezterm")

local M = {}

local saved_im = nil
local original_im = nil

-- macism 完整路径（WezTerm 的 run_child_process 用最小化 PATH，必须写死）
local MACISM = "/opt/homebrew/bin/macism"

local function is_macos()
  return wezterm.target_triple and wezterm.target_triple:find("apple") ~= nil
end

local function macism(args)
  local success, stdout, stderr = wezterm.run_child_process(args)
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

  wezterm.on("user-var-changed", function(_window, _pane, name, value)
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
