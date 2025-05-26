return {
  "TobinPalmer/pastify.nvim",
  cmd = { "Pastify" },
  keys = {
    { "<localleader>I", "<cmd>Pastify<CR>", ft = "markdown", desc = "[P]Insert Picture (Paste Local with Pastify)" },
  },
  config = function()
    require("pastify").setup({
      opts = {
        absolute_path = false,
        local_path = "/assets/imgs/",
        save = "local",
      },
    })
  end,
}
