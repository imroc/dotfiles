-- 输入法自动切换（基于 im-select.nvim + 自定义扩展）
--
-- 核心目标：在 Neovim 中编辑时，normal 模式始终使用英文输入法，insert 模式恢复
-- 用户之前使用的输入法，消除中英文切换的心智负担。
--
-- 两种工作模式：
--   1. 本地模式（macOS 本机）：直接调用 macism/im-select 切换输入法
--   2. 远程模式（SSH 会话）：通过 OSC 1337 SetUserVar 序列向本地 WezTerm 发送指令，
--      由 WezTerm 在本机执行 macism 切换输入法
--
-- ┌──────────────────────────────────────────────────────────────────────────┐
-- │ 远程模式架构                                                             │
-- ├──────────────────┬───────────────────────────────────────────────────────┤
-- │ 远程 nvim        │ InsertLeave → OSC: save_abc                           │
-- │ (im-select.lua)  │ InsertEnter → OSC: restore                           │
-- │                  │ WinEnter     → OSC: abc                               │
-- │                  │ FocusLost    → OSC: save                              │
-- │                  │ FocusGained  → OSC: restore / abc                     │
-- │                  │ VimEnter     → OSC: init                              │
-- │                  │ VimLeave     → OSC: exit                              │
-- ├──────────────────┼───────────────────────────────────────────────────────┤
-- │ SSH 隧道         │ OSC 序列通过 SSH stdout 流透传到本地终端              │
-- ├──────────────────┼───────────────────────────────────────────────────────┤
-- │ 本地 WezTerm     │ 拦截 OSC SetUserVar(im_select=...) 事件              │
-- │ (im-switch.lua)  │ → 在本机执行 macism 切换/查询输入法                   │
-- │                  │ → 维护 saved_im / original_im 状态                    │
-- └──────────────────┴───────────────────────────────────────────────────────┘
--
-- 依赖：
--   本地模式：macism 或 im-select（brew install macism）
--   远程模式：本地 WezTerm + macism（WezTerm 配置中的 events/im-switch.lua）
--
-- 状态存储：
--   本地模式：vim.g.im_select_saved_state（记录离开 insert 模式时的输入法 ID）
--   远程模式：状态由 WezTerm 侧管理（saved_im / original_im）
--
-- 已知的边界场景：
--   - 远程模式下无法查询当前 IM 状态，因此放弃"已为英文则不切换"的优化
--   - 远程模式下如果经过 tmux/zellij，需要开启 passthrough
--   - 浮动窗口内的 insert 模式不触发切换，避免 picker 内频繁调用

-- ──────────────────────────────────────────────────────────────────────────────
-- 模式检测
-- ──────────────────────────────────────────────────────────────────────────────

local is_mac = vim.fn.has("mac") == 1
local is_ssh = vim.env.SSH_CONNECTION ~= nil or vim.env.SSH_CLIENT ~= nil

-- 非 macOS 且非 SSH 会话：不启用
if not is_mac and not is_ssh then
  return {}
end

-- 远程模式：SSH 会话中（无论远程系统是否为 macOS，都走 OSC 通道）
local remote_mode = is_ssh

-- ──────────────────────────────────────────────────────────────────────────────
-- 工具函数
-- ──────────────────────────────────────────────────────────────────────────────

local function is_floating_win()
  return vim.api.nvim_win_get_config(0).relative ~= ""
end

-- ──────────────────────────────────────────────────────────────────────────────
-- 远程模式：通过 OSC 1337 SetUserVar 向本地 WezTerm 发送输入法指令
-- ──────────────────────────────────────────────────────────────────────────────

local function send_im_osc(action)
  local encoded = vim.base64.encode(action)
  local osc = string.format("\27]1337;SetUserVar=im_select=%s\7", encoded)
  io.stderr:write(osc)
  io.stderr:flush()
end

-- ──────────────────────────────────────────────────────────────────────────────
-- 本地模式：直接调用 macism/im-select
-- ──────────────────────────────────────────────────────────────────────────────

local im_cmd = vim.env.GHOSTTY_QUICK_TERMINAL == "1" and "im-select" or "macism"

-- ──────────────────────────────────────────────────────────────────────────────
-- 统一接口：根据模式选择切换方式
-- ──────────────────────────────────────────────────────────────────────────────

-- 切换到英文输入法（不保存当前状态）
local function switch_to_abc()
  if remote_mode then
    send_im_osc("abc")
  else
    vim.fn.system({ im_cmd, "com.apple.keylayout.ABC" })
  end
end

-- 保存当前输入法并切换到英文
local function save_and_switch_to_abc()
  if remote_mode then
    send_im_osc("save_abc")
  else
    local current = vim.fn.system({ im_cmd }):gsub("%s+", "")
    vim.api.nvim_set_var("im_select_saved_state", current)
    if current ~= "com.apple.keylayout.ABC" then
      vim.fn.system({ im_cmd, "com.apple.keylayout.ABC" })
    end
  end
end

-- 恢复之前保存的输入法
local function restore_im()
  if remote_mode then
    send_im_osc("restore")
  else
    local saved = vim.g["im_select_saved_state"]
    if saved and saved ~= "com.apple.keylayout.ABC" then
      vim.fn.system({ im_cmd, saved })
    end
  end
end

-- 仅保存当前输入法（不切换）
local function save_im()
  if remote_mode then
    send_im_osc("save")
  else
    return vim.fn.system({ im_cmd }):gsub("%s+", "")
  end
end

-- ──────────────────────────────────────────────────────────────────────────────
-- 焦点处理（FocusLost / FocusGained）
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

-- 远程模式不使用插件的命令机制（无法查询远程 IM 状态），
-- 所有事件由自定义 autocmd 处理；本地模式使用插件内置事件 + 自定义扩展
local plugin_opts
if remote_mode then
  plugin_opts = {
    default_im_select = "com.apple.keylayout.ABC",
    default_command = "true", -- 占位：远程模式不实际调用此命令
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

    -- Custom InsertEnter/InsertLeave: skip IM switching in floating windows
    local im_group = vim.api.nvim_create_augroup("im-select-floating", { clear = true })

    vim.api.nvim_create_autocmd("InsertLeave", {
      group = im_group,
      callback = function()
        if is_floating_win() then
          return
        end
        save_and_switch_to_abc()
      end,
    })

    vim.api.nvim_create_autocmd("InsertEnter", {
      group = im_group,
      callback = function()
        if is_floating_win() then
          return
        end
        restore_im()
      end,
    })

    -- 从浮动窗口回到普通窗口时，如果不在插入模式则确保切回英文
    vim.api.nvim_create_autocmd("WinEnter", {
      group = im_group,
      callback = function()
        if is_floating_win() then
          return
        end
        local mode = vim.api.nvim_get_mode().mode
        if mode ~= "i" and mode ~= "ic" and mode ~= "ix" then
          switch_to_abc()
        end
      end,
    })

    -- 远程模式下补充 CmdlineLeave 事件（本地模式由插件处理）
    if remote_mode then
      vim.api.nvim_create_autocmd("CmdlineLeave", {
        group = im_group,
        callback = function()
          switch_to_abc()
        end,
      })
    end

    -- 启动时：保存原始 IM，切英文；退出时：恢复
    if remote_mode then
      send_im_osc("init")
      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function()
          send_im_osc("exit")
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
