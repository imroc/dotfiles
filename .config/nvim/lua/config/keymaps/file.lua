local clipboard = require("util.clipboard")
local job = require("util.job")
local file = require("util.file")
local picker = require("util.picker")

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

vim.keymap.set("n", "<leader>oc", function()
  job.run("code", { args = { "-r", LazyVim.root() } })
end, { desc = "[P]Open VSCode (Root Dir)" })

vim.keymap.set("n", "<leader>oz", function()
  job.run("zed", { args = { LazyVim.root() } })
end, { desc = "[P]Open Zed (Root Dir)" })

vim.keymap.set("n", "<leader>on", function()
  job.run("neovide", { args = { LazyVim.root() } })
end, { desc = "[P]Open Neovide (Root Dir)" })

vim.keymap.set("n", "<leader>ob", function()
  job.run("buddycn", { args = { "-r", LazyVim.root() } })
end, { desc = "[P]Open CodeBuddy (Root Dir)" })

-- dotfiles
vim.keymap.set("n", "<leader>odn", function()
  picker.files({ cwd = vim.fn.expand("~/.config/nvim") })
end, { desc = "[P]Nvim" })
vim.keymap.set("n", "<leader>odf", function()
  picker.files({ cwd = vim.fn.expand("~/.config/fish") })
end, { desc = "[P]Fish" })
vim.keymap.set("n", "<leader>oda", "<cmd>edit ~/.config/aerospace/aerospace.toml<cr>", { desc = "[P]Aerospace" })
vim.keymap.set("n", "<leader>odg", "<cmd>edit ~/.config/ghostty/config<cr>", { desc = "[P]Ghostty" })
vim.keymap.set("n", "<leader>odz", "<cmd>edit ~/.config/zellij/config.kdl<cr>", { desc = "[P]Zellij" })

-- rename file with iwiki.json sync
vim.keymap.set("n", "<leader>rn", file.rename, { desc = "[P]Rename current filename" })
