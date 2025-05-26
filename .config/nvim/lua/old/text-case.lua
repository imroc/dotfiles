return {
  {
    "johmsalas/text-case.nvim",
    event = "VeryLazy",
    keys = {
      { "ga.", "<cmd>TextCaseOpenTelescope<CR>", mode = { "n", "v" }, desc = "[P]TextCaseOpenTelescope" },
    },
    config = function()
      require("textcase").setup({})
      require("telescope").load_extension("textcase")
    end,
  },
}
