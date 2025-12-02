return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<localleader>", "<cmd>WhichKey <localleader><cr>" },
        { "<localleader>h", group = "git hunk" },
        { "<leader>t", group = "toggle/todo" },
        { "<leader>y", group = "yazi/yadm/yank" },
        { "<leader>k", group = "kube" },
        { "<leader>o", group = "open" },
        { "<leader>og", group = "git repo" },
        { "<leader>ka", group = "kubectl apply" },
        { "<leader>kd", group = "kubectl delete" },
        { "<leader>gH", group = "github" },
        { "<leader>gy", group = "copy url" },
        { "<localleader>i", group = "insert", ft = "markdown" },
      },
    },
  },
}
