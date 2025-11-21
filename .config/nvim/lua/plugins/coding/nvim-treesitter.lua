return {
  {
    "nvim-treesitter/nvim-treesitter",
    enabled = vim.g.simpler_scrollback ~= "deeznuts",
    keys = {
      {
        "<leader>sf",
        function()
          local parsers = require("nvim-treesitter.parsers")
          local languages = vim.tbl_keys(parsers)
          table.sort(languages)
          Snacks.picker.select(languages, { prompt = "Select Filetype" }, function(ft)
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
  --   "nvim-treesitter/nvim-treesitter-textobjects",
  --   config = function() end,
  -- },
}
