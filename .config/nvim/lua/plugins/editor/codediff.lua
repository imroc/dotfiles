return {
  "esmuellert/codediff.nvim",
  cmd = "CodeDiff",
  keys = {
    { "<leader>gd", "<cmd>CodeDiff<CR>", desc = "[P]Git Diff" },
    { "<leader>gr", "<cmd>CodeDiff origin/HEAD...<CR>", desc = "[P]Code Review (diff with origin/HEAD)" },
    { "<leader>gf", "<cmd>CodeDiff history %<CR>", desc = "[P]Git History For Current File" },
    { "<leader>gh", "<cmd>CodeDiff history<CR>", desc = "[P]Git History" },
    {
      "<leader>gD",
      function()
        local git_blame = require("gitblame")
        git_blame.get_sha(function(sha)
          vim.cmd("CodeDiff " .. sha .. "^ " .. sha)
        end)
      end,
      desc = "[P]Diff Commit on Current Blame Line",
    },
    { "<C-S-h>", "<cmd>CodeDiff history<CR>", desc = "[P]Git History" },
  },
  config = function()
    require("codediff").setup({
      diff = {
        layout = "side-by-side",
        ignore_trim_whitespace = false,
        jump_to_first_change = true,
        cycle_next_hunk = false,
      },
      explorer = {
        initial_focus = "modified",
        view_mode = "tree",
      },
      history = {
        initial_focus = "history",
      },
    })

    -- explorer 模式下自动隐藏文件列表面板（history 模式保留 commit 列表）
    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeDiffOpen",
      callback = function(ev)
        local mode = ev.data and ev.data.mode
        if mode ~= "explorer" then
          return
        end
        local tabpage = ev.data.tabpage or vim.api.nvim_get_current_tabpage()
        local lifecycle = require("codediff.ui.lifecycle")
        local explorer_obj = lifecycle.get_explorer(tabpage)
        if explorer_obj and explorer_obj.split and explorer_obj.split.winid and vim.api.nvim_win_is_valid(explorer_obj.split.winid) then
          require("codediff.ui.explorer").toggle_visibility(explorer_obj)
        end
      end,
    })

    -- history 面板：o/l/<CR> 选中后自动聚焦 diff 区域第一个 change
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "codediff-history",
      callback = function(ev)
        local function focus_first_change()
          vim.defer_fn(function()
            local lifecycle = require("codediff.ui.lifecycle")
            local tabpage = vim.api.nvim_get_current_tabpage()
            local _, modified_win = lifecycle.get_windows(tabpage)
            if modified_win and vim.api.nvim_win_is_valid(modified_win) then
              vim.api.nvim_set_current_win(modified_win)
              vim.cmd("normal! gg")
              -- 等 diff 计算完成后再跳转到第一个 hunk
              vim.defer_fn(function()
                require("codediff").next_hunk()
              end, 100)
            end
          end, 200)
        end

        -- 映射 o/l 为 "select + focus"（模仿 diffview 的 focus_entry）
        for _, key in ipairs({ "o", "l" }) do
          vim.keymap.set("n", key, function()
            -- 触发 codediff 内部的 <CR> select 逻辑
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "m", false)
            focus_first_change()
          end, { buffer = ev.buf, desc = "[P]Select and focus diff" })
        end
      end,
    })
  end,
}
