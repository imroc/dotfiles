local git = require("util.git")

-- gitsigns
-- vim.keymap.set("n", "<leader>gD", git.toggle_git_diff, { desc = "[P]Toggle Git Signs Diff" })

-- tig
vim.keymap.set("n", "<leader>gT", git.open_tig_root_dir, { desc = "Tig (root dir)" })

-- next/pre change
vim.keymap.set("n", "<C-M-n>", "]c", { desc = "[P]Next Change" })
vim.keymap.set("n", "<C-M-p>", "[c", { desc = "[P]Previous Change" })

-- git push
vim.keymap.set("n", "<leader>gp", git.git_push, { desc = "[P]Git Push" })
vim.keymap.set("n", "<leader>gi", git.git_commit_and_push, { desc = "[P]Git Commit and Push" })
vim.keymap.set("n", "<leader>ga", git.git_add_all, { desc = "[P]Git Add" })
vim.keymap.set("n", "<leader>gA", git.git_commit_amend, { desc = "[P]Git Amend" })

-- lazygit
if vim.fn.executable("lazygit") == 1 then
  vim.keymap.set({ "n", "i", "t", "v" }, "<C-g>", function()
    Snacks.lazygit({ cwd = LazyVim.root.git() })
  end, { desc = "Lazygit (Root Dir)" })
end
