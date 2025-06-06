-- buffers
vim.keymap.set("n", "<leader>o", "<cmd>Outline<cr>", { desc = "[P]Toggle Outline" })
vim.keymap.set("n", "<leader>bu", "<cmd>UrlView<CR>", { desc = "[P]Urls in current buffer" })
vim.keymap.set("n", "<C-S-o>", "<cmd>e #<cr>", { desc = "[P]Switch to Other Buffer" })

-- tabs
vim.keymap.set("n", "<leader>'", "<cmd>tabclose<cr>", { desc = "[P]Close Tab" })
vim.keymap.set("n", "<C-S-n>", "<cmd>tabnew<cr>", { desc = "[P]New Tab" })

-- window
local function is_window_on_right()
  local win = vim.api.nvim_get_current_win()
  local col = vim.fn.win_screenpos(win)[2]
  local width = vim.api.nvim_win_get_width(win)
  local screen_width = vim.o.columns
  local right_pos = screen_width - col - width
  return right_pos <= 1
end
local function is_window_on_top()
  local win = vim.api.nvim_get_current_win()
  local row = vim.fn.win_screenpos(win)[1]
  return row <= 2
end
vim.keymap.set({ "n", "t" }, "<M-h>", function()
  -- 只有最右边的 window 才变宽，其它都变窄
  if is_window_on_right() then
    vim.cmd("vertical resize +5")
  else
    vim.cmd("vertical resize -5")
  end
end, { desc = "[P]Increase or Decrease window width" })
vim.keymap.set({ "n", "t" }, "<M-l>", function()
  -- 只有最右边的 window 才变窄，其它都变宽
  if is_window_on_right() then
    vim.cmd("vertical resize -5")
  else
    vim.cmd("vertical resize +5")
  end
end, { desc = "[P]Increase or Decrease window width" })
vim.keymap.set({ "n", "t" }, "<M-j>", function()
  -- 只有最上边的 window 才变高，其它都变矮
  if is_window_on_top() then
    vim.cmd("resize +5")
  else
    vim.cmd("resize -5")
  end
end, { desc = "[P]Increase or Decrease window height" })
vim.keymap.set({ "n", "t" }, "<M-k>", function()
  -- 只有最上边的 window 才变矮，其它都变高
  if is_window_on_top() then
    vim.cmd("resize -5")
  else
    vim.cmd("resize +5")
  end
end, { desc = "[P]Increase or Decrease window height" })
vim.keymap.set({ "n", "t" }, "<C-'>", "<cmd>close<cr>", { desc = "[P]Close Window" })
vim.keymap.set({ "n", "t" }, "<C-x>", "<cmd>close<cr>", { desc = "[P]Close Window" })
vim.keymap.set({ "n" }, "<C-_>", "<C-W>s", { desc = "[P]Split Window Below", remap = true })
vim.keymap.set({ "n" }, "<C-\\>", "<C-W>v", { desc = "[P]Split Window Right", remap = true })
vim.keymap.set({ "n", "t" }, "<leader>tw", function()
  local win = vim.api.nvim_get_current_win()
  local row = vim.fn.win_screenpos(win)[1]
  vim.notify("row:" .. row)
end, { desc = "[P]test window" })

-- format and save
vim.keymap.set(
  { "n", "v", "i" },
  "<leader>;",
  require("util.conform").format_and_save_async,
  { desc = "[P]Format and Save file asynchronously" }
)

-- quit
vim.keymap.set({ "n", "v" }, "<leader>z", "<cmd>qa<cr>", { desc = "[P]Quit all" })
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

vim.keymap.set("n", "<leader>td", "<cmd>e ~/dev/note/todo.md<cr>", { desc = "[P]Open Todo" })

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
vim.keymap.set({ "n", "v" }, "gm", outline.goto_location, { desc = "[P]goto method name" })
vim.keymap.set({ "n", "v" }, "gM", function()
  outline.goto_location()
  Snacks.picker.lsp_references()
end, { desc = "[P]method references" })
