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
                -- 去重同一行的多个定义结果（如 lua_ls 对 Table.field = function() 返回两个位置）
                vim.lsp.buf.definition({
                  on_list = function(options)
                    local items = options.items
                    if #items > 1 then
                      -- 按 filename+lnum 去重，只保留每行的第一个结果
                      local seen = {}
                      local unique = {}
                      for _, item in ipairs(items) do
                        local key = (item.filename or "") .. ":" .. (item.lnum or 0)
                        if not seen[key] then
                          seen[key] = true
                          unique[#unique + 1] = item
                        end
                      end
                      items = unique
                    end
                    if #items == 1 then
                      local item = items[1]
                      local b = item.bufnr or vim.fn.bufadd(item.filename)
                      vim.cmd("normal! m'")
                      vim.bo[b].buflisted = true
                      vim.api.nvim_win_set_buf(0, b)
                      vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
                      vim.cmd("normal! zv")
                    else
                      vim.fn.setqflist({}, " ", { title = options.title, items = items })
                      vim.cmd("botright copen")
                    end
                  end,
                })
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
