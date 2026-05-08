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
              if vim.bo.filetype == "markdown" then
                require("util.markdown").follow_link()
              else
                vim.lsp.buf.definition()
              end
            end,
            desc = "Goto Definition",
            has = "definition",
          },
        },
      },
    },
  },
}
