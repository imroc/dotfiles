return {
  {
    "petertriho/nvim-scrollbar",
    lazy = false,
    dependencies = {
      "lewis6991/gitsigns.nvim",
      "folke/tokyonight.nvim",
    },
    config = function()
      local colors = require("tokyonight.colors").setup()
      require("scrollbar").setup({
        handle = {
          color = colors.blue,
          text = " ",
          blend = 30, -- Integer between 0 and 100. 0 for fully opaque and 100 to full transparent. Defaults to 30.
        },
        handlers = {
          cursor = true,
          diagnostic = true,
          gitsigns = true, -- Requires gitsigns
          handle = true,
          search = false, -- Requires hlslens
          ale = false, -- Requires ALE
        },
      })
    end,
  },
}
