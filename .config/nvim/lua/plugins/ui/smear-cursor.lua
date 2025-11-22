return {
  "sphamba/smear-cursor.nvim",
  enabled = vim.env.KITTY_PID == nil and vim.g.neovide == nil,
  event = "VeryLazy",
  cmd = {
    "SmearCursorToggle",
  },
  keys = {
    {
      "<leader>tS",
      function()
        require("smear_cursor").toggle()
      end,
      desc = "[P]Toggle SmearCursor",
    },
  },
  opts = {
    -- 快速移动
    stiffness = 0.8, -- 0.6      [0, 1]
    trailing_stiffness = 0.5, -- 0.4      [0, 1]
    stiffness_insert_mode = 0.6, -- 0.4      [0, 1]
    trailing_stiffness_insert_mode = 0.6, -- 0.4      [0, 1]
    distance_stop_animating = 0.5, -- 0.1      > 0
    time_interval = 7, -- milliseconds

    -- 火焰特效
    cursor_color = "#ff8800",
    trailing_exponent = 5,
    never_draw_over_target = true,
    hide_target_hack = true,
    gamma = 1,
  },
}
