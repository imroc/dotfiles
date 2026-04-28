return {
  "neovim/nvim-lspconfig",
  dependencies = {
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
      },
      opts = { lsp = { auto_attach = true } },
    },
  },
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "<a-n>", false },
          { "<a-p>", false },
          {
            "gd",
            function()
              require("util.markdown").follow_link()
            end,
            desc = "[P]Follow markdown link to local file",
            has = "definition",
            enabled = function(buf)
              return vim.bo[buf].filetype == "markdown"
            end,
          },
        },
      },
    },
  },
}
