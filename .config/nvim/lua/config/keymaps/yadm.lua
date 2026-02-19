local yadm = require("util.yadm")

vim.keymap.set("n", "<leader>yi", "", { desc = "+[P]yadm private" })
vim.keymap.set("n", "<leader>yu", "", { desc = "+[P]yadm public" })
vim.keymap.set("n", "<leader>yig", yadm.open_lazygit("private"), { desc = "[P]Open Lazygit (yadm private)" })
vim.keymap.set("n", "<leader>yug", yadm.open_lazygit("public"), { desc = "[P]Open Lazygit (yadm public)" })
vim.keymap.set("n", "<leader>ye", yadm.remove_git_env, { desc = "[P]Remove Git Env (yadm work tree)" })
