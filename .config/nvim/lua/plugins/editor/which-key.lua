return {
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<localleader>", "<cmd>WhichKey <localleader><cr>" },
        { "<localleader>h", group = "git hunk" },
        { "<leader>y", group = "yazi/yadm/yank" },
        { "<leader>k", group = "kube" },
        { "<leader>r", group = "replace/rename" },
        { "<leader>o", group = "open" },
        { "<leader>og", group = "git repo" },
        { "<leader>ka", group = "kubectl apply" },
        { "<leader>kd", group = "kubectl delete" },
        { "<leader>gH", group = "github" },
        { "<leader>gy", group = "copy url" },
      },
    },
  },
}
