return {
  "echasnovski/mini.files",
  keys = {
    { "<leader>a", "<leader>fm", desc = "[P]Open mini.files (Directory of Current File)", remap = true },
    { "<leader>A", "<leader>fM", desc = "[P]Open mini.files (cwd)", remap = true },
  },
  init = function()
    local miniKeymaps = require("util.mini-files-keymaps")
    miniKeymaps.setup({
      open_zellij = "<localleader>z",
      open_terminal = "<localleader>t",
      toggle_explorer = "<leader>a",
      search_text = "<localleader>s",
      find_files = "<localleader>f",
      replace = "<localleader>r",
    })
    local miniGit = require("util.mini-files-git")
    miniGit.setup()
  end,
  opts = {
    windows = {
      preview = false,
    },
    mappings = {
      go_in_plus = "<CR>",
      go_in_horizontal_plus = "-",
      go_in_vertical_plus = "\\",
    },
  },
}
