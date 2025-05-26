return {
  "f-person/git-blame.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>gOc", "<cmd>GitBlameOpenCommitURL<CR>", desc = "[P]Open Commit URL" },
  },
  config = function()
    require("gitblame").setup({
      date_format = "%x %X",
    })
  end,
}
