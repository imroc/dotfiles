local window = require("util.window")

vim.keymap.set({ "n", "t" }, "<C-'>", "<cmd>close<cr>", { desc = "[P]Close Window" })
vim.keymap.set({ "n", "t" }, "<C-x>", "<cmd>close<cr>", { desc = "[P]Close Window" })
vim.keymap.set({ "n" }, "<C-_>", "<C-W>s", { desc = "[P]Split Window Below", remap = true })
vim.keymap.set({ "n" }, "<C-\\>", "<C-W>v", { desc = "[P]Split Window Right", remap = true })
vim.keymap.set("n", "<leader>j", window.clear, { desc = "[P]Clear all other windows" })
