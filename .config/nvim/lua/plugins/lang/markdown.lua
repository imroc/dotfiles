local colors = require("config.colors")

return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters = {
        -- https://github.com/LazyVim/LazyVim/discussions/4094#discussioncomment-10178217
        ["markdownlint-cli2"] = {
          args = { "--config", os.getenv("HOME") .. "/.config/markdownlint/.markdownlint.yaml", "--" },
        },
      },
      linters_by_ft = {
        -- 禁用 markdown 的 lint（影响写作）
        markdown = false,
      },
    },
  },
  {
    "mpas/marp-nvim",
    ft = "markdown",
    keys = {
      { "<localleader>m", "<cmd>MarpToggle<cr>", ft = "markdown", desc = "[P]Marp Toggle (PPT)" },
    },
    cmd = {
      "MarpToggle",
      "MarpStart",
      "MarpStop",
      "MarpStatus",
    },
    opts = {},
  },
  {
    "iamcco/markdown-preview.nvim",
    keys = {
      { "<localleader>P", "<cmd>MarkdownPreviewToggle<cr>", ft = "markdown", desc = "[P]Toggle Preview" },
    },
  },
  {
    -- https://github.com/jakewvincent/mkdnflow.nvim
    "jakewvincent/mkdnflow.nvim",
    lazy = true,
    ft = { "markdown" },
    keys = {
      {
        "<localleader>f",
        "<cmd>MkdnTableFormat<cr>",
        ft = "markdown",
        desc = "[P]Format Table Under The Cursor",
      },
      {
        "<localleader>l",
        "<cmd>MkdnCreateLinkFromClipboard<cr>",
        ft = "markdown",
        desc = "[P]Create Link From Clipboard",
      },
      {
        "<localleader>n",
        "<cmd>MkdnUpdateNumbering<cr>",
        ft = "markdown",
        desc = "[P]Update Numbering For List Item",
      },
      {
        "<localleader>t",
        function()
          vim.ui.input({ prompt = "Create Table: nrow ncol" }, function(msg)
            if not msg then
              return
            end
            vim.cmd("MkdnTable " .. msg)
          end)
        end,
        ft = "markdown",
        desc = "[P]Create Table",
      },
    },
    opts = {
      modules = {
        -- 禁用暂时用不上的模块，减少冲突
        folds = false,
        foldtext = false,
        bib = false,
        conceal = false,
      },
    },
  },
  {
    "askfiy/nvim-picgo",
    keys = {
      {
        "<localleader>i",
        function()
          require("nvim-picgo").upload_clipboard()
        end,
        ft = "markdown",
        desc = "[P]Insert Picture (Picgo)",
      },
      {
        "<M-i>",
        function()
          require("nvim-picgo").upload_clipboard()
        end,
        mode = { "n", "v", "i" },
        ft = "markdown",
        desc = "[P]Insert Picture (Picgo)",
      },
    },
    config = function()
      require("nvim-picgo").setup({
        temporary_storage = false,
        image_name = false,
      })
    end,
  },
  {
    "HakonHarnes/img-clip.nvim",
    event = "VeryLazy",
    ft = "markdown",
    opts = {},
    keys = {
      -- suggested keymap
      { "<localleader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      checkbox = {
        -- Determines how icons fill the available space:
        --  inline:  underlying text is concealed resulting in a left aligned icon
        --  overlay: result is left padded with spaces to hide any additional text
        position = "inline",
      },
      -- Add custom icons lamw26wmal
      link = {
        image = "󰥶 ",
        custom = {
          youtu = { pattern = "youtu%.be", icon = "󰗃 " },
        },
      },
      html = {
        -- Turn on / off all HTML rendering
        enabled = true,
        comment = {
          -- Turn on / off HTML comment concealing
          conceal = false,
        },
      },
      heading = {
        sign = true,
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
        backgrounds = {},
      },
    },
  },
}
