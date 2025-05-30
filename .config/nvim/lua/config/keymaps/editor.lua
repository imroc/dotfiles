-- buffers
vim.keymap.set("n", "<leader>o", "<cmd>Outline<cr>", { desc = "[P]Toggle Outline" })
vim.keymap.set("n", "<leader>bu", "<cmd>UrlView<CR>", { desc = "[P]Urls in current buffer" })
vim.keymap.set("n", "<C-S-o>", "<cmd>e #<cr>", { desc = "[P]Switch to Other Buffer" })

-- tabs
vim.keymap.set("n", "<leader>'", "<cmd>tabclose<cr>", { desc = "[P]Close Tab" })
vim.keymap.set("n", "<C-S-n>", "<cmd>tabnew<cr>", { desc = "[P]New Tab" })

-- window
vim.keymap.set({ "n", "t" }, "<M-k>", "<cmd>resize +5<cr>", { desc = "[P]Increase window height" })
vim.keymap.set({ "n", "t" }, "<M-j>", "<cmd>resize -5<cr>", { desc = "[P]Decrease window height" })
vim.keymap.set({ "n", "t" }, "<M-l>", "<cmd>vertical resize +5<cr>", { desc = "[P]Increase window width" })
vim.keymap.set({ "n", "t" }, "<M-h>", "<cmd>vertical resize -5<cr>", { desc = "[P]Decrease window width" })
vim.keymap.set("n", "<leader>0", "<cmd>close<cr>", { desc = "[P]Close Window", remap = true })
vim.keymap.set({ "n", "i" }, "<C-'>", "<cmd>close<cr>", { desc = "[P]Close Window", remap = true })

-- format and save
vim.keymap.set(
  { "n", "v", "i" },
  "<leader>;",
  require("util.conform").format_and_save_async,
  { desc = "[P]Format and Save file asynchronously" }
)

-- quit
vim.keymap.set({ "n", "v" }, "<leader>.", "<cmd>qa<cr>", { desc = "[P]Quit all" })
vim.keymap.set({ "n", "v" }, "<leader>X", "<cmd>qa!<cr>", { desc = "[P]Quit all without save" })
vim.keymap.set({ "n", "v" }, "go", "<cmd>qa!<cr>", { desc = "[P]Quit all without save" })
vim.keymap.set({ "n", "v", "i" }, "<C-q>", "<cmd>wq<cr>", { desc = "[P]Save and quit current window" })

vim.keymap.set("i", "kj", "<Esc>")
vim.keymap.set("n", "<C-c>", "ggVGy", { desc = "[P]Copy All" })
vim.keymap.set("n", "<M-C-a>", "ggVG", { desc = "[P]Select All" })

vim.keymap.set("v", "<C-c>", "y", { desc = "[P]Copy" })

vim.keymap.set("n", "<leader>ct", "<cmd>%s/\t/  /g<cr>", { desc = "[P]Convert tab to 2 spaces" })
vim.keymap.set("n", "<leader>cT", "<cmd>%s/  /\t/g<cr>", { desc = "[P]Convert 2 spaces to a tab" })

local window = require("util.window")
vim.keymap.set("n", "<leader>j", window.clear, { desc = "[P]Clear all other windows" })

vim.keymap.set("n", "<C-t>", "<cmd>e ~/dev/note/todo.md<cr>")

-- Scroll by 35% of the window height and keep the cursor centered
local scroll_percentage = 0.35
-- Scroll by a percentage of the window height and keep the cursor centered
vim.keymap.set("n", "<C-d>", function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
  vim.cmd("normal! " .. lines .. "jzz")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
  vim.cmd("normal! " .. lines .. "kzz")
end, { noremap = true, silent = true })

local outline = require("util.outline")
vim.keymap.set("n", "gn", outline.goto_localtion, { desc = "[P]goto method name" })
