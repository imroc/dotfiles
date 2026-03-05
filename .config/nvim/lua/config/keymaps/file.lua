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

-- weekly note
vim.keymap.set("n", "<leader>ow", file.open_weekly_note, { desc = "[P]Open Weekly Note" })

-- dotfiles
vim.keymap.set("n", "<leader>oda", "<cmd>edit ~/.config/aerospace/aerospace.toml<cr>", { desc = "[P]Aerospace" })
vim.keymap.set("n", "<leader>odc", "<cmd>edit ~/.claude-internal/settings.json<cr>", { desc = "[P]Claude" })
vim.keymap.set("n", "<leader>odf", "<cmd>edit ~/.config/fish/config.fish<cr>", { desc = "[P]Fish" })
vim.keymap.set("n", "<leader>odg", "<cmd>edit ~/.config/ghostty/config<cr>", { desc = "[P]Ghostty" })
vim.keymap.set("n", "<leader>odG", "<cmd>edit ~/.config/git/config<cr>", { desc = "[P]Git" })
vim.keymap.set("n", "<leader>odk", "<cmd>edit ~/.config/kitty/kitty.conf<cr>", { desc = "[P]Kitty" })
vim.keymap.set("n", "<leader>odK", "<cmd>edit ~/.config/karabiner/karabiner.json<cr>", { desc = "[P]Karabiner" })
vim.keymap.set("n", "<leader>odn", "<cmd>edit ~/.config/nvim/init.lua<cr>", { desc = "[P]Neovim" })
vim.keymap.set("n", "<leader>ods", "<cmd>edit ~/.config/sketchybar/sketchybarrc<cr>", { desc = "[P]Sketchybar" })
vim.keymap.set("n", "<leader>odt", "<cmd>edit ~/.config/tmux/tmux.conf.local<cr>", { desc = "[P]Tmux" })
vim.keymap.set("n", "<leader>odw", "<cmd>edit ~/.config/wezterm/wezterm.lua<cr>", { desc = "[P]Wezterm" })
vim.keymap.set("n", "<leader>odz", "<cmd>edit ~/.config/zellij/config.kdl<cr>", { desc = "[P]Zellij" })

-- rename file with iwiki.json sync
vim.keymap.set("n", "<leader>rn", file.rename, { desc = "[P]Rename current filename" })
