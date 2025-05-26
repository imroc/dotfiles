return {
  {
    "folke/zen-mode.nvim",
    lazy = true,
    cmd = "ZenMode",
    keys = {
      { "<leader>tz", "<cmd>ZenMode<CR>", desc = "[P]Toggle Zen Mode" },
    },
    opts = {
      window = {
        backdrop = 1,
        width = 1,
        height = 1,
      },
      plugins = {
        tmux = { enabled = true }, -- disables the tmux statusline
        todo = { enabled = true },
        -- gitsigns = { enabled = true },
      },
    },
  },
}
