-- https://github.com/arnamak/stay-centered.nvim
local loaded = false
return {
  "arnamak/stay-centered.nvim",
  lazy = true,
  keys = {
    {
      "<leader>ts",
      function()
        if not loaded then
          loaded = true
          return
        end
        local sc = require("stay-centered")
        sc.toggle()
        local result = ""
        if sc.cfg.enabled then
          result = "Enabled"
        else
          result = "Disabled"
        end
        vim.notify("Stay Center " .. result, vim.log.levels.INFO)
      end,
      desc = "[P]Toggle Stay Centered",
    },
  },
  config = function()
    require("stay-centered").setup({})
  end,
}
