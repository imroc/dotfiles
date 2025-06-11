local resize_width = 8
local resize_height = 8

return {
  "pogyomo/winresize.nvim",
  keys = {
    {
      "<M-k>",
      function()
        require("winresize").resize(0, resize_height, "up")
      end,
    },
    {
      "<M-j>",
      function()
        require("winresize").resize(0, resize_height, "down")
      end,
    },
    {
      "<M-h>",
      function()
        require("winresize").resize(0, resize_width, "left")
      end,
    },
    {
      "<M-l>",
      function()
        require("winresize").resize(0, resize_width, "right")
      end,
    },
  },
}
