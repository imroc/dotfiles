return {
  {
    "mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "buf", "buf-language-server", "protolint" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        bufls = {},
        clangd = {
          filetypes = { "c", "cpp", "objc", "objcpp", "cuda" }, -- 删除 proto
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "proto" })
    end,
  },
}
