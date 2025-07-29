return {
  "neovim/nvim-lspconfig",
  opts = function()
    -- diable <M-n> and <M-p> (avoid conflict with next/prev change)
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    keys[#keys + 1] = { "<a-n>", false }
    keys[#keys + 1] = { "<a-p>", false }
  end,
}
