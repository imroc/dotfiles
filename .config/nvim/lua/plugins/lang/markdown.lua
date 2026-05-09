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
    keys = (function()
      local function toggle_toc(buf)
        local toc_injected = vim.b[buf].mkdp_toc_injected
        if toc_injected then
          -- Closing preview: search and remove injected TOC lines
          local was_modified = vim.bo[buf].modified
          local all_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
          local removed = false
          for i = 1, #all_lines - 2 do
            if all_lines[i] == "## 目录" and all_lines[i + 1] == "" and all_lines[i + 2] == "[[toc]]" then
              -- Determine range to remove: include leading/trailing empty lines if present
              local start_line = i - 1 -- 0-indexed
              if i > 1 and all_lines[i - 1] == "" then
                start_line = start_line - 1
              end
              local end_line = i + 2 -- 0-indexed, exclusive (after [[toc]])
              if i + 3 <= #all_lines and all_lines[i + 3] == "" then
                end_line = end_line + 1
              end
              vim.api.nvim_buf_set_lines(buf, start_line, end_line, false, {})
              removed = true
              break
            end
          end
          if removed and not was_modified then
            -- TOC was persisted to disk by a save during preview, re-save to clean it
            vim.cmd("silent write")
          else
            vim.bo[buf].modified = was_modified
          end
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
      end

      local function close_cmux_surface(buf)
        local cmux_surface = vim.b[buf].mkdp_cmux_surface
        if cmux_surface then
          vim.fn.jobstart({ "cmux", "close-surface", "--surface", cmux_surface })
          vim.b[buf].mkdp_cmux_surface = nil
        end
      end

      return {
        {
          "<localleader>o",
          function()
            local buf = vim.api.nvim_get_current_buf()
            toggle_toc(buf)
            close_cmux_surface(buf)
            -- Force open with system default browser (bypass cmux)
            vim.g.mkdp_browserfunc = ""
            vim.cmd("MarkdownPreviewToggle")
            -- Restore cmux handler after server has read the value
            vim.defer_fn(function()
              if vim.env.CMUX_SOCKET_PATH then
                vim.g.mkdp_browserfunc = "CmuxOpenBrowser"
              end
            end, 3000)
          end,
          ft = "markdown",
          desc = "[P]Toggle Preview (Default Browser)",
        },
        {
          "<localleader>c",
          function()
            local buf = vim.api.nvim_get_current_buf()
            close_cmux_surface(buf)
            -- Ensure cmux handler is active
            vim.g.mkdp_browserfunc = "CmuxOpenBrowser"
            vim.cmd("MarkdownPreviewToggle")
          end,
          ft = "markdown",
          desc = "[P]Toggle Preview (cmux)",
        },
      }
    end)(),
    init = function()
      vim.g.mkdp_markdown_css = vim.fn.expand("~/.config/nvim/resources/markdown-preview/github-markdown-light.css")
      vim.g.mkdp_highlight_css = vim.fn.expand("~/.config/nvim/resources/markdown-preview/github-dark.css")
      vim.g.mkdp_page_title = "${name}"
      if vim.env.CMUX_SOCKET_PATH then
        vim.g.mkdp_browserfunc = "CmuxOpenBrowser"
        _G._cmux_open_browser = function(url)
          local surface = require("util.cmux").open_browser(url, { focus = false })
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
        function()
          -- Step 1: 调用原生 archive（归档已完成的根 item）
          require("checkmate").archive()

          -- Step 2: 延迟处理子项归档（等 checkmate transaction 完成）
          vim.schedule(function()
            local bufnr = vim.api.nvim_get_current_buf()
            local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

            -- checkmate 在 buffer 中用 unicode: ✔ (checked), □ (unchecked)
            local checked_marker = "✔"
            local unchecked_marker = "□"

            -- 辅助：查找 archive section 行范围
            local function find_archive_section(buf_lines)
              local a_start, a_end
              for i, line in ipairs(buf_lines) do
                if line:match("^%s*## 已完成%s*$") then
                  a_start = i -- 1-indexed
                  a_end = #buf_lines
                  for j = i + 1, #buf_lines do
                    if buf_lines[j]:match("^%s*##[^#]") or buf_lines[j]:match("^%s*#[^#]") then
                      a_end = j - 1
                      break
                    end
                  end
                  break
                end
              end
              return a_start, a_end
            end

            local archive_start, archive_end = find_archive_section(lines)

            -- 扫描已勾选子项（排除 archive section 内的）
            -- 匹配 buffer 中 unicode 格式: "  - ✔ xxx" 或 markdown 格式: "  - [x] xxx"
            local checked_children = {} -- {row=1-indexed, indent=num, text=string}
            for i, line in ipairs(lines) do
              if archive_start and i >= archive_start then
                break
              end
              -- 匹配 unicode 格式: "  - ✔ content"
              local indent, content = line:match("^(%s+)- " .. checked_marker .. " (.+)$")
              -- fallback: 匹配 markdown 格式: "  - [x] content"
              if not indent then
                indent, content = line:match("^(%s+)- %[x%] (.+)$")
              end
              if indent and #indent >= 2 then
                table.insert(checked_children, { row = i, indent = #indent, text = content })
              end
            end

            if #checked_children == 0 then
              return
            end

            -- 为每个子项找到父项
            local groups = {} -- parent_text -> {children_texts}
            local group_order = {} -- 保持父项顺序
            local rows_to_delete = {}
            for _, child in ipairs(checked_children) do
              local parent_text
              for j = child.row - 1, 1, -1 do
                local pline = lines[j]
                -- 匹配 unicode: "- □ xxx" 或 "- ✔ xxx"（分别匹配，因为 lua pattern 不支持多字节 []）
                local pindent, pcontent = pline:match("^(%s*)- " .. unchecked_marker .. " (.+)$")
                if not pindent then
                  pindent, pcontent = pline:match("^(%s*)- " .. checked_marker .. " (.+)$")
                end
                -- fallback: markdown "- [ ] xxx" 或 "- [x] xxx"
                if not pindent then
                  pindent, pcontent = pline:match("^(%s*)- %[.%] (.+)$")
                end
                -- 最终 fallback: 普通列表 "- xxx"
                if not pindent then
                  pindent, pcontent = pline:match("^(%s*)- (.+)$")
                end
                if pindent and #pindent < child.indent then
                  parent_text = pcontent
                  break
                end
              end
              if parent_text then
                if not groups[parent_text] then
                  groups[parent_text] = {}
                  table.insert(group_order, parent_text)
                end
                table.insert(groups[parent_text], child.text)
                table.insert(rows_to_delete, child.row)
              end
            end

            if vim.tbl_isempty(groups) then
              return
            end

            -- 从后往前删除子项行（避免行号偏移）
            table.sort(rows_to_delete, function(a, b)
              return a > b
            end)
            for _, row in ipairs(rows_to_delete) do
              vim.api.nvim_buf_set_lines(bufnr, row - 1, row, false, {})
            end

            -- 重新读取 buffer，重新定位 archive section
            lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
            archive_start, archive_end = find_archive_section(lines)

            -- 如果 archive section 不存在，在文件末尾创建
            if not archive_start then
              local total = vim.api.nvim_buf_line_count(bufnr)
              local last_line = vim.api.nvim_buf_get_lines(bufnr, total - 1, total, false)[1]
              local new_lines = {}
              if last_line ~= "" then
                table.insert(new_lines, "")
              end
              table.insert(new_lines, "## 已完成")
              table.insert(new_lines, "")
              vim.api.nvim_buf_set_lines(bufnr, total, total, false, new_lines)
              lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
              archive_start, archive_end = find_archive_section(lines)
            end

            -- 解析 archive section 中已有的父项条目
            local existing_parents = {} -- parent_text -> row (1-indexed)
            for i = archive_start + 1, archive_end do
              local line = lines[i]
              -- 匹配无 checkbox 的根列表项: "- xxx"（不匹配子项 "  - xxx"）
              local ptxt = line:match("^- (.+)$")
              if ptxt then
                existing_parents[ptxt] = i
              end
            end

            -- 构建归档内容
            local append_lines = {}
            local insert_into_existing = {} -- {after_row, lines}

            for _, parent_text in ipairs(group_order) do
              local children = groups[parent_text]
              local existing_row = existing_parents[parent_text]
              if existing_row then
                -- 找到已有父项下最后一个子项，并收集已有子项文本用于去重
                local last_child_row = existing_row
                local existing_children = {}
                for j = existing_row + 1, archive_end do
                  if lines[j] and lines[j]:match("^  ") then
                    last_child_row = j
                    -- 提取子项文本（去掉缩进和 marker）
                    local ct = lines[j]:match("^%s+- %[x%] (.+)$")
                      or lines[j]:match("^%s+- " .. checked_marker .. " (.+)$")
                    if ct then
                      existing_children[ct] = true
                    end
                  else
                    break
                  end
                end
                local child_lines = {}
                for _, ct in ipairs(children) do
                  if not existing_children[ct] then
                    table.insert(child_lines, "  - [x] " .. ct)
                  end
                end
                if #child_lines > 0 then
                  table.insert(insert_into_existing, { after = last_child_row, lines = child_lines })
                end
              else
                table.insert(append_lines, "- " .. parent_text)
                for _, ct in ipairs(children) do
                  table.insert(append_lines, "  - [x] " .. ct)
                end
              end
            end

            -- 插入到已有父项下（从后往前）
            table.sort(insert_into_existing, function(a, b)
              return a.after > b.after
            end)
            for _, ins in ipairs(insert_into_existing) do
              vim.api.nvim_buf_set_lines(bufnr, ins.after, ins.after, false, ins.lines)
            end

            -- 追加新父项到 archive section 末尾
            if #append_lines > 0 then
              lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
              _, archive_end = find_archive_section(lines)
              vim.api.nvim_buf_set_lines(bufnr, archive_end, archive_end, false, append_lines)
            end
          end)
        end,
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
