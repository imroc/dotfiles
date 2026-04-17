return {
  "hedyhli/outline.nvim",
  keys = {
    { "<leader>cs", false },
  },
  opts = {
    outline_window = {
      auto_width = {
        enabled = true,
      },
    },
    providers = {
      priority = { "markdown", "lsp", "coc", "norg", "man" },
    },
  },
}
