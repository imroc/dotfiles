-- debug
-- vim.keymap.set("n", "<M-S-j>", ":lua require'dap'.step_over()<CR>", { desc = "[P]Step Over (Dap)" })
-- vim.keymap.set("n", "<M-S-k>", ":lua require'dap'.continue()<CR>", { desc = "[P]Continue (Dap)" })
-- vim.keymap.set("n", "<M-S-h>", ":lua require'dap'.step_out()<CR>", { desc = "[P]Step Out (Dap)" })
-- vim.keymap.set("n", "<M-S-l>", ":lua require'dap'.step_into()<CR>", { desc = "[P]Step Into (Dap)" })

-- lsp
-- vim.keymap.set("n", "gR", function()
--   require("trouble").open("lsp_references")
-- end, { desc = "[P]References (Trouble)" })

-- lint
vim.keymap.set("n", "gl", vim.diagnostic.open_float, { desc = "[P]Line Diagnostics" })
