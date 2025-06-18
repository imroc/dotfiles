local yadm = require("util.yadm")

vim.keymap.set("n", "<leader>yl", yadm.open_lazygit, { desc = "Open Dotfiles with Lazygit" })
vim.keymap.set("n", "<leader>yd", yadm.open_lazygit, { desc = "Open Dotfiles with Diffview" })
