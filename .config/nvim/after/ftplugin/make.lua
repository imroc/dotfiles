vim.opt_local.expandtab = false
vim.defer_fn(function()
  vim.opt_local.tabstop = 2 -- Number of spaces tabs count for
end, 100)

local make = require("util.make")

-- run in zellij
vim.keymap.set("n", "<localleader>r", function()
  make.run_in_terminal_or_zellij(false)
end, { buffer = 0, desc = "[P]Run in Terminal or Zellij" })
vim.keymap.set("n", "<localleader>R", function()
  make.run_in_terminal_or_zellij(true)
end, { buffer = 0, desc = "[P]Run in Terminal or Zellij (Close on Exit)" })

-- run in background
vim.keymap.set("n", "<localleader>b", function()
  make.run_in_background()
end, { buffer = 0, desc = "[P]Run in Background" })

-- run in terminal
vim.keymap.set("n", "<localleader>t", function()
  make.run_in_terminal(false)
end, { buffer = 0, desc = "[P]Run in Terminal" })
vim.keymap.set("n", "<localleader>T", function()
  make.run_in_terminal(true)
end, { buffer = 0, desc = "[P]Run in Terminal (Close on Exit)" })

-- run in zellij
vim.keymap.set("n", "<localleader>z", function()
  make.run_in_zellij(false)
end, { buffer = 0, desc = "[P]Run in Zellij" })
vim.keymap.set("n", "<localleader>Z", function()
  make.run_in_zellij(true)
end, { buffer = 0, desc = "[P]Run in Zellij (Close on Exit)" })
