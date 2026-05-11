local clipboard = require("util.clipboard")
local job = require("util.job")
local file = require("util.file")
local picker = require("util.picker")

-- copy file path
vim.keymap.set("n", "<leader>yf", clipboard.copy_absolute_path, { desc = "[P]Copy Absolute Path" })
vim.keymap.set("n", "<leader>yn", clipboard.copy_filename_without_ext, { desc = "[P]Copy Filename (no ext)" })
vim.keymap.set("n", "<leader>yN", clipboard.copy_filename, { desc = "[P]Copy Filename" })
vim.keymap.set("n", "<leader>yr", clipboard.copy_relative_path, { desc = "[P]Copy Relative Path" })
vim.keymap.set("n", "<leader>yR", clipboard.copy_current_root_directory, { desc = "[P]Copy Current Root Directory" })
vim.keymap.set("n", "<leader>yd", clipboard.copy_current_directory, { desc = "[P]Copy Current Directory" })
-- Copy current file to system clipboard as Finder file object (macOS)
vim.keymap.set("n", "<leader>yy", function()
  local path = vim.api.nvim_buf_get_name(0)
  local safe_path = path:gsub([[\]], [[\\]]):gsub([["]], [[\"]])
  -- Build the osascript command to copy the file to the clipboard
  local result = vim.fn.system({
    "osascript",
    "-e",
    string.format([[tell application "Finder" to set the clipboard to (POSIX file "%s")]], safe_path),
  })
  if vim.v.shell_error ~= 0 then
    vim.notify("Copy failed: " .. result, vim.log.levels.ERROR)
  else
    vim.notify(vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
    vim.notify("Copied to system clipboard", vim.log.levels.INFO)
  end
end, { desc = "[P]Copy current file to clipboard" })

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

-- weekly note / troubleshooting note
vim.keymap.set("n", "<leader>ow", file.open_weekly_note, { desc = "[P]Open Weekly Note" })
vim.keymap.set("n", "<leader>ot", file.open_troubleshooting_note, { desc = "[P]Open Troubleshooting Note" })

-- dotfiles
vim.keymap.set("n", "<leader>oda", "<cmd>edit ~/.config/aerospace/aerospace.toml<cr>", { desc = "[P]Aerospace" })
vim.keymap.set("n", "<leader>odA", "<cmd>edit ~/.config/agents/AGENTS.md<cr>", { desc = "[P]AI Config" })
vim.keymap.set("n", "<leader>odc", "<cmd>edit ~/.claude-internal/settings.json<cr>", { desc = "[P]Claude" })
vim.keymap.set("n", "<leader>odb", "<cmd>edit ~/.codebuddy/settings.json<cr>", { desc = "[P]CodeBuddy" })
vim.keymap.set("n", "<leader>odf", "<cmd>edit ~/.config/fish/config.fish<cr>", { desc = "[P]Fish" })
vim.keymap.set("n", "<leader>odg", "<cmd>edit ~/.config/ghostty/config<cr>", { desc = "[P]Ghostty" })
vim.keymap.set("n", "<leader>odG", "<cmd>edit ~/.config/git/config<cr>", { desc = "[P]Git" })
vim.keymap.set("n", "<leader>odk", "<cmd>edit ~/.config/kitty/kitty.conf<cr>", { desc = "[P]Kitty" })
vim.keymap.set("n", "<leader>odK", "<cmd>edit ~/.config/karabiner/karabiner.json<cr>", { desc = "[P]Karabiner" })
vim.keymap.set(
  "n",
  "<leader>odm",
  "<cmd>edit ~/Library/Containers/net.sonuscape.mouseless/Data/.mouseless/configs/config.yaml<cr>",
  { desc = "[P]Mouseless" }
)
vim.keymap.set("n", "<leader>odn", "<cmd>edit ~/.config/nvim/init.lua<cr>", { desc = "[P]Neovim" })
vim.keymap.set("n", "<leader>ods", "<cmd>edit ~/.config/sketchybar/sketchybarrc<cr>", { desc = "[P]Sketchybar" })
vim.keymap.set("n", "<leader>odt", "<cmd>edit ~/.config/tmux/tmux.conf.local<cr>", { desc = "[P]Tmux" })
vim.keymap.set("n", "<leader>odw", "<cmd>edit ~/.config/wezterm/wezterm.lua<cr>", { desc = "[P]Wezterm" })
vim.keymap.set("n", "<leader>odz", "<cmd>edit ~/.config/zellij/config.kdl<cr>", { desc = "[P]Zellij" })

-- rename file with iwiki.json sync
vim.keymap.set("n", "<leader>rn", file.rename, { desc = "[P]Rename current filename" })

-- Auto-yank visual selection to the system clipboard on mouse release
-- NOTE: This requires Neovim to receive mouse events (so `mouse` must include visual mode)
-- NOTE: LazyVim already enables `opt.mouse = "a"` (mouse mode), so we don't set it here
-- https://stackoverflow.com/questions/79585797/how-to-copy-on-mouse-selection-in-neovim
vim.keymap.set("v", "<LeftRelease>", [["+ygv]], { silent = true, desc = "[P]Mouse select -> yank to system clipboard" })
vim.keymap.set(
  "v",
  "<2-LeftRelease>",
  [["+ygv]],
  { silent = true, desc = "[P]Mouse select (double) -> yank to system clipboard" }
)
