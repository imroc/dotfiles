return {
  {
    "folke/edgy.nvim",
    enabled = false,
    opts = function(_, opts)
      -- table.insert(opts.bottom, {
      --   ft = "Trouble",
      -- })
      -- table.insert(opts.bottom, {
      --   ft = "DiffviewFileHistory",
      -- })
      -- local trouble_index = nil
      -- for i, v in pairs(opts.bottom) do
      --   if v == "Trouble" then
      --     trouble_index = i
      --   elseif type(v) == "table" then
      --     v.size = { height = 0. }
      --   end
      -- end
      -- if trouble_index ~= nil then
      --   table.remove(opts.bottom, trouble_index)
      -- end
      opts.options = vim.tbl_deep_extend("force", opts.options or {}, {
        left = { size = 50 },
        right = { size = 60 },
      })
      opts.animate = vim.tbl_deep_extend("force", opts.animate or {}, {
        enabled = false,
      })
      opts.keys = vim.tbl_deep_extend("force", opts.keys or {}, {
        -- increase width
        ["<c-Right>"] = function(win)
          win:resize("width", 10)
        end,
        -- decrease width
        ["<c-Left>"] = function(win)
          win:resize("width", -10)
        end,
        -- increase height
        ["<c-Up>"] = function(win)
          win:resize("height", 10)
        end,
        -- decrease height
        ["<c-Down>"] = function(win)
          win:resize("height", -10)
        end,
      })

      return opts
    end,
  },
}
