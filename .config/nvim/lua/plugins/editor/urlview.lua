return {
  {
    "axieax/urlview.nvim",
    lazy = false,
    cmd = {
      "UrlView",
    },
    keys = {
      { "<leader>fu", "<cmd>UrlView<cr>", desc = "[P]Find URL" },
    },
    config = function()
      require("urlview").setup({
        default_action = "system",
      })
    end,
  },
}
