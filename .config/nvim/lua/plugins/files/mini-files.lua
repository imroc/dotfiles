return {
  "echasnovski/mini.files",
  keys = {
    { "<leader>a", "<leader>fm", desc = "[P]Open mini.files (Directory of Current File)", remap = true },
    { "<leader>A", "<leader>fM", desc = "[P]Open mini.files (cwd)", remap = true },
  },
  opts = {
    windows = {
      preview = false,
    },
  },
}
