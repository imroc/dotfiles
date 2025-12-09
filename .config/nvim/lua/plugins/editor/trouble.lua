return {
  "folke/trouble.nvim",
  keys = {
    {
      "<leader>uj",
      function()
        require("trouble").toggle("snacks")
      end,
      desc = "[P]Toggle Trouble (Snacks)",
    },
  },
  opts = {
    -- win = {
    --   size = 20,
    -- },
    modes = {
      lsp = {
        win = {
          position = "bottom",
        },
      },
    },
    keys = {
      -- If I close the incorrect pane, I can bring it up with ctrl+o
      ["<esc>"] = "close",
    },
  },
}
