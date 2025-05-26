return {
  {
    "nvim-treesitter/nvim-treesitter",
    keys = {
      {
        "<leader>sf",
        function()
          local parsers = require("nvim-treesitter.parsers").available_parsers()
          vim.ui.select(parsers, { prompt = "Select Filetype" }, function(ft)
            if ft then
              vim.cmd("set filetype=" .. ft)
            end
          end)
        end,
        desc = "[P]Search and Set Filetype",
      },
    },
    opts = {
      indent = { enable = false },
    },
  },
  -- {
  --   "nvim-treesitter/nvim-treesitter-context",
  --   opts = {
  --     mode = "topline",
  --   },
  -- },
}
