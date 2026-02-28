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
    -- 从其它面板切回 Neovim 时，仅在非插入模式下切换到英文输入法
    vim.api.nvim_create_autocmd("FocusGained", {
      group = vim.api.nvim_create_augroup("im-select-focus", { clear = true }),
      callback = function()
        local mode = vim.api.nvim_get_mode().mode
        if mode ~= "i" and mode ~= "ic" and mode ~= "ix" then
          vim.fn.system({ "macism", "com.apple.keylayout.ABC" })
        end
      end,
    })
  end,
}
