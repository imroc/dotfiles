-- local colors = require("config.colors")

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
        mode = { "n", "v" },
        "<cmd>MkdnCreateLinkFromClipboard<cr>",
        ft = "markdown",
        desc = "[P]Create Link From Clipboard",
      },
      {
        "<localleader>L",
        mode = { "n", "v" },
        "<cmd>MkdnDestroyLink<cr>",
        ft = "markdown",
        desc = "[P]Destroy Link",
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
    -- enabled = vim.g.simpler_scrollback ~= "deeznuts",
    lazy = true,
    event = "VeryLazy",
    ft = "markdown",
    opts = {
      default = {
        drag_and_drop = {
          enabled = false,
        },
      },
    },
    keys = {
      -- suggested keymap
      { "<localleader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      -- anti_conceal = {
      -- ignore = {},
      -- },
      callout = {
        abstract = {
          raw = "[!ABSTRACT]",
          rendered = "󰯂 Abstract",
          highlight = "RenderMarkdownInfo",
          category = "obsidian",
        },
        summary = {
          raw = "[!SUMMARY]",
          rendered = "󰯂 Summary",
          highlight = "RenderMarkdownInfo",
          category = "obsidian",
        },
        tldr = { raw = "[!TLDR]", rendered = "󰦩 Tldr", highlight = "RenderMarkdownInfo", category = "obsidian" },
        failure = {
          raw = "[!FAILURE]",
          rendered = " Failure",
          highlight = "RenderMarkdownError",
          category = "obsidian",
        },
        fail = { raw = "[!FAIL]", rendered = " Fail", highlight = "RenderMarkdownError", category = "obsidian" },
        missing = {
          raw = "[!MISSING]",
          rendered = " Missing",
          highlight = "RenderMarkdownError",
          category = "obsidian",
        },
        attention = {
          raw = "[!ATTENTION]",
          rendered = " Attention",
          highlight = "RenderMarkdownWarn",
          category = "obsidian",
        },
        warning = {
          raw = "[!WARNING]",
          rendered = " Warning",
          highlight = "RenderMarkdownWarn",
          category = "github",
        },
        danger = {
          raw = "[!DANGER]",
          rendered = " Danger",
          highlight = "RenderMarkdownError",
          category = "obsidian",
        },
        error = { raw = "[!ERROR]", rendered = " Error", highlight = "RenderMarkdownError", category = "obsidian" },
        bug = { raw = "[!BUG]", rendered = " Bug", highlight = "RenderMarkdownError", category = "obsidian" },
        quote = { raw = "[!QUOTE]", rendered = " Quote", highlight = "RenderMarkdownQuote", category = "obsidian" },
        cite = { raw = "[!CITE]", rendered = " Cite", highlight = "RenderMarkdownQuote", category = "obsidian" },
        todo = { raw = "[!TODO]", rendered = " Todo", highlight = "RenderMarkdownInfo", category = "obsidian" },
        wip = { raw = "[!WIP]", rendered = "󰦖 WIP", highlight = "RenderMarkdownHint", category = "obsidian" },
        done = { raw = "[!DONE]", rendered = " Done", highlight = "RenderMarkdownSuccess", category = "obsidian" },
      },
      -- sign = { enabled = false },
      code = {
        disable_background = true,
        -- avoid making headings ugly
        highlight_inline = "RenderMarkdownCodeInfo",
      },
      heading = {
        icons = { " 󰼏 ", " 󰎨 ", " 󰼑 ", " 󰎲 ", " 󰼓 ", " 󰎴 " },
        border = true,
        render_modes = true, -- keep rendering while inserting
      },
      checkbox = {
        unchecked = {
          icon = "󰄱",
          highlight = "RenderMarkdownCodeFallback",
          scope_highlight = "RenderMarkdownCodeFallback",
        },
        checked = {
          icon = "󰄵",
          highlight = "RenderMarkdownUnchecked",
          scope_highlight = "RenderMarkdownUnchecked",
        },
        custom = {
          question = {
            raw = "[?]",
            rendered = "",
            highlight = "RenderMarkdownError",
            scope_highlight = "RenderMarkdownError",
          },
          todo = {
            raw = "[>]",
            rendered = "󰦖",
            highlight = "RenderMarkdownInfo",
            scope_highlight = "RenderMarkdownInfo",
          },
          canceled = {
            raw = "[-]",
            rendered = "",
            highlight = "RenderMarkdownCodeFallback",
            scope_highlight = "@text.strike",
          },
          important = {
            raw = "[!]",
            rendered = "",
            highlight = "RenderMarkdownWarn",
            scope_highlight = "RenderMarkdownWarn",
          },
          favorite = {
            raw = "[~]",
            rendered = "",
            highlight = "RenderMarkdownMath",
            scope_highlight = "RenderMarkdownMath",
          },
        },
      },
      pipe_table = {
        alignment_indicator = "─",
        border = { "╭", "┬", "╮", "├", "┼", "┤", "╰", "┴", "╯", "│", "─" },
      },
      link = {
        wiki = { icon = " ", highlight = "RenderMarkdownWikiLink", scope_highlight = "RenderMarkdownWikiLink" },
        image = " ",
        custom = {
          github = { pattern = "github", icon = " " },
          gitlab = { pattern = "gitlab", icon = "󰮠 " },
          youtube = { pattern = "youtube", icon = " " },
          cern = { pattern = "cern.ch", icon = " " },
        },
        hyperlink = " ",
      },
      completions = {
        blink = { enabled = true },
        lsp = { enabled = true },
      },
    },
  },
}
