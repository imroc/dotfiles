return {
  "nvzone/floaterm",
  dependencies = "nvzone/volt",
  opts = {},
  cmd = "FloatermToggle",
  keys = {
    {
      "<C-t>",
      "<cmd>FloatermToggle<cr>",
      mode = { "n", "v", "t" },
      desc = "[P] Toggle Floaterm",
    },
  },
}
