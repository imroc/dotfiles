return {
  "nvzone/floaterm",
  dependencies = "nvzone/volt",
  opts = {},
  cmd = "FloatermToggle",
  keys = {
    {
      "<C-;>",
      "<cmd>FloatermToggle<cr>",
      mode = { "n", "v", "i", "t" },
      desc = "[P] Toggle Floaterm",
    },
    {
      "<C-t>",
      "<cmd>FloatermToggle<cr>",
      mode = { "n", "v", "t" },
      desc = "[P] Toggle Floaterm",
    },
  },
}
