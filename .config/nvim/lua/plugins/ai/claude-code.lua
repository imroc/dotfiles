return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  opts = {
    command = "claude-internal",
    window = {
      position = "vertical",
    },
    keymaps = {
      toggle = {
        normal = "<C-m>",
        terminal = "<C-m>",
        variants = {
          continue = false,
          verbose = false,
        },
      },
    },
  },
}
