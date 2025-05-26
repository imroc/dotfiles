return {
  "lewis6991/gitsigns.nvim",
  keys = {
    {
      "<leader>tg",
      function()
        local gs = package.loaded.gitsigns
        gs.toggle_deleted()
        gs.toggle_numhl()
        gs.toggle_linehl()
        gs.toggle_word_diff()
      end,
      desc = "[P]Toggle All GitSigns",
    },
  },
  opts = {
    -- 拷贝自 LazyVim 的 lua/lazyvim/plugins/editor.lua，做了调整：注释掉 <leader>gh 开头的快捷键
    on_attach = function(buffer)
      local gs = package.loaded.gitsigns

      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
      end

      -- stylua: ignore start
      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next Hunk")
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Prev Hunk")
      map("n", "]H", function() gs.nav_hunk("last") end, "Last Hunk")
      map("n", "[H", function() gs.nav_hunk("first") end, "First Hunk")
      map({ "n", "v" }, "ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
      map({ "n", "v" }, "ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      map("n", "ghS", gs.stage_buffer, "Stage Buffer")
      map("n", "ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
      map("n", "ghR", gs.reset_buffer, "Reset Buffer")
      map("n", "ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
      map("n", "ghb", function() gs.blame_line({ full = true }) end, "Blame Line")
      map("n", "ghB", function() gs.blame() end, "Blame Buffer")
      map("n", "ghd", gs.diffthis, "Diff This")
      map("n", "ghD", function() gs.diffthis("~") end, "Diff This ~")
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
    end,
  },
}
