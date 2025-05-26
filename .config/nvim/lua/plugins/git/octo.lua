return {
  "pwntester/octo.nvim",
  keys = {
    { "<leader>gHa", "<Cmd>Octo actions<CR>", desc = "[P]Actions" },
    { "<leader>gHi", "<cmd>Octo issue list<CR>", desc = "[P]List Issues (Octo)" },
    { "<leader>gHI", "<cmd>Octo issue search<CR>", desc = "[P]Search Issues (Octo)" },
    { "<leader>gHp", "<cmd>Octo pr list<CR>", desc = "[P]List PRs (Octo)" },
    { "<leader>gHP", "<cmd>Octo pr search<CR>", desc = "[P]Search PRs (Octo)" },
    { "<leader>gHr", "<cmd>Octo repo list<CR>", desc = "[P]List Repos (Octo)" },
    { "<leader>gHs", "<cmd>Octo search<CR>", desc = "[P]Search (Octo)" },
    -- 禁用 <leader>g 开头的快捷键，避免冲突
    { "<leader>gi", false },
    { "<leader>gI", false },
    { "<leader>gp", false },
    { "<leader>gP", false },
    { "<leader>gr", false },
    { "<leader>gS", false },
  },
}
