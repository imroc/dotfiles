return {
  "echasnovski/mini.files",
  keys = {
    { "<leader>m", "<leader>fm", desc = "[P] Open mini.files (Directory of Current File)", remap = true },
    { "<leader>M", "<leader>fM", desc = "[P] Open mini.files (cwd)", remap = true },
  },
  opts = {
    windows = {
      preview = false,
    },
  },
}
