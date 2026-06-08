return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    -- downloads a prebuilt binary or falls back to cargo build
    require("fff.download").download_or_build_binary()
  end,
  opts = {
    debug = {
      enabled = true,
      show_scores = true,
    },
    keymaps = {
      move_up = { "<Up>", "<C-p>", "<C-k>" },
      move_down = { "<Down>", "<C-n>", "<C-j>" },
      send_to_quickfix = "<C-t>",
    },
    layout = {
      prompt_position = "top",
      height = 0.8,
      width = 0.8,
      flex = false,
    },
  },
  keys = {
    {
      "ff",
      function()
        require("fff").find_files()
      end,
      desc = "FFFind files",
    },
    {
      "fg",
      function()
        require("fff").live_grep()
      end,
      desc = "LiFFFe grep",
    },
    {
      "fz",
      function()
        require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
      end,
      desc = "Live fffuzy grep",
    },
    {
      "fc",
      function()
        require("fff").live_grep({ query = vim.fn.expand("<cword>") })
      end,
      desc = "Search current word",
    },
    {
      "<leader><space>",
      function()
        require("fff").find_files({ cwd = LazyVim.root() })
      end,
      desc = "[P]FFF Find Files (Root Dir)",
    },
    {
      "<leader>/",
      function()
        require("fff").live_grep({ cwd = LazyVim.root() })
      end,
      desc = "[P]FFF Grep (Root Dir)",
    },
    {
      "<leader>ff",
      function()
        require("fff").find_files({ cwd = require("util.buffer").current_dir() })
      end,
      desc = "[P]Find Files (Current Dir)",
    },
    {
      "<leader>fc",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config") })
      end,
      desc = "[P]Find Config File (~/.config)",
    },
    {
      "<leader>fl",
      function()
        require("fff").find_files({ cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy") })
      end,
      desc = "[P]Find Lazy Plugin Files",
    },
    {
      "<leader>fda",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config/aerospace") })
      end,
      desc = "[P]Find Aerospace Dotfiles",
    },
    {
      "<leader>fdb",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.local/bin") })
      end,
      desc = "[P]Find Bin",
    },
    {
      "<leader>fdf",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config/fish") })
      end,
      desc = "[P]Find Fish Dotfiles",
    },
    {
      "<leader>fdk",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config/kitty") })
      end,
      desc = "[P]Find Kitty Dotfiles",
    },
    {
      "<leader>fdn",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config/nvim") })
      end,
      desc = "[P]Find Neovim Dotfiles",
    },
    {
      "<leader>fdz",
      function()
        require("fff").find_files({ cwd = vim.fn.expand("$HOME/.config/zellij") })
      end,
      desc = "[P]Find Zellij Dotfiles",
    },
    {
      "<leader>gw",
      function()
        local output = vim.fn.systemlist("git worktree list --porcelain")
        if vim.v.shell_error ~= 0 then
          vim.notify("Not in a git repository", vim.log.levels.WARN)
          return
        end
        local worktrees = {}
        for _, line in ipairs(output) do
          local path = line:match("^worktree (.+)$")
          if path then
            table.insert(worktrees, path)
          end
        end
        if #worktrees == 0 then
          vim.notify("No worktrees found", vim.log.levels.WARN)
          return
        end
        if #worktrees == 1 then
          require("fff").find_files({ cwd = worktrees[1] })
          return
        end
        local names = {}
        local name_to_path = {}
        for _, path in ipairs(worktrees) do
          local name = vim.fn.fnamemodify(path, ":t")
          table.insert(names, name)
          name_to_path[name] = path
        end
        Snacks.picker.select(names, { prompt = "Worktree" }, function(name)
          if name then
            require("fff").find_files({ cwd = name_to_path[name] })
          end
        end)
      end,
      desc = "[P]Git Worktree Files",
    },
  },
}
