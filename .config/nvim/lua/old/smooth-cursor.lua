return {
  "gen740/SmoothCursor.nvim",
  config = function()
    require("smoothcursor").setup({
      cursor = "👉",
      type = "exp",
      fancy = {
        enable = false,
        head = { cursor = "👉" },
      },
    })
  end,
}
