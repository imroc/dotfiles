return {
  "tpope/vim-fugitive",
  lazy = true,
  keys = {
    { "<leader>uB", "<cmd>G blame<CR>", desc = "[P]Toggle All Git Blame Line" },
    {
      "<leader>gc",
      function()
        vim.cmd("Git add .")
        vim.cmd("Git commit --signoff")
      end,
      desc = "[P]Git Commit (Stage All)",
    },
    {
      "<leader>gC",
      function()
        vim.cmd("Git commit --signoff")
      end,
      desc = "[P]Git Commit",
    },
  },
  dependencies = {
    "tpope/vim-rhubarb",
    "linuxsuren/fugitive-gitee.vim",
  },
  cmd = {
    "G",
    "Git",
    "Gdiffsplit",
    "Gread",
    "Gwrite",
    "Ggrep",
    "GMove",
    "GDelete",
    "GBrowse",
    "GRemove",
    "GRename",
    "Glgrep",
    "Gedit",
  },
  ft = { "fugitive" },
}
