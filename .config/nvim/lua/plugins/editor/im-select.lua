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
    set_default_events = { "InsertLeave", "CmdlineLeave", "TermLeave" },
    set_previous_events = { "InsertEnter", "TermEnter" },
  },
}
