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
        -- 禁用条件编译的代码用注释方式渲染（比如 c/c++ 的 #ifdef 内的代码内容太暗，影响阅读）
        highlights["@lsp.type.comment"] = {}
      end,
    },
    priority = 9999999,
  },
}
