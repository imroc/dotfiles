return {
  "ruifm/gitlinker.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  lazy = true,
  opts = {
    mappings = nil,
  },
  keys = {
    {
      "<leader>gy",
      function()
        require("gitlinker").get_buf_range_url("n")
      end,
      mode = "n",
      desc = "[P]Copy Remote URL",
    },
    {
      "<leader>gy",
      function()
        require("gitlinker").get_buf_range_url("v")
      end,
      mode = "v",
      desc = "[P]Copy Remote URL",
    },
    {
      "<leader>gOo",
      function()
        require("gitlinker").get_buf_range_url("n", { action_callback = require("gitlinker.actions").open_in_browser })
      end,
      mode = "n",
      desc = "[P]Open Current Line In Brower",
    },
    {
      "<leader>gOo",
      function()
        require("gitlinker").get_buf_range_url("v", { action_callback = require("gitlinker.actions").open_in_browser })
      end,
      mode = "v",
      desc = "[P]Open Selected Lines In Brower",
    },
    {
      "<leader>gOf",
      function()
        require("gitlinker").get_repo_url({
          action_callback = require("gitlinker.actions").open_in_browser,
        })
      end,
      mode = "n",
      desc = "[P]Open File In Brower",
    },
  },
}
