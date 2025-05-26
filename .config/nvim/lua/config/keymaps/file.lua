local clipboard = require("util.clipboard")

-- copy file path
vim.keymap.set("n", "<leader>pa", clipboard.copy_absolute_path, { desc = "[P]Copy Absolute Path" })
vim.keymap.set("n", "<leader>pn", clipboard.copy_filename, { desc = "[P]Copy Filename" })
vim.keymap.set("n", "<leader>pr", clipboard.copy_relative_path, { desc = "[P]Copy Relative Path" })
vim.keymap.set("n", "<leader>pR", clipboard.copy_current_root_directory, { desc = "[P]Copy Current Root Directory" })
vim.keymap.set("n", "<leader>pd", clipboard.copy_current_directory, { desc = "[P]Copy Current Directory" })

-- file permission
vim.keymap.set("n", "<leader>fx", "<cmd>!chmod +x %<cr>", { desc = "[P]Add executable permission" })

vim.keymap.set("n", "<leader>yZ", function()
  require("util.zellij").run({ "yazi", require("util.buffer").current_dir() }, { name = "yazi" })
end, { desc = "[P]Open Yazi (zellij)" })
