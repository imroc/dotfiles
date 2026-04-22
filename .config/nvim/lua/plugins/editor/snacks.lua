-- 虽然变量没被引用，但这个却是必须的，参考snacks 官方示例

local picker = require("util.picker")
local iwiki = require("util.iwiki")
local bookmark = require("util.bookmark")

local get_copy_opts = function(what)
  return {
    open = function(url)
      vim.fn.setreg("+", url)
    end,
    notify = false,
    what = what,
  }
end

local gitbrowse_line_suffix = function(line_start, line_end)
  if not line_start or line_start == 0 then
    return ""
  end
  if not line_end or line_start == line_end then
    return ("#L%s"):format(line_start)
  end
  return ("#L%s-%s"):format(line_start, line_end)
end

return {
  "folke/snacks.nvim",
  keys = {
    -- 禁用一些快捷键，避免与自定义快捷键冲突
    -- { "<leader>S", false },
    -- { "<leader>gS", false },
    { "<leader>gi", false },
    { "<leader>gI", false },
    { "<leader>gp", false },
    { "<leader>gP", false },
    { "<leader>gd", false },
    { "<leader>gD", false },
    { "<leader>gc", false },
    { "<leader>.", false },
    {
      "<leader>gHi",
      function()
        Snacks.picker.gh_issue()
      end,
      desc = "GitHub Issues (open)",
    },
    {
      "<leader>gHI",
      function()
        Snacks.picker.gh_issue({ state = "all" })
      end,
      desc = "GitHub Issues (all)",
    },
    {
      "<leader>gHp",
      function()
        Snacks.picker.gh_pr()
      end,
      desc = "GitHub Pull Requests (open)",
    },
    {
      "<leader>gHP",
      function()
        Snacks.picker.gh_pr({ state = "all" })
      end,
      desc = "GitHub Pull Requests (all)",
    },
    {
      "g.",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>gyr",
      function()
        Snacks.gitbrowse(get_copy_opts("repo"))
      end,
      desc = "[P]Copy Repo URL",
    },
    {
      "<leader>gyf",
      function()
        Snacks.gitbrowse(get_copy_opts("file"))
      end,
      mode = { "n", "v" },
      desc = "[P]Copy File URL",
    },
    {
      "<leader>gyp",
      function()
        Snacks.gitbrowse(get_copy_opts("permalink"))
      end,
      mode = { "n", "v" },
      desc = "[P]Copy Permalink URL",
    },
    {
      "<leader>ogr",
      function()
        Snacks.gitbrowse({ what = "repo" })
      end,
      desc = "[P]Open Repo In Browser",
    },
    {
      "<leader>ogf",
      function()
        Snacks.gitbrowse({ what = "file", line_start = 0, line_end = 0 })
      end,
      mode = "n",
      desc = "[P]Open File In Browser",
    },
    {
      "<leader>ogf",
      function()
        Snacks.gitbrowse({ what = "file" })
      end,
      mode = "v",
      desc = "[P]Open File In Browser",
    },
    {
      "<leader>ogp",
      function()
        Snacks.gitbrowse({ what = "permalink", line_start = 0, line_end = 0 })
      end,
      mode = "n",
      desc = "[P]Open Permalink In Browser",
    },
    {
      "<leader>ogp",
      function()
        Snacks.gitbrowse({ what = "permalink" })
      end,
      mode = "v",
      desc = "[P]Open Permalink In Browser",
    },
    {
      "<leader>ogb",
      function()
        Snacks.gitbrowse({ what = "branch" })
      end,
      desc = "[P]Open Branch In Browser",
    },
    -- {
    --   "<leader>gs",
    --   function()
    --     Snacks.picker.git_status({ cwd = LazyVim.root.git() })
    --   end,
    --   desc = "[P]Git Status (Root Dir)",
    -- },
    {
      "<leader>fl",
      function()
        picker.files({
          cwd = vim.fs.joinpath(vim.fn.stdpath("data"), "lazy"),
        })
      end,
      desc = "[P]Find Lazy Plugin Files",
    },
    {
      "<leader>fc",
      function()
        picker.files({
          cwd = vim.fn.expand("$HOME/.config"),
        })
      end,
      desc = "[P]Find Config File (~/.config)",
    },
    {
      "<leader>fda",
      function()
        picker.files({ cwd = vim.fn.expand("$HOME/.config/aerospace") })
      end,
      desc = "[P]Find Aerospace Dotfiles",
    },
    {
      "<leader>fdb",
      function()
        picker.files({ cwd = vim.fn.expand("$HOME/.local/bin") })
      end,
      desc = "[P]Find Bin",
    },
    {
      "<leader>fdf",
      function()
        picker.files({ cwd = vim.fn.expand("$HOME/.config/fish") })
      end,
      desc = "[P]Find Fish Dotfiles",
    },
    {
      "<leader>fdk",
      function()
        picker.files({ cwd = vim.fn.expand("$HOME/.config/kitty") })
      end,
      desc = "[P]Find Kitty Dotfiles",
    },
    {
      "<leader>fdn",
      function()
        picker.files({ cwd = vim.fn.expand("$HOME/.config/nvim") })
      end,
      desc = "[P]Find Neovim Dotfiles",
    },
    {
      "<leader>fdz",
      function()
        picker.files({ cwd = vim.fn.expand("$HOME/.config/zellij") })
      end,
      desc = "[P]Find Zellij Dotfiles",
    },
    {
      "<leader><space>",
      function()
        picker.files({ cwd = LazyVim.root() })
      end,
      desc = "[P]Find Files (Root Dir)",
    },
    {
      "<leader>ff",
      function()
        picker.files({ cwd = require("util.buffer").current_dir() })
      end,
      desc = "[P]Find Files (Current Dir)",
    },
    {
      "<C-S-p>",
      function()
        Snacks.picker.zoxide({})
      end,
      desc = "[P]Find Zoxide Directory",
    },
    {
      "<leader>fz",
      function()
        Snacks.picker.zoxide({})
      end,
      desc = "[P]Find Zoxide Directory",
    },
    {
      "<leader>fj",
      bookmark.find_files,
      desc = "[P]Find Bookmark Files",
    },
    {
      "<leader>fJ",
      bookmark.find_files_subdir,
      desc = "[P]Find Bookmark Subdir Files",
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
          picker.files({ cwd = worktrees[1] })
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
            picker.files({ cwd = name_to_path[name] })
          end
        end)
      end,
      desc = "[P]Git Worktree Files",
    },
    {
      "<leader>sg",
      function()
        picker.grep({
          cwd = LazyVim.root(),
          regex = false,
          args = { "--case-sensitive" },
        })
      end,
      desc = "[P]Grep (Plain Text)",
    },
    {
      "<leader>/",
      function()
        picker.grep({ cwd = LazyVim.root() })
      end,
      desc = "[P]Grep (Regex)",
    },
  },
  opts = function(_, opts)
    return vim.tbl_deep_extend("force", opts or {}, {
      bigfile = {
        enabled = true,
        size = 10 * 1024 * 1024,
      },
      gitbrowse = {
        url_patterns = {
          ["git%.woa%.com"] = {
            branch = "/tree/{branch}",
            file = function(fields)
              return ("/blob/%s/%s%s"):format(
                fields.branch,
                fields.file,
                gitbrowse_line_suffix(fields.line_start, fields.line_end)
              )
            end,
            permalink = function(fields)
              return ("/blob/%s/%s%s"):format(
                fields.commit,
                fields.file,
                gitbrowse_line_suffix(fields.line_start, fields.line_end)
              )
            end,
            commit = "/commit/{commit}",
          },
          ["gitee%.com"] = {
            branch = "/tree/{branch}",
            file = function(fields)
              return ("/blob/%s/%s%s"):format(
                fields.branch,
                fields.file,
                gitbrowse_line_suffix(fields.line_start, fields.line_end)
              )
            end,
            permalink = function(fields)
              return ("/blob/%s/%s%s"):format(
                fields.commit,
                fields.file,
                gitbrowse_line_suffix(fields.line_start, fields.line_end)
              )
            end,
            commit = "/commit/{commit}",
          },
        },
      },
      scroll = { enabled = false },
      dashboard = {
        enabled = vim.g.simpler_scrollback ~= "deeznuts",
        preset = {
          -- keys = {
          --   { icon = " ", key = "s", desc = "Restore Session", section = "session" },
          --   -- { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
          --   { icon = " ", key = "<esc>", desc = "Quit", action = ":qa" },
          -- },
          header = [[
██████╗  ██████╗  ██████╗    ██╗██████╗ ███████╗
██╔══██╗██╔═══██╗██╔════╝    ██║██╔══██╗██╔════╝
██████╔╝██║   ██║██║         ██║██║  ██║█████╗  
██╔══██╗██║   ██║██║         ██║██║  ██║██╔══╝  
██║  ██║╚██████╔╝╚██████╗    ██║██████╔╝███████╗
╚═╝  ╚═╝ ╚═════╝  ╚═════╝    ╚═╝╚═════╝ ╚══════╝
        ]],
        },
      },
      picker = {
        layout = {
          preset = "ivy",
          cycle = false,
        },
        layouts = {
          -- I wanted to modify the ivy layout height and preview pane width,
          -- this is the only way I was able to do it
          -- NOTE: I don't think this is the right way as I'm declaring all the
          -- other values below, if you know a better way, let me know
          --
          -- Then call this layout in the keymaps above
          -- got example from here
          -- https://github.com/folke/snacks.nvim/discussions/468
          ivy = {
            layout = {
              box = "vertical",
              backdrop = false,
              row = -1,
              width = 0,
              height = 0.5,
              border = "top",
              title = " {title} {live} {flags}",
              title_pos = "left",
              { win = "input", height = 1, border = "bottom" },
              {
                box = "horizontal",
                { win = "list", border = "none" },
                { win = "preview", title = "{preview}", width = 0.5, border = "left" },
              },
            },
          },
        },
        matcher = {
          frecency = true,
        },
        win = {
          input = {
            keys = {
              -- to close the picker on ESC instead of going to normal mode,
              -- add the following keymap to your config
              ["<Esc>"] = { "close", mode = { "n", "i" } },
              ["<C-h>"] = { "preview_scroll_left", mode = { "i", "n" } },
              ["<C-l>"] = { "preview_scroll_right", mode = { "i", "n" } },
              ["<C-t>"] = {
                "trouble_open",
                mode = { "i" },
              },
            },
          },
          list = {
            keys = {
              -- to close the picker on ESC instead of going to normal mode,
              -- add the following keymap to your config
              ["<Esc>"] = { "close", mode = { "n", "i" } },
              ["<C-h>"] = { "preview_scroll_left", mode = { "i", "n" } },
              ["<C-l>"] = { "preview_scroll_right", mode = { "i", "n" } },
            },
          },
        },
        formatters = {
          file = {
            filename_first = true, -- display filename before the file path
            truncate = 80,
          },
        },
      },
      -- Folke pointed me to the snacks docs
      -- https://github.com/LazyVim/LazyVim/discussions/4251#discussioncomment-11198069
      -- Here's the lazygit snak docs
      -- https://github.com/folke/snacks.nvim/blob/main/docs/lazygit.md
      lazygit = {
        theme = {
          selectedLineBgColor = { bg = "CursorLine" },
        },
        -- With this I make lazygit to use the entire screen, because by default there's
        -- "padding" added around the sides
        -- I asked in LazyGit, folke didn't like it xD xD xD
        -- https://github.com/folke/snacks.nvim/issues/719
        win = {
          -- -- The first option was to use the "dashboard" style, which uses a
          -- -- 0 height and width, see the styles documentation
          -- -- https://github.com/folke/snacks.nvim/blob/main/docs/styles.md
          -- style = "dashboard",
          -- But I can also explicitly set them, which also works, what the best
          -- way is? Who knows, but it works
          width = 0,
          height = 0,
        },
      },
      notifier = {
        enabled = true,
        top_down = false, -- place notifications from top to bottom
      },
      -- This keeps the image on the top right corner, basically leaving your
      -- text area free, suggestion found in reddit by user `Redox_ahmii`
      -- https://www.reddit.com/r/neovim/comments/1irk9mg/comment/mdfvk8b/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
      styles = {
        snacks_image = {
          relative = "editor",
          col = -1,
        },
      },
      image = {
        enabled = true,
        -- 自定义图片路径解析，用于处理 iwiki 需要鉴权的图片
        resolve = iwiki.resolve_image,
        convert = {
          notify = false, -- disable notification on error
        },
        doc = {
          -- Personally I set this to false, I don't want to render all the
          -- images in the file, only when I hover over them
          -- render the image inline in the buffer
          -- if your env doesn't support unicode placeholders, this will be disabled
          -- takes precedence over `opts.float` on supported terminals
          -- inline = false,
          inline = vim.g.neovim_mode == "skitty" and true or false,
          -- only_render_image_at_cursor = vim.g.neovim_mode == "skitty" and false or true,
          -- render the image in a floating window
          -- only used if `opts.inline` is disabled
          float = true,
          -- Sets the size of the image
          -- max_width = 60,
          -- max_width = vim.g.neovim_mode == "skitty" and 20 or 60,
          -- max_height = vim.g.neovim_mode == "skitty" and 10 or 30,
          -- max_width = vim.g.neovim_mode == "skitty" and 5 or 60,
          -- max_height = vim.g.neovim_mode == "skitty" and 2.5 or 30,
          -- max_width = 80,
          -- max_height = 40,
          -- max_height = 30,
          -- Apparently, all the images that you preview in neovim are converted
          -- to .png and they're cached, original image remains the same, but
          -- the preview you see is a png converted version of that image
          --
          -- Where are the cached images stored?
          -- This path is found in the docs
          -- :lua print(vim.fn.stdpath("cache") .. "/snacks/image")
          -- For me returns `~/.cache/neobean/snacks/image`
          -- Go 1 dir above and check `sudo du -sh ./* | sort -hr | head -n 5`
        },
      },
    })
  end,
}
