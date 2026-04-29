return {
  "hedyhli/outline.nvim",
  keys = {
    { "<leader>cs", false },
  },
  opts = {
    outline_window = {
      auto_width = {
        enabled = true,
      },
    },
    providers = {
      priority = { "markdown", "lsp", "coc", "norg", "man" },
    },
  },
  config = function(_, opts)
    require("outline").setup(opts)

    -- Patch markdown provider to skip YAML frontmatter.
    -- The original parser treats "---" as Setext heading underline, causing
    -- frontmatter keys (e.g. "description: ...") to appear as H2 in outline.
    -- NOTE: outline internally uses require("outline/providers/markdown") (slash path),
    -- which resolves to a different module instance than "outline.providers.markdown".
    local md = require("outline/providers/markdown")
    local orig_request = md.request_symbols
    md.request_symbols = function(on_symbols, o, info)
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      -- Detect frontmatter: first line must be "---"
      if not lines[1] or not lines[1]:match("^%-%-%-+%s*$") then
        return orig_request(on_symbols, o, info)
      end
      local fm_end
      for i = 2, #lines do
        if lines[i]:match("^%-%-%-+%s*$") then
          fm_end = i
          break
        end
      end
      if not fm_end then
        return orig_request(on_symbols, o, info)
      end

      -- Call original, then filter out symbols within frontmatter range
      orig_request(function(symbols, opts2)
        local filtered = {}
        for _, sym in ipairs(symbols or {}) do
          -- sym.range.start.line is 0-indexed
          if sym.range.start.line >= fm_end then
            filtered[#filtered + 1] = sym
          end
        end
        on_symbols(filtered, opts2)
      end, o, info)
    end
  end,
}
