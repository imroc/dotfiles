return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<localleader>", "<cmd>WhichKey <localleader><cr>" },
        { "<localleader>h", group = "[P]git hunk" },
        { "<leader>t", group = "toggle/todo" },
        { "<leader>y", group = "yazi/yadm/yank" },
        { "<leader>k", group = "kube" },
        { "<leader>o", group = "open" },
        { "<leader>ka", group = "kubectl apply" },
        { "<leader>kd", group = "kubectl delete" },
        { "<leader>gH", group = "github" },
        { "<leader>gO", group = "open in browser" },
        { "<leader>gy", group = "copy url" },
      },
    },
  },
}
