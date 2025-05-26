return {
  -- https://github.com/folke/flash.nvim
  "folke/flash.nvim",
  event = "VeryLazy",
  vscode = true,
  ---@type Flash.Config
  opts = {
    modes = {
      search = {
        enabled = false,
      },
      char = {
        enabled = false,
      },
    },
  },
}
