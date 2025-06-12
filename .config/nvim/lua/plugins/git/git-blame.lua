return {
  "f-person/git-blame.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>gOc", "<cmd>GitBlameOpenCommitURL<CR>", desc = "[P]Open Commit URL" },
  },
  config = function()
    vim.g.gitblame_set_extmark_options = {
      priority = 0, -- lowest priority, avoid obscuring diagnostic information.
    }
    require("gitblame").setup({
      date_format = "%x %X",
    })
  end,
}
