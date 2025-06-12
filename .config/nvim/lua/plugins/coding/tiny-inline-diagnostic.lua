return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    config = function()
      require("tiny-inline-diagnostic").setup({
        transparent_bg = true,
        transparent_cursorline = true,
        options = {
          multilines = {
            enabled = false,
            always_show = false,
          },
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = { diagnostics = { virtual_text = false } },
  },
}
