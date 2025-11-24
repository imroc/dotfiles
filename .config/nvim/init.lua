-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.filetypes")

-- Delay for `skitty` configuration
-- If I don't add this delay, I get the message
-- "Press ENTER or type command to continue"
if vim.g.neovim_mode == "skitty" then
  vim.wait(500, function()
    return false
  end) -- Wait for X miliseconds without doing anything
end
