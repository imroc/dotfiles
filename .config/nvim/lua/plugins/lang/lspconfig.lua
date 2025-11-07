return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "<a-n>", false },
          { "<a-p>", false },
        },
      },
    },
  },
}
