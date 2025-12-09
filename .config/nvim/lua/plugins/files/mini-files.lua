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
  init = function()
    local miniKeymaps = require("util.mini-files-keymaps")
    miniKeymaps.setup({
      open_zellij = "<localleader>z",
      open_terminal = "<localleader>t",
      search_text = "<localleader>s",
      find_files = "<localleader>f",
      replace = "<localleader>r",
      copy_to_clipboard = "<localleader>y",
      paste_from_clipboard = "<localleader>p",
      copy_path = "<localleader>c",
      preview_image = "<localleader>i",
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
      synchronize = ";",
    },
  },
}
