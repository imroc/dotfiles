return {
  {
    "hedyhli/outline.nvim",
    keys = {
      { "<leader>cs", false },
    },
  },
  {
    "SmiteshP/nvim-navbuddy",
    keys = {
      {
        "<leader>cs",
        function()
          require("nvim-navbuddy").open()
        end,
        desc = "[P]Symbols Outline (Float)",
      },
    },
    dependencies = {
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
      "neovim/nvim-lspconfig",
    },
    lazy = true,
    opts = { lsp = { auto_attach = true } },
  },
}
