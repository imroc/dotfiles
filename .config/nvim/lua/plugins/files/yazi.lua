return {
  ---@type LazySpec
  {
    "mikavilpas/yazi.nvim",
    enabled = vim.g.simpler_scrollback ~= "deeznuts",
    lazy = true,
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
