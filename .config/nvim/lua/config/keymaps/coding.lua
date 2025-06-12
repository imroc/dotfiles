---@diagnostic disable: deprecated
---@diagnostic disable: undefined-field
---@diagnostic disable: undefined-global

local outline = require("util.outline")
local conform = require("util.conform")
local map = vim.keymap.set

-- jump methond
map({ "n", "v" }, "gm", outline.goto_location, { desc = "[P]goto method name" })
map({ "n", "v" }, "gM", function()
  outline.goto_location()
  Snacks.picker.lsp_references()
end, { desc = "[P]method references" })

-- format and save
map({ "n", "v", "i" }, "<leader>;", conform.format_and_save_async, { desc = "[P]Format and Save file asynchronously" })
map({ "n" }, "<leader>cv", function()
  local config = vim.diagnostic.config() or {}
  vim.notify(vim.inspect(config))
  vim.diagnostic.config({
    virtual_text = false,
  })
end, { desc = "[P]toggle virtual text" })

-- to compatible with tiny-inline-diagnostic.nvim: override diagnostic related keybindings to prevent open float popup
-- see https://github.com/rachartier/tiny-inline-diagnostic.nvim/issues/41#issuecomment-2496018944
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity, float = false })
  end
end
local map = vim.keymap.set
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "[P]Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "[P]Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })
