-- 只在 MacOS 开发机上启用
if vim.fn.has("mac") ~= 1 then
  return {}
end

-- 聚焦时: 非插入模式切英文，插入模式恢复失焦前的输入法
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
        local saved = vim.g["im_select_saved_state"]
        if saved and saved ~= "com.apple.keylayout.ABC" then
          vim.fn.system({ "macism", saved })
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
