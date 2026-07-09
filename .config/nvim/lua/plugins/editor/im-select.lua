-- 输入法自动切换（基于 im-select.nvim + 自定义扩展）
--
-- 核心目标：在 Neovim 中编辑时，normal 模式始终使用英文输入法，insert 模式恢复
-- 用户之前使用的输入法，消除中英文切换的心智负担。
--
-- 三种工作模式（自动检测）：
--   1. 本地模式（macOS 非 SSH）：直接调用 macism
--   2. 隧道模式（SSH + 反向隧道可用）：通过 nc 发送指令到本地监听服务
--   3. OSC 模式（SSH + 无隧道 + WezTerm）：通过 OSC 1337 向本地 WezTerm 发送指令
--
-- ┌──────────────────────────────────────────────────────────────────────────────┐
-- │ 隧道模式架构                                                                │
-- ├──────────────────┬───────────────────────────────────────────────────────────┤
-- │ 远程 nvim        │ InsertLeave → echo "save_abc" | nc -w1 localhost:17395   │
-- │ (im-select.lua)  │ InsertEnter → echo "restore"  | nc -w1 localhost:17395  │
-- │                  │ VimEnter    → echo "init"     | nc -w1 localhost:17395   │
-- │                  │ VimLeave    → echo "exit"     | nc -w1 localhost:17395   │
-- ├──────────────────┼───────────────────────────────────────────────────────────┤
-- │ SSH 反向隧道     │ SSH -R 17395:localhost:17395  远程 → 本地端口转发         │
-- ├──────────────────┼───────────────────────────────────────────────────────────┤
-- │ 本地监听服务      │ im-switch-listener (Python) 接收指令 → 执行 macism        │
-- │ (本地 Mac)       │ 维护 saved_im / original_im 状态                         │
-- └──────────────────┴───────────────────────────────────────────────────────────┘
--
-- 状态存储：
--   本地模式：vim.g.im_select_saved_state
--   隧道/OSC 模式：状态由本地服务/WezTerm 管理
--
-- 依赖：
--   本地模式：macism 或 im-select（brew install macism）
--   隧道模式：本地 im-switch-listener + SSH RemoteForward + 远程 nc
--   OSC 模式：本地 WezTerm + macism（WezTerm 配置 events/im-switch.lua）

-- ──────────────────────────────────────────────────────────────────────────────
-- 模式检测
-- ──────────────────────────────────────────────────────────────────────────────

local is_mac = vim.fn.has("mac") == 1
local is_ssh = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_CLIENT ~= nil

if not is_mac and not is_ssh then
  return {}
end

local remote_mode = is_ssh

-- ──────────────────────────────────────────────────────────────────────────────
-- 工具函数
-- ──────────────────────────────────────────────────────────────────────────────

local function is_floating_win()
  return vim.api.nvim_win_get_config(0).relative ~= ""
end

-- ──────────────────────────────────────────────────────────────────────────────
-- 远程模式：检测可用通道（隧道 or OSC）
-- ──────────────────────────────────────────────────────────────────────────────

local TUNNEL_PORT = 17395
local use_tunnel = false

if remote_mode then
  -- 用 nc -z 同步检测反向隧道端口是否可用
  local ret = vim.fn.system({ "nc", "-z", "-w1", "127.0.0.1", tostring(TUNNEL_PORT) })
  use_tunnel = vim.v.shell_error == 0
end

-- ──────────────────────────────────────────────────────────────────────────────
-- 远程模式：发送指令
-- ──────────────────────────────────────────────────────────────────────────────

local function send_im_osc(action)
  local encoded = vim.base64.encode(action)
  local osc = string.format("\27]1337;SetUserVar=im_select=%s\7", encoded)
  io.stderr:write(osc)
  io.stderr:flush()
end

local function send_im_tunnel(action)
  vim.fn.system({ "nc", "-w1", "127.0.0.1", tostring(TUNNEL_PORT) }, action)
end

local function send_im_remote(action)
  if use_tunnel then
    send_im_tunnel(action)
  else
    send_im_osc(action)
  end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- 本地模式
-- ──────────────────────────────────────────────────────────────────────────────

local im_cmd = vim.env.GHOSTTY_QUICK_TERMINAL == "1" and "im-select" or "macism"

-- ──────────────────────────────────────────────────────────────────────────────
-- 统一接口
-- ──────────────────────────────────────────────────────────────────────────────

local function switch_to_abc()
  if remote_mode then
    send_im_remote("abc")
  else
    vim.fn.system({ im_cmd, "com.apple.keylayout.ABC" })
  end
end

local function save_and_switch_to_abc()
  if remote_mode then
    send_im_remote("save_abc")
  else
    local current = vim.fn.system({ im_cmd }):gsub("%s+", "")
    vim.api.nvim_set_var("im_select_saved_state", current)
    if current ~= "com.apple.keylayout.ABC" then
      vim.fn.system({ im_cmd, "com.apple.keylayout.ABC" })
    end
  end
end

local function restore_im()
  if remote_mode then
    send_im_remote("restore")
  else
    local saved = vim.g["im_select_saved_state"]
    if saved and saved ~= "com.apple.keylayout.ABC" then
      vim.fn.system({ im_cmd, saved })
    end
  end
end

local function save_im()
  if remote_mode then
    send_im_remote("save")
  else
    return vim.fn.system({ im_cmd }):gsub("%s+", "")
  end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- 焦点处理
-- ──────────────────────────────────────────────────────────────────────────────

local saved_im_before_focus_lost

local function handle_focus_change()
  local group = vim.api.nvim_create_augroup("im-select-focus", { clear = true })

  vim.api.nvim_create_autocmd("FocusLost", {
    group = group,
    callback = function()
      local mode = vim.api.nvim_get_mode().mode
      if mode == "i" or mode == "ic" or mode == "ix" then
        saved_im_before_focus_lost = save_im()
      else
        saved_im_before_focus_lost = nil
      end
    end,
  })

  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      local mode = vim.api.nvim_get_mode().mode
      if mode == "i" or mode == "ic" or mode == "ix" then
        restore_im()
      else
        switch_to_abc()
      end
      saved_im_before_focus_lost = nil
    end,
  })
end

-- ──────────────────────────────────────────────────────────────────────────────
-- 插件配置
-- ──────────────────────────────────────────────────────────────────────────────

local plugin_opts
if remote_mode then
  plugin_opts = {
    default_im_select = "com.apple.keylayout.ABC",
    default_command = "true",
    set_default_events = {},
    set_previous_events = {},
  }
else
  plugin_opts = {
    default_im_select = "com.apple.keylayout.ABC",
    default_command = im_cmd,
    set_default_events = { "CmdlineLeave", "TermLeave", "TermEnter" },
    set_previous_events = {},
  }
end

return {
  "keaising/im-select.nvim",
  lazy = false,
  enabled = vim.g.simpler_scrollback ~= "deeznuts",
  opts = plugin_opts,
  config = function(_, opts)
    require("im_select").setup(opts)
    handle_focus_change()

    local im_group = vim.api.nvim_create_augroup("im-select-floating", { clear = true })

    vim.api.nvim_create_autocmd("InsertLeave", {
      group = im_group,
      callback = function()
        if is_floating_win() then return end
        save_and_switch_to_abc()
      end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
      group = im_group,
      callback = function()
        if is_floating_win() then return end
        restore_im()
      end,
    })

    vim.api.nvim_create_autocmd("WinEnter", {
      group = im_group,
      callback = function()
        if is_floating_win() then return end
        local mode = vim.api.nvim_get_mode().mode
        if mode ~= "i" and mode ~= "ic" and mode ~= "ix" then
          switch_to_abc()
        end
      end,
    })

    if remote_mode then
      vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = im_group,
        callback = function()
          switch_to_abc()
        end,
      })
    end

    if remote_mode then
      send_im_remote("init")
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          send_im_remote("exit")
        end,
      })
    else
      local im_before_nvim = vim.fn.system({ im_cmd }):gsub("%s+", "")
      vim.fn.system({ im_cmd, "com.apple.keylayout.ABC" })
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          vim.fn.system({ im_cmd, im_before_nvim })
        end,
      })
    end
  end,
}
