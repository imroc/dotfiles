-- Load external modules first
local mini_files_km = require("config.modules.mini-files-km")
local mini_files_km_2 = require("config.modules.mini-files-km-2")
-- -- git config is slowing mini.files too much, so disabling it
local mini_files_git = require("config.modules.mini-files-git")

return {
  "nvim-mini/mini.files",
  keys = {
    {
      "<leader>e",
      function()
        if not MiniFiles.close() then
          MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
        end
      end,
      desc = "Files (Current Directory)",
    },
    {
      "<leader>E",
      function()
        if not MiniFiles.close() then
          MiniFiles.open(LazyVim.root(), true)
        end
      end,
      desc = "Files (Root Directory)",
    },
  },
  config = function(_, opts)
    -- Set up mini.files
    require("mini.files").setup(opts)
    -- Load custom keymaps
    mini_files_km.setup(opts)
    mini_files_km_2.setup(opts)

    -- Load Git integration
    -- git config is slowing mini.files too much, so disabling it
    mini_files_git.setup()
  end,
  opts = {
    windows = {
      preview = false,
    },
    mappings = {
      go_in_plus = "<CR>",
      go_in_horizontal_plus = "-",
      go_in_vertical_plus = "\\",
      synchronize = ";",
    },
    custom_keymaps = {
      open_tmux_pane = "<M-t>",
      copy_to_clipboard = "<space>Y",
      zip_and_copy = "<space>yz",
      paste_from_clipboard = "<space>p",
      copy_path = "<M-c>",
      open_with_default_app = "O",
      preview_image = "<space>i",
      preview_image_popup = "<M-i>",

      -- My own custom keymaps
      open_zellij = "<space>z",
      open_terminal = "<space>t",
      search_text = "<space>s",
      find_files = "<space>f",
      replace = "<space>r",
    },
  },
}
