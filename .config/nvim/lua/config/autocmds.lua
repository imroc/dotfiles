-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- disable the default wrap and check for spell in LazyVim
vim.api.nvim_create_augroup("lazyvim_wrap_spell", { clear = true })
