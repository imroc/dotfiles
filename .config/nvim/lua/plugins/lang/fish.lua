return {
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "fish-lsp" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        fish_lsp = {},
      },
    },
  },
}
