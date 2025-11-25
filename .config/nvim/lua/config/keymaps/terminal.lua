-- open terminal
vim.keymap.set("n", "gt", function()
  require("util.term").toggle(require("util.buffer").current_dir())
end, { desc = "[P]Terminal (current file dir)" })
vim.keymap.set("n", "gT", function()
  require("util.term").toggle(require("util.buffer").root_dir())
end, { desc = "[P]Terminal (root dir)" })

-- open zellij
vim.keymap.set("n", "gz", function()
  require("util.zellij").open_float(require("util.buffer").current_dir)
end, { desc = "[P]Open Zellij Floating Terminal (currrent dir)" })
vim.keymap.set("n", "gZ", function()
  require("util.zellij").open_float(require("util.buffer").root_dir)
end, { desc = "[P]Open Zellij Floating Terminal (root dir)" })

-- page up/down in terminal
vim.keymap.set("t", "<C-u>", "<C-\\><C-n><C-u>", { noremap = true })
vim.keymap.set("t", "<C-d>", "<C-\\><C-n><C-d>", { noremap = true })
