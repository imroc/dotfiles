-- bootstrap lazy.nvim, LazyVim and your plugins
vim.g.simpler_scrollback = vim.env.SIMPLER_SCROLLBACK or "default"

require("config.lazy")
require("config.filetypes")
