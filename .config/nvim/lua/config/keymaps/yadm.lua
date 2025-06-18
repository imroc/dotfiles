local yadm = require("util.yadm")

vim.keymap.set("n", "<leader>yg", yadm.open_lazygit, { desc = "[P]Open Lazygit (yadm)" })
vim.keymap.set("n", "<leader>ye", yadm.set_git_env, { desc = "[P]Set Git Env (yadm work tree)" })
