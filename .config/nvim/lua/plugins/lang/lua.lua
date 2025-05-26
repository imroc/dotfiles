return {
  {
    "folke/lazydev.nvim",
    opts = {
      library = {
        { path = "wezterm-types", mods = { "wezterm" } },
      },
    },
  },
  {
    "justinsgithub/wezterm-types",
    lazy = true,
  },
}
