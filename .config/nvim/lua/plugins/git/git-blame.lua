return {
  "f-person/git-blame.nvim",
  event = "VeryLazy",
  keys = {
    { "<leader>gOc", "<cmd>GitBlameOpenCommitURL<CR>", desc = "[P]Open Commit URL" },
  },
  config = function()
    vim.g.gitblame_set_extmark_options = {
      priority = 0, -- 最低显示优先级，避免遮住诊断信息
    }
    require("gitblame").setup({
      date_format = "%x %X",
    })
  end,
}
