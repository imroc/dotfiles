-- 虽然变量没被引用，但这个却是必须的，参考snacks 官方示例

local picker = require("util.picker")

local get_copy_opts = function(what)
  return {
    open = function(url)
      vim.fn.setreg("+", url)
    end,
    notify = false,
    what = what,
  }
end

return {
  "folke/snacks.nvim",
  keys = {
    -- 禁用一些快捷键，避免与自定义快捷键冲突
    -- { "<leader>.", false },
    -- { "<leader>S", false },
    -- { "<leader>gS", false },
    { "<leader>gd", false },
    { "<leader>gc", false },
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
      "<leader>gOr",
      function()
        Snacks.gitbrowse({ what = "repo" })
      end,
      desc = "[P]Open Repo In Browser",
    },
    {
      "<leader>gOf",
      function()
        Snacks.gitbrowse({ what = "file" })
      end,
      mode = { "n", "v" },
      desc = "[P]Open File In Browser",
    },
    {
      "<leader>gOp",
      function()
        Snacks.gitbrowse({ what = "permalink" })
      end,
      mode = { "n", "v" },
      desc = "[P]Open Permalink In Browser",
    },
    {
      "<leader>gOb",
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
      "<leader>fd",
      function()
        picker.files({
          cwd = vim.fn.expand("$HOME/dotfiles"),
        })
      end,
      desc = "[P]Find Dotfiles",
    },
    {
      "<leader>ff",
      function()
        picker.files({ cwd = LazyVim.root() })
      end,
      desc = "[P]Find Files (Root Dir)",
    },
    {
      "<leader>fF",
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
      "<leader>sG",
      function()
        picker.grep({ cwd = LazyVim.root() })
      end,
      desc = "[P]Grep (Regex)",
    },
  },
  opts = function(_, opts)
    return vim.tbl_deep_extend("force", opts or {}, {
      scroll = { enabled = false },
      dashboard = {
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
              ["<C-m>"] = {
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
        doc = {
          -- Personally I set this to false, I don't want to render all the
          -- images in the file, only when I hover over them
          -- render the image inline in the buffer
          -- if your env doesn't support unicode placeholders, this will be disabled
          -- takes precedence over `opts.float` on supported terminals
          inline = false,
          -- only_render_image_at_cursor = vim.g.neovim_mode == "skitty" and false or true,
          -- render the image in a floating window
          -- only used if `opts.inline` is disabled
          float = true,
          -- Sets the size of the image
          -- max_width = 60,
          -- max_width = vim.g.neovim_mode == "skitty" and 20 or 60,
          -- max_height = vim.g.neovim_mode == "skitty" and 10 or 30,
          max_width = 200,
          max_height = 100,
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
