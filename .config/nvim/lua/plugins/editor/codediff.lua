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
    -- yadm keymaps：触发 codediff lazy load 并打开 yadm diff
    {
      "<leader>yud",
      function()
        require("util.yadm").open_codediff("public")()
      end,
      desc = "[P]Yadm diff (public)",
    },
    {
      "<leader>yid",
      function()
        require("util.yadm").open_codediff("private")()
      end,
      desc = "[P]Yadm diff (private)",
    },
  },
  opts = {
    diff = {
      layout = "inline",
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
    keymaps = {
      view = {
        next_hunk = "<C-]>",
        prev_hunk = "<C-[>",
      },
    },
  },
  config = function(_, opts)
    require("codediff").setup(opts)

    -- explorer 模式下自动隐藏文件列表面板（history 模式保留 commit 列表）
    -- CodeDiff 打开时自动最大化 cmux pane（多 pane 且未最大化时）
    vim.api.nvim_create_autocmd("User", {
      pattern = "CodeDiffOpen",
      callback = function(ev)
        -- require("util.cmux").zoom_if_split()
        local mode = ev.data and ev.data.mode
        if mode ~= "explorer" then
          return
        end
        local tabpage = ev.data.tabpage or vim.api.nvim_get_current_tabpage()
        local lifecycle = require("codediff.ui.lifecycle")

        -- 等 diff 渲染完成后再隐藏 explorer 并聚焦 modified 窗口第一个变更。
        -- 不能立即隐藏 explorer，因为 initial file selection 的 vim.schedule
        -- 回调依赖 explorer 窗口有效性来完成文件加载流程。
        local attempts = 0
        local function wait_and_focus()
          attempts = attempts + 1
          local tp = vim.api.nvim_get_current_tabpage()
          if tp ~= tabpage then
            return -- tab 已切换，放弃
          end
          local session = lifecycle.get_session(tp)
          if session and session.stored_diff_result then
            -- diff 渲染完成，隐藏 explorer
            local explorer_obj = lifecycle.get_explorer(tp)
            if
              explorer_obj
              and not explorer_obj.is_hidden
              and explorer_obj.split
              and explorer_obj.split.winid
              and vim.api.nvim_win_is_valid(explorer_obj.split.winid)
            then
              require("codediff.ui.explorer").toggle_visibility(explorer_obj)
            end
            -- 聚焦 modified 窗口第一个变更
            local _, modified_win = lifecycle.get_windows(tp)
            if modified_win and vim.api.nvim_win_is_valid(modified_win) then
              vim.api.nvim_set_current_win(modified_win)
              pcall(require("codediff").next_hunk)
            end
          elseif attempts < 50 then
            vim.defer_fn(wait_and_focus, 100)
          end
        end
        vim.defer_fn(wait_and_focus, 200)
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

        -- L 查看 commit 完整 message（浮动窗口，与上游 roadmap #267 #5 对齐）
        vim.keymap.set("n", "L", function()
          local lifecycle = require("codediff.ui.lifecycle")
          local tabpage = vim.api.nvim_get_current_tabpage()
          -- history_obj 存储在 explorer slot 中
          local history_obj = lifecycle.get_explorer(tabpage)
          if not history_obj or not history_obj.tree then
            return
          end
          local node = history_obj.tree:get_node()
          if not node or not node.data then
            return
          end
          -- 支持 commit 节点和 file 节点（取其 commit_hash）
          local hash = (node.data.type == "commit") and node.data.hash or node.data.commit_hash
          if not hash then
            return
          end
          local git_root = node.data.git_root or history_obj.git_root
          local result = vim.fn.systemlist({ "git", "-C", git_root, "log", "-1", "--format=%B", hash })
          if vim.v.shell_error ~= 0 or #result == 0 then
            return
          end
          -- 去除末尾空行
          while #result > 0 and result[#result] == "" do
            table.remove(result)
          end
          vim.lsp.util.open_floating_preview(result, "markdown", {
            border = "rounded",
            max_width = 80,
            max_height = 20,
            focus_id = "codediff_commit_msg",
          })
        end, { buffer = ev.buf, desc = "[P]Show full commit message" })
      end,
    })
  end,
}
