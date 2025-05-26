return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    opts = {
      -- 透明背景
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      -- style = "night",
      on_highlights = function(highlights, colors)
        -- 默认的 unused 高亮太暗了(#414868，源码文件 tokyonight.nvim/extras/lua/tokyonight_night.lua)，看不清，提高亮度到注释一样亮
        highlights.DiagnosticUnnecessary = {
          fg = colors.comment,
        }
      end,
    },
    priority = 9999999,
  },
}
