-- 只在 MacOS 开发机上启用
if vim.fn.has("mac") ~= 1 then
  return {}
end

return {
  -- https://github.com/keaising/im-select.nvim
  "keaising/im-select.nvim",
  lazy = false,
  enabled = vim.g.simpler_scrollback ~= "deeznuts",
  opts = {
    default_im_select = "com.apple.keylayout.ABC",
    default_command = "macism",
    -- 在默认事件基础上增加终端进入和离开的事件，确保终端使用场景也能自动切换输入方法
    set_default_events = { "InsertLeave", "CmdlineLeave", "TermLeave", "TermEnter" },
    set_previous_events = { "InsertEnter" },
  },
  config = function(_, opts)
    require("im_select").setup(opts)

    local group = vim.api.nvim_create_augroup("im-select-focus", { clear = true })
    -- 用于记录失焦时插入模式下的输入法
    local saved_im_before_focus_lost = nil
    -- 用于记录聚焦时插入模式下的输入法
    local saved_im_before_focus_gained = nil

    -- 失焦时：如果在插入模式，记录当前输入法
    vim.api.nvim_create_autocmd("FocusLost", {
      group = group,
      callback = function()
        local mode = vim.api.nvim_get_mode().mode
        -- 如果在插入模式，失焦时记录当前输入法
        if mode == "i" or mode == "ic" or mode == "ix" then
          saved_im_before_focus_lost = vim.fn.system({ "macism" }):gsub("%s+", "")
        else
          saved_im_before_focus_lost = nil
        end
        -- 失焦时清理上次聚焦时的输入法记录
        if saved_im_before_focus_gained then
          saved_im_before_focus_gained = nil
        end
      end,
    })

    -- 聚焦时：插入模式下恢复之前的输入法，否则切英文
    vim.api.nvim_create_autocmd("FocusGained", {
      group = group,
      callback = function()
        -- 聚焦时记录聚焦前的输入法
        saved_im_before_focus_gained = vim.fn.system({ "macism" }):gsub("%s+", "")
        local mode = vim.api.nvim_get_mode().mode
        -- 插入模式恢复失焦时的输入法
        if mode == "i" or mode == "ic" or mode == "ix" then
          if saved_im_before_focus_lost then
            vim.fn.system({ "macism", saved_im_before_focus_lost })
            saved_im_before_focus_lost = nil
          end
        else
          -- 其它模式切英文
          vim.fn.system({ "macism", "com.apple.keylayout.ABC" })
        end
      end,
    })
  end,
}
