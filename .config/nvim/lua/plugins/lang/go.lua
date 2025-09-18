-- https://github.com/ray-x/go.nvim?tab=readme-ov-file#configuration
return {
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      {
        "neovim/nvim-lspconfig",
        opts = {
          servers = {
            gopls = {
              settings = {
                gopls = {
                  buildFlags = { "-tags=linux" }, -- 强制包含 linux tag
                },
              },
            },
          },
        },
      },
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      diagnostic = false,
      lsp_cfg = false,
      -- camelcase/snakecase
      tag_transform = "camelcase",
      -- tag_options = 'json=omitempty',
    },
    keys = {
      {
        mode = { "v", "n" },
        ft = "go",
        "<localleader>t",
        "<cmd>GoTestFunc -v<cr>",
        desc = "[P]GoTestFunc -v",
      },
      {
        mode = { "v", "n" },
        ft = "go",
        "<localleader>T",
        "<cmd>GoTestFunc -s<cr>",
        desc = "[P]GoTestFunc -s",
      },
    },
    event = { "CmdlineEnter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()', -- if you need to install/update all binaries
  },
  {
    "mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "gomodifytags" })
    end,
  },
}
