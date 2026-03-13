---@diagnostic disable: undefined-global

-- if vim.g.simpler_scrollback == "deeznuts" then
--   -- yank and quit when using my scrollback config
--   vim.keymap.set({ "n", "v" }, "y", [["+y<cmd>q!<cr>]], { desc = "[P]Yank to system clipboard + Quit" })
--   -- vim.keymap.set({ "n", "v" }, "q", "<cmd>q!<cr>", { desc = "[P]Quit" })
-- end

-- quit
vim.keymap.set({ "n", "v" }, "<leader>.", "<cmd>qa<cr>", { desc = "[P]Quit all" })
vim.keymap.set({ "n", "v" }, "<leader>X", "<cmd>qa!<cr>", { desc = "[P]Quit all without save" })
vim.keymap.set({ "n" }, "go", "<cmd>qa!<cr>", { desc = "[P]Quit all without save" })
vim.keymap.set({ "n", "v", "i" }, "<C-q>", "<cmd>wq<cr>", { desc = "[P]Save and quit current window" })

-- esc
vim.keymap.set("i", "kj", "<Esc>")

-- select / copy
vim.keymap.set("n", "<C-c>", "ggVGy", { desc = "[P]Copy All" })
vim.keymap.set("n", "<M-C-a>", "ggVG", { desc = "[P]Select All" })
vim.keymap.set("v", "<C-c>", "y", { desc = "[P]Copy" })

-- convert tabs/spaces
vim.keymap.set("n", "<leader>ct", "<cmd>%s/\t/  /g<cr>", { desc = "[P]Convert tab to 2 spaces" })
vim.keymap.set("n", "<leader>cT", "<cmd>%s/  /\t/g<cr>", { desc = "[P]Convert 2 spaces to a tab" })

-- open quick note
local picker = require("util.picker")
local buffer = require("util.buffer")
vim.keymap.set("n", "<leader>oo", function()
  vim.fn.system("open '" .. buffer.absolute_path() .. "'")
end, { desc = "[P]Open current file with system" })
vim.keymap.set("v", "<leader>oo", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  vim.schedule(function()
    local start_pos = vim.api.nvim_buf_get_mark(0, "<")
    local end_pos = vim.api.nvim_buf_get_mark(0, ">")
    local lines = vim.api.nvim_buf_get_text(0, start_pos[1] - 1, start_pos[2], end_pos[1] - 1, end_pos[2] + 1, {})
    local text = vim.fn.trim(table.concat(lines, "\n"))
    if text ~= "" then
      vim.fn.system("open '" .. text .. "'")
    end
  end)
end, { desc = "[P]Open selected text with system" })
vim.keymap.set("n", "<leader>on", function()
  picker.files({ cwd = vim.fn.expand("$HOME/dev/note") })
end, { desc = "[P]Open Note" })

vim.keymap.set("n", "<C-]>", "]c", { desc = "[P]Next change", noremap = true, silent = true })
vim.keymap.set("n", "<C-[>", "[c", { desc = "[P]Previous change", noremap = true, silent = true })

-- yank AI reference
local clipboard = require("util.clipboard")
vim.keymap.set("n", "<leader>ya", function()
  clipboard.copy_ai_ref_text(false)
end, { desc = "[P]Yank file ref to clipboard" })
vim.keymap.set("v", "<leader>ya", function()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
  vim.schedule(function()
    clipboard.copy_ai_ref_text(true)
  end)
end, { desc = "[P]Yank selection ref to clipboard" })

-- toggle cursor column
Snacks.toggle.option("cursorcolumn", { name = "Cursor Column" }):map("<leader>ux")

-- scroll
local scroll_percentage = 0.35 -- Scroll by 35% of the window height and keep the cursor centered
-- Scroll by a percentage of the window height and keep the cursor centered
vim.keymap.set("n", "<C-d>", function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
  vim.cmd("normal! " .. lines .. "jzz")
end, { noremap = true, silent = true })
vim.keymap.set("n", "<C-u>", function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) * scroll_percentage)
  vim.cmd("normal! " .. lines .. "kzz")
end, { noremap = true, silent = true })
