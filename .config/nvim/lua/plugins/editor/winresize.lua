local resize_width = 8
local resize_height = 8

return {
  "pogyomo/winresize.nvim",
  keys = {
    {
      "<M-k>",
      mode = { "n", "t" },
      function()
        require("winresize").resize(0, resize_height, "up")
      end,
    },
    {
      "<M-j>",
      mode = { "n", "t" },
      function()
        require("winresize").resize(0, resize_height, "down")
      end,
    },
    {
      "<M-h>",
      mode = { "n", "t" },
      function()
        require("winresize").resize(0, resize_width, "left")
      end,
    },
    {
      "<M-l>",
      mode = { "n", "t" },
      function()
        require("winresize").resize(0, resize_width, "right")
      end,
    },
  },
}
