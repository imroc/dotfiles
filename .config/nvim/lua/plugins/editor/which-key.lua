return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<localleader>", "<cmd>WhichKey <localleader><cr>" },
        { "<localleader>h", group = "[P]git hunk" },
        { "<leader>t", group = "toggle" },
        { "<leader>y", group = "yazi" },
        { "<leader>p", group = "file path" },
        { "<leader>k", group = "kube" },
        { "<leader>ka", group = "kubectl apply" },
        { "<leader>kd", group = "kubectl delete" },
        { "<leader>a", group = "avante" },
        { "<leader>gH", group = "github" },
        { "<leader>gO", group = "open in browser" },
        { "<leader>gy", group = "copy url" },
      },
    },
  },
}
