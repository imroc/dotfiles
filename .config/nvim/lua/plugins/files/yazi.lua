return {
  ---@type LazySpec
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>yz",
        "<cmd>Yazi<cr>",
        desc = "[P]Open Yazi",
      },
    },
    ---@type YaziConfig
    opts = {
      keymaps = {
        show_help = "H",
      },
    },
    -- enabled = false,
  },
}
