local miniFiles = require("util.mini-files")

return {
  "nvim-mini/mini.pairs",
  version = false,
  opts = {
    custom_keymaps = {
      copy_to_clipboard = "<localleader>C",
      zip_and_copy = "<localleader>Z",
      paste_from_clipboard = "<localleader>P",
      copy_path = "<localleader>c",
      preview_image = "<localleader>p",
      open_zellij = "<localleader>z",
      open_terminal = "<localleader>t",
      find_files = "<localleader>f",
      search_text = "<localleader>s",
      search_plaintext = "<localleader>S",
    },
    mappings = {
      -- Default =
      synchronize = "s",
      go_in_plus = "<CR>",
    },
    windows = {
      preview = true,
      width_focus = 30,
      width_preview = 80,
    },
  },
  config = function(_, opts)
    -- Set up mini.files
    require("mini.files").setup(opts)
    -- Load custom keymaps
    miniFiles.create_autocmd(opts)
  end,
  dependencies = {
    {
      "echasnovski/mini.nvim",
      version = false,
    },
  },
  keys = {
    {
      -- Open the directory of the file currently being edited
      -- If the file doesn't exist because you maybe switched to a new git branch
      -- open the current working directory
      "<C-M-e>",
      miniFiles.open_current_dir,
      desc = "[P]Open mini.files (Directory of Current File or CWD if not exists)",
    },
    -- Open the current working directory
    -- {
    --   "<leader>E",
    --   miniFiles.open_cwd,
    --   desc = "[P]Open mini.files (cwd)",
    -- },
  },
}
