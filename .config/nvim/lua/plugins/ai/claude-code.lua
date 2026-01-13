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
        normal = "<C-i>",
        terminal = "<C-i>",
        variants = {
          continue = false,
          verbose = false,
        },
      },
    },
  },
}
