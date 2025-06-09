local outline = require("util.outline")
local conform = require("util.conform")

-- jump methond
vim.keymap.set({ "n", "v" }, "gm", outline.goto_location, { desc = "[P]goto method name" })
vim.keymap.set({ "n", "v" }, "gM", function()
  outline.goto_location()
  Snacks.picker.lsp_references()
end, { desc = "[P]method references" })

-- format and save
vim.keymap.set(
  { "n", "v", "i" },
  "<leader>;",
  conform.format_and_save_async,
  { desc = "[P]Format and Save file asynchronously" }
)
