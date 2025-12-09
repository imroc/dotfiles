-- https://github.com/arnamak/stay-centered.nvim
local loaded = false
return {
  "arnamak/stay-centered.nvim",
  lazy = true,
  enabled = vim.g.simpler_scrollback ~= "deeznuts",
  keys = {
    {
      "<leader>u-",
      function()
        local result = ""
        if not loaded then
          loaded = true
          result = "Enabled"
        else
          local sc = require("stay-centered")
          sc.toggle()
          if sc.cfg.enabled then
            result = "Enabled"
          else
            result = "Disabled"
          end
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
