local yadm = require("util.yadm")

vim.keymap.set("n", "<leader>yl", yadm.open_lazygit, { desc = "[P]Open Dotfiles with Lazygit (yadm)" })
vim.keymap.set("n", "<leader>yd", yadm.open_diffview, { desc = "[P]Open Dotfiles with Diffview (yadm)" })
