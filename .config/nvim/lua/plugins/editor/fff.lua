return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    -- downloads a prebuilt binary or falls back to cargo build
    require("fff.download").download_or_build_binary()
  end,
  opts = {
    debug = {
      enabled = true,
      show_scores = true,
    },
    keymaps = {
      move_up = { "<Up>", "<C-p>", "<C-k>" },
      move_down = { "<Down>", "<C-n>", "<C-j>" },
      send_to_quickfix = "<C-t>",
    },
    layout = {
      prompt_position = "top",
      height = 1,
      width = 1,
      flex = false,
    },
  },
  keys = {
    {
      "ff",
      function()
        require("fff").find_files()
      end,
      desc = "FFFind files",
    },
    {
      "fg",
      function()
        require("fff").live_grep()
      end,
      desc = "LiFFFe grep",
    },
    {
      "fz",
      function()
        require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
      end,
      desc = "Live fffuzy grep",
    },
    {
      "fc",
      function()
        require("fff").live_grep({ query = vim.fn.expand("<cword>") })
      end,
      desc = "Search current word",
    },
    {
      "<leader><space>",
      function()
        require("fff").find_files({ cwd = LazyVim.root() })
      end,
      desc = "[P]FFF Find Files (Root Dir)",
    },
    {
      "<leader>/",
      function()
        require("fff").live_grep({ cwd = LazyVim.root() })
      end,
      desc = "[P]FFF Grep (Root Dir)",
    },
  },
}
