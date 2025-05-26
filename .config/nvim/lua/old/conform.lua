return {
  "stevearc/conform.nvim",
  keys = {
    {
      "<M-f>",
      function()
        require("conform").format({
          async = true,
          quiet = true,
        })
      end,
      mode = { "n", "v", "i" },
      desc = "Format Code with Conform",
    },
  },
}
