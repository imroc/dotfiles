local window = require("util.window")

vim.keymap.set({ "n", "t" }, "<C-'>", "<cmd>close<cr>", { desc = "[P]Close Window" })
vim.keymap.set("n", "<leader>j", window.clear, { desc = "[P]Clear all other windows" })
