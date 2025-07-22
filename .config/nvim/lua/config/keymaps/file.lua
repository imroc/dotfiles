local clipboard = require("util.clipboard")

-- copy file path
vim.keymap.set("n", "<leader>yf", clipboard.copy_absolute_path, { desc = "[P]Copy Absolute Path" })
vim.keymap.set("n", "<leader>yn", clipboard.copy_filename, { desc = "[P]Copy Filename" })
vim.keymap.set("n", "<leader>yr", clipboard.copy_relative_path, { desc = "[P]Copy Relative Path" })
vim.keymap.set("n", "<leader>yR", clipboard.copy_current_root_directory, { desc = "[P]Copy Current Root Directory" })
vim.keymap.set("n", "<leader>yd", clipboard.copy_current_directory, { desc = "[P]Copy Current Directory" })

-- file permission
vim.keymap.set("n", "<leader>fx", "<cmd>!chmod +x %<cr>", { desc = "[P]Add executable permission" })

-- yazi
vim.keymap.set("n", "<leader>yZ", function()
  require("util.zellij").run({ "yazi", require("util.buffer").current_dir() }, { name = "yazi" })
end, { desc = "[P]Open Yazi (Zellij)" })

local job = require("util.job")

vim.keymap.set("n", "<leader>ov", function()
  job.run("code", { args = { "-r", LazyVim.root() } })
end, { desc = "[P]Open VSCode (Root Dir)" })

vim.keymap.set("n", "<leader>oz", function()
  job.run("zed", { args = { LazyVim.root() } })
end, { desc = "[P]Open Zed (Root Dir)" })

vim.keymap.set("n", "<leader>on", function()
  job.run("neovide", { args = { LazyVim.root() } })
end, { desc = "[P]Open Neovide (Root Dir)" })
