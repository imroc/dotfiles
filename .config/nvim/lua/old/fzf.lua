return {
  "ibhagwan/fzf-lua",
  opts = function(_, opts)
    local config = require("fzf-lua.config")
    -- Trouble
    if LazyVim.has("trouble.nvim") then
      config.defaults.actions.files["ctrl-e"] = require("trouble.sources.fzf").actions.open_all
    end
    local actions = require("fzf-lua").actions
    return {
      files = {
        actions = {
          -- alt-i --> ctrl i 避免与 zellij “切换到左边标签页” 快捷键冲突
          ["alt-i"] = "",
          ["ctrl-i"] = { actions.toggle_ignore },
          -- alt-h --> alt . 避免与 zellij “切换到左边面板” 快捷键冲突
          ["alt-h"] = "",
          ["alt-."] = actions.toggle_hidden,
        },
      },
      grep = {
        actions = {
          -- alt-i --> ctrl i 避免与 zellij “切换到左边标签页” 快捷键冲突
          ["alt-i"] = "",
          ["ctrl-i"] = { actions.toggle_ignore },
          -- alt-h --> alt . 避免与 zellij “切换到左边面板” 快捷键冲突
          ["alt-h"] = "",
          ["alt-."] = actions.toggle_hidden,
        },
      },
    }
  end,
  keys = {
    {
      "<leader>fp",
      function()
        require("fzf-lua").files({
          cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy"),
        })
      end,
      desc = "[P]Find Plugin Files",
    },
    {
      "<leader>fd",
      function()
        require("fzf-lua").files({
          cwd = vim.fn.expand("$HOME/dotfiles"),
        })
      end,
      desc = "[P]Find Dotfiles",
    },
    {
      "<leader>ff",
      function()
        require("fzf-lua").files({
          cwd = require("util.buffer").current_dir(),
        })
      end,
      desc = "[P]Find Files (Current Directory)",
    },
    {
      "<leader>fF",
      function()
        require("fzf-lua").files({
          no_ignore = true,
        })
      end,
      desc = "[P]Find Files (Root No Ignore)",
    },
    {
      "<leader>sg",
      function()
        require("fzf-lua").live_grep({
          cwd = require("util.buffer").current_dir(),
        })
      end,
      desc = "[P]Grep (Current Directory)",
    },
    {
      "<leader>sG",
      function()
        require("fzf-lua").live_grep({
          rg_glob = true,
          no_esc = true,
          no_ignore = true,
        })
      end,
      desc = "[P]Grep (Root With Glob No Ignore)",
    },
  },
}
