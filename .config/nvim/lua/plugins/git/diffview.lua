return {
  {
    "sindrets/diffview.nvim",
    lazy = true,
    config = function()
      local actions = require("diffview.actions")
      require("diffview").setup({
        enhanced_diff_hl = true,
        view = {
          merge_tool = {
            layout = "diff3_mixed",
          },
        },
        default_args = {
          DiffviewOpen = { "--imply-local" },
        },
        hooks = {
          diff_buf_win_enter = function()
            -- 每次 diff 都要展开所有折叠(包含重新打开相同 diff）
            vim.opt_local.foldenable = false
            -- 某个 diff 第一次打开时光标定位到第一个 change 的位置
            -- vim.api.nvim_input("gg]czz")
          end,
        },
        keymaps = {
          file_history_panel = {
            {
              "n",
              "<cr>",
              actions.focus_entry,
              { desc = "[P]Open diff and focus on the first change for the selected entry." },
            },
            {
              "n",
              "o",
              actions.focus_entry,
              { desc = "[P]Open diff and focus on the first change for the selected entry." },
            },
            {
              "n",
              "l",
              actions.focus_entry,
              { desc = "[P]Open diff and focus on the first change for the selected entry." },
            },
            {
              "n",
              "<2-LeftMouse>",
              actions.focus_entry,
              { desc = "[P]Open diff and focus on the first change for the selected entry." },
            },
          },
          file_panel = {
            {
              "n",
              "cc",
              "<Cmd>Git commit <bar> wincmd J<CR>",
              { desc = "[P]Commit staged changes" },
            },
            {
              "n",
              "ca",
              "<Cmd>Git commit --amend <bar> wincmd J<CR>",
              { desc = "[P]Amend the last commit" },
            },
            {
              "n",
              "c<space>",
              function()
                vim.ui.input({ prompt = "Commit message: " }, function(msg)
                  if not msg then
                    return
                  end
                  local results = vim.system({ "git", "commit", "-m", msg }, { text = true }):wait()

                  if results.code ~= 0 then
                    vim.notify(
                      "Commit failed with the message: \n" .. vim.trim(results.stdout .. "\n" .. results.stderr),
                      vim.log.levels.ERROR,
                      { title = "Commit" }
                    )
                  else
                    vim.notify(results.stdout, vim.log.levels.INFO, { title = "Commit" })
                  end
                end)
              end,
              { desc = "[P]Commit with one line message" },
            },
            {
              "n",
              "<cr>",
              actions.focus_entry,
              { desc = "[P]Open diff and focus on the first change for the selected entry." },
            },
            {
              "n",
              "o",
              actions.focus_entry,
              { desc = "[P]Open diff and focus on the first change for the selected entry." },
            },
            {
              "n",
              "l",
              actions.focus_entry,
              { desc = "[P]Open diff and focus on the first change for the selected entry." },
            },
            {
              "n",
              "<2-LeftMouse>",
              actions.focus_entry,
              { desc = "[P]Open diff and focus on the first change for the selected entry." },
            },
          },
        },
      })
    end,
    cmd = {
      "DiffviewFileHistory",
      "DiffviewOpen",
      "DiffviewClose",
    },
    keys = {
      {
        "<leader>gr",
        "<cmd>DiffviewOpen origin/HEAD...HEAD --imply-local<CR>",
        desc = "[P]Code Review (diff with origin/HEAD)",
      },
      {
        "<leader>gR",
        "<cmd>DiffviewFileHistory --range=origin/HEAD...HEAD --right-only --no-merges<CR>",
        desc = "[P]Code Review (commit history after origin/HEAD)",
      },
      -- { "gh", "<cmd>DiffviewFileHistory --no-merges<CR>", desc = "Git History" },
      {
        "<leader>gF",
        function()
          local find = coroutine.wrap(function()
            vim.ui.input({ prompt = "Search Git History: " }, function(input)
              if not input or input == "" then
                return
              end
              vim.cmd('DiffviewFileHistory --grep="' .. input .. '"')
            end)
          end)
          find()
        end,
        desc = "[P]Find Git History",
      },
      {
        "<leader>gD",
        function()
          local git_blame = require("gitblame")
          git_blame.get_sha(function(sha)
            vim.cmd("DiffviewOpen " .. sha .. "^!")
          end)
        end,
        desc = "[P]Diff Commit on Current Blame Line",
      },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<CR>", desc = "[P]Git History For Current File" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "[P]Git History" },
      {
        "<leader>gd",
        function()
          vim.cmd("DiffviewOpen")
          vim.cmd("DiffviewToggleFiles")
        end,
        desc = "[P]Git Diff",
      },
      {
        "<leader>yc",
        function()
          local yadm = require("util.yadm")
          yadm.set_git_env()
          vim.cmd("DiffviewOpen")
        end,
        desc = "[P]Yadm diff (git changes)",
      },
      { "<C-S-h>", "<cmd>DiffviewFileHistory<CR>", desc = "[P]Git History" },
    },
  },
}
