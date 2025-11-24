return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      preset = "default",
      ["<M-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-k>"] = { "select_prev" },
      ["<C-j>"] = { "select_next" },
    },
  },
}
