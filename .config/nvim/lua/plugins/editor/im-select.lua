-- macOS 输入法自动切换（基于 im-select.nvim + 自定义扩展）
--
-- 核心目标：在 Neovim 中编辑时，normal 模式始终使用英文输入法，insert 模式恢复
-- 用户之前使用的输入法，消除中英文切换的心智负担。
--
-- 依赖：macism（命令行输入法切换工具，brew install macism）
-- 状态存储：vim.g.im_select_saved_state（记录离开 insert 模式时的输入法 ID）
--
-- ┌─────────────────────────────────────────────────────────────────────┐
-- │ 架构分层                                                          │
-- ├──────────────────┬──────────────────────────────────────────────────┤
-- │ im-select.nvim   │ 插件原生能力，处理 CmdlineLeave / TermLeave /  │
-- │ (opts 配置)      │ TermEnter 事件的输入法切换                      │
-- ├──────────────────┼──────────────────────────────────────────────────┤
-- │ 自定义           │ InsertLeave → 非浮动窗口：保存当前 IM，切英文   │
-- │ InsertLeave/     │ InsertEnter → 非浮动窗口：恢复之前的 IM         │
-- │ InsertEnter      │ 浮动窗口中跳过，避免 picker 内 insert/normal    │
-- │ (im-select-      │ 切换时频繁调用 macism 造成干扰                  │
-- │  floating 组)    │                                                  │
-- ├──────────────────┼──────────────────────────────────────────────────┤
-- │ 自定义           │ WinEnter → 进入非浮动窗口且非 insert 模式时     │
-- │ WinEnter         │ 切回英文。补偿浮动窗口（如 Snacks picker）      │
-- │ (同上)           │ 关闭后 InsertLeave 被跳过的问题                  │
-- ├──────────────────┼──────────────────────────────────────────────────┤
-- │ 窗口焦点处理     │ FocusLost  → insert 模式记录当前 IM             │
-- │ (im-select-      │ FocusGained → insert 模式恢复 IM，否则切英文    │
-- │  focus 组)       │ 解决 Alt-Tab 切窗口后输入法状态丢失的问题       │
-- ├──────────────────┼──────────────────────────────────────────────────┤
-- │ 生命周期         │ 启动时：记录原始 IM，切英文                      │
-- │                  │ 退出时：恢复启动前的 IM                          │
-- └──────────────────┴──────────────────────────────────────────────────┘
--
-- 为什么不用插件原生的 InsertLeave/InsertEnter？
--   插件默认会在所有窗口触发切换，包括浮动窗口。在 Snacks picker、补全弹窗
--   等浮动窗口中，用户可能在 insert 模式下输入中文搜索词，如果此时 InsertLeave
--   也触发切换，会导致频繁的 macism 调用和输入法闪烁。因此 opts 中将
--   set_previous_events 设为空，InsertLeave 也从 set_default_events 中移除，
--   改由自定义 autocmd 实现带浮动窗口过滤的版本。
--
-- 已知的边界场景：
--   - WinEnter 每次进入普通窗口都会检查输入法，如果 macism 调用耗时过长
--     可能影响窗口切换的流畅度（目前实测无感知）
--   - 浮动窗口内的 insert 模式不会保存/恢复 IM 状态

-- 只在 macOS 启用
if vim.fn.has("mac") ~= 1 then
  return {}
end

local function handle_focus_change()
  local group = vim.api.nvim_create_augroup("im-select-focus", { clear = true })
  -- 失焦时：如果在插入模式，记录当前输入法（供聚焦时恢复）
  vim.api.nvim_create_autocmd("FocusLost", {
    group = group,
    callback = function()
      local mode = vim.api.nvim_get_mode().mode
      if mode == "i" or mode == "ic" or mode == "ix" then
        saved_im_before_focus_lost = vim.fn.system({ "macism" }):gsub("%s+", "")
      else
        saved_im_before_focus_lost = nil
      end
    end,
  })

  -- 聚焦时：插入模式下恢复之前的输入法，否则切英文
  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      local mode = vim.api.nvim_get_mode().mode
      -- 插入模式：聚焦时恢复之前失焦时使用的输入法
      -- 非插入模式：默认切英文输入法
      if mode == "i" or mode == "ic" or mode == "ix" then
        if saved_im_before_focus_lost then
          vim.fn.system({ "macism", saved_im_before_focus_lost })
        end
      else
        vim.fn.system({ "macism", "com.apple.keylayout.ABC" })
      end
      saved_im_before_focus_lost = nil
    end,
  })
end

local function is_floating_win()
  return vim.api.nvim_win_get_config(0).relative ~= ""
end

return {
  -- https://github.com/keaising/im-select.nvim
  "keaising/im-select.nvim",
  lazy = false,
  enabled = vim.g.simpler_scrollback ~= "deeznuts",
  opts = {
    default_im_select = "com.apple.keylayout.ABC",
    -- default_command = "macism",
    -- 在默认事件基础上增加终端进入和离开的事件，确保终端使用场景也能自动切换输入方法
    set_default_events = { "CmdlineLeave", "TermLeave", "TermEnter" },
    set_previous_events = {},
  },
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
        local current = vim.fn.system({ "macism" }):gsub("%s+", "")
        vim.api.nvim_set_var("im_select_saved_state", current)
        if current ~= "com.apple.keylayout.ABC" then
          vim.fn.system({ "macism", "com.apple.keylayout.ABC" })
        end
      end,
    })
    vim.api.nvim_create_autocmd("InsertEnter", {
      group = im_group,
      callback = function()
        if is_floating_win() then
          return
        end
        -- quick terminal 中不自动恢复中文（避免 macism 通过切焦切换输入法导致失焦）
        if vim.env.GHOSTTY_QUICK_TERMINAL == "1" then
          return
        end
        local saved = vim.g["im_select_saved_state"]
        if saved and saved ~= "com.apple.keylayout.ABC" then
          vim.fn.system({ "macism", saved })
        end
      end,
    })

    -- 从浮动窗口回到普通窗口时，如果不在插入模式则确保切回英文
    -- 解决 Snacks picker 等浮动窗口关闭后输入法未切换的问题
    vim.api.nvim_create_autocmd("WinEnter", {
      group = im_group,
      callback = function()
        if is_floating_win() then
          return
        end
        local mode = vim.api.nvim_get_mode().mode
        if mode ~= "i" and mode ~= "ic" and mode ~= "ix" then
          local current = vim.fn.system({ "macism" }):gsub("%s+", "")
          if current ~= "com.apple.keylayout.ABC" then
            vim.fn.system({ "macism", "com.apple.keylayout.ABC" })
          end
        end
      end,
    })

    -- 启动时记录当前输入法，然后切换到英文
    local im_before_nvim = vim.fn.system({ "macism" }):gsub("%s+", "")
    vim.fn.system({ "macism", "com.apple.keylayout.ABC" })
    -- 退出时恢复启动前的输入法
    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        vim.fn.system({ "macism", im_before_nvim })
      end,
    })
  end,
}
