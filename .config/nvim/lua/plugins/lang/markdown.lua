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
      {
        "<localleader>o",
        function()
          local buf = vim.api.nvim_get_current_buf()
          local toc_injected = vim.b[buf].mkdp_toc_injected
          if toc_injected then
            -- Closing preview: remove injected TOC lines and restore buffer modified state
            local inject_line = vim.b[buf].mkdp_toc_line
            local was_modified = vim.bo[buf].modified
            if inject_line then
              local lines = vim.api.nvim_buf_get_lines(buf, inject_line, inject_line + 4, false)
              if lines[1] == "" and lines[2] == "## 目录" and lines[3] == "" and lines[4] == "[[toc]]" then
                vim.api.nvim_buf_set_lines(buf, inject_line, inject_line + 4, false, {})
              end
            end
            vim.bo[buf].modified = was_modified
            vim.b[buf].mkdp_toc_injected = nil
            vim.b[buf].mkdp_toc_line = nil
          else
            -- Find first ## heading
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local insert_before = nil
            for i, line in ipairs(lines) do
              if line:match("^## ") then
                insert_before = i - 1 -- 0-indexed
                break
              end
            end
            if insert_before then
              local was_modified = vim.bo[buf].modified
              vim.api.nvim_buf_set_lines(buf, insert_before, insert_before, false, { "", "## 目录", "", "[[toc]]" })
              vim.bo[buf].modified = was_modified
              vim.b[buf].mkdp_toc_injected = true
              vim.b[buf].mkdp_toc_line = insert_before
            end
          end
          -- Close cmux browser surface when toggling off
          local cmux_surface = vim.b[buf].mkdp_cmux_surface
          if cmux_surface then
            vim.fn.jobstart({ "cmux", "close-surface", "--surface", cmux_surface })
            vim.b[buf].mkdp_cmux_surface = nil
          end
          vim.cmd("MarkdownPreviewToggle")
        end,
        ft = "markdown",
        desc = "[P]Toggle Preview",
      },
    },
    init = function()
      vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/resources/markdown-preview/github-markdown-light.css")
      vim.g.mkdp_highlight_css = vim.fn.expand("~/.config/nvim/resources/markdown-preview/github-dark.css")
      vim.g.mkdp_page_title = "${name}"
      if vim.env.CMUX_SOCKET then
        vim.g.mkdp_browserfunc = "CmuxOpenBrowser"
        _G._cmux_open_browser = function(url)
          local surface = require("util.cmux").open_browser(url)
          if surface then
            vim.b.mkdp_cmux_surface = surface
          end
        end
        vim.cmd([[
          function! CmuxOpenBrowser(url) abort
            call v:lua._cmux_open_browser(a:url)
          endfunction
        ]])
      end
    end,
  },
  {
    "Kicamon/markdown-table-mode.nvim",
    opts = {},
    keys = {
      { "<localleader>T", "<cmd>Mtm<cr>", ft = "markdown", desc = "[P]Toggle Table Mode" },
    },
  },
  {
    "bngarren/checkmate.nvim",
    ft = "markdown", -- Lazy loads for Markdown files matching patterns in 'files'
    keys = {
      {
        "<C-t>",
        mode = { "n", "i" },
        "<cmd>Checkmate toggle<cr>",
      },
      {
        "<localleader>t",
        mode = { "n" },
        "<cmd>Checkmate create<cr>",
      },
      {
        "<localleader>a",
        "<cmd>Checkmate archive<cr>",
        ft = "markdown",
        desc = "[P]Archive Done Items",
      },
    },
    opts = {
      enter_insert_after_new = false,
      files = {
        "*.md", -- Any markdown file (basename matching)
      },
      archive = {
        heading = {
          title = "已完成",
          level = 2, -- e.g. ##
        },
      },
      list_continuation = {
        keys = {
          -- 保留 <CR> 默认行为
          ["<CR>"] = function()
            require("checkmate").create({ position = "below", indent = false })
          end,
          -- 禁用 checkmate 内置的 <S-CR>，改用下方 config 中的自定义映射
          -- 原因：checkmate 内置 fallback 返回 <S-CR> 原始按键码，nvim 无法处理，导致插入不可见字符
        },
      },
    },
    config = function(_, opts)
      require("checkmate").setup(opts)

      -- 自定义 <S-CR> 映射：todo 行创建缩进子 item，非 todo 行 fallback 到普通换行
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "markdown",
        callback = function(ev)
          vim.keymap.set("i", "<S-CR>", function()
            local line = vim.api.nvim_get_current_line()
            local ok, ph = pcall(require, "checkmate.parser.helpers")
            if ok and ph.match_todo(line) then
              require("checkmate").create({ position = "below", indent = true })
            else
              -- 非 todo 行：执行普通换行
              local cr = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
              vim.api.nvim_feedkeys(cr, "n", false)
            end
          end, { buffer = ev.buf, desc = "Shift-Enter: sub-item or newline" })
        end,
      })
    end,
  },
  {
    -- https://github.com/jakewvincent/mkdnflow.nvim
    "jakewvincent/mkdnflow.nvim",
    lazy = true,
    enabled = false,
    ft = { "markdown" },
    keys = {
      {
        "<localleader>Tf",
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
        "<localleader>x",
        mode = { "n", "v" },
        "<cmd>MkdnToggleToDo<cr>",
        ft = "markdown",
        desc = "[P]Toggle ToDo",
      },
      {
        "<localleader>T",
        ft = "markdown",
        desc = "[P]Table",
      },
      {
        "<localleader>Tc",
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
      to_do = {
        symbols = { " ", ">", "x" },
        in_progress = ">",
        complete = "x",
      },
      mappings = {
        MkdnTableNewRowBelow = { "n", "<localleader>ir" },
        MkdnTableNewRowAbove = { "n", "<localleader>iR" },
        MkdnTableNewColAfter = { "n", "<localleader>ic" },
        MkdnTableNewColBefore = { "n", "<localleader>iC" },
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
          local buffer = require("util.buffer")
          local iwiki_json = buffer.current_dir() .. "/iwiki.json"
          local stat = vim.loop.fs_stat(iwiki_path)
          if stat ~= nil and stat.type == "file" then
            require("util.iwiki").insert_image()
          else
            require("nvim-picgo").upload_clipboard()
          end
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
    -- event = "VeryLazy",
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
      { "<localleader>p", "<cmd>PasteImage<cr>", desc = "[P]Paste Image (Clipboard)" },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      bullet = {
        enabled = true,
        -- 仅给无序列表 bullet 加右侧间距，有序列表不加（数字后已有点号和空格）
        right_pad = function(ctx)
          return ctx.value:match("^%d") and 0 or 1
        end,
      },
      -- 禁用 yaml 代码块中 block_sequence_item "-" 的 bullet 渲染，避免与 markdown list 混淆
      yaml = { enabled = false },
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
        icons = { "󰎤 ", "󰎧 ", "󰎪 ", "󰎭 ", "󰎱 ", "󰎳 " },
        render_modes = true, -- keep rendering while inserting
      },
      checkbox = {
        -- Turn on / off checkbox state rendering
        enabled = true,
        checkbox = {
          -- Turn on / off checkbox state rendering
          enabled = true,
          -- Determines how icons fill the available space:
          --  inline:  underlying text is concealed resulting in a left aligned icon
          --  overlay: result is left padded with spaces to hide any additional text
          position = "inline",
          bullet = false,
          unchecked = {
            -- Replaces '[ ]' of 'task_list_marker_unchecked'
            icon = "   󰄱 ",
            -- Highlight for the unchecked icon
            highlight = "RenderMarkdownUnchecked",
            -- Highlight for item associated with unchecked checkbox
            scope_highlight = nil,
          },
          checked = {
            -- Replaces '[x]' of 'task_list_marker_checked'
            icon = "   󰱒 ",
            -- Highlight for the checked icon
            highlight = "RenderMarkdownChecked",
            -- Highlight for item associated with checked checkbox
            scope_highlight = nil,
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
        image = vim.g.neovim_mode == "skitty" and "" or "󰥶 ",
        -- image = " ",
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
  -- {
  --   "obsidian-nvim/obsidian.nvim",
  --   version = "*", -- use latest release, remove to use latest commit
  --   ft = "markdown",
  --   ---@module 'obsidian'
  --   ---@type obsidian.config
  --   opts = {
  --     legacy_commands = false, -- this will be removed in the next major release
  --     workspaces = {
  --       {
  --         name = "work",
  --         path = "~/work",
  --       },
  --     },
  --     frontmatter = {
  --       enabled = false,
  --     },
  --   },
  -- },
}
