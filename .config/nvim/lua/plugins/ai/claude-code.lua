return {
  "greggh/claude-code.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim", -- Required for git operations
  },
  opts = {
    command = "claude-internal",
    window = {
      position = "float",
      float = {
        width = "95%",
      },
    },
    keymaps = {
      toggle = {
        normal = "<C-.>",
        terminal = "<C-.>",
        variants = {
          continue = false,
          verbose = false,
        },
      },
      window_navigation = false,
      scrolling = false,
    },
  },
}
