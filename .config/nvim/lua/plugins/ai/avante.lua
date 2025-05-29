return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
  opts = {
    mappings = {
      ask = "<leader>ia", -- ask
      edit = "<leader>ie", -- edit
      refresh = "<leader>ir", -- refresh
    },
    behaviour = {
      auto_set_keymaps = false,
    },
    provider = "deepseek",
    vendors = {
      deepseek = {
        __inherited_from = "openai",
        api_key_name = "DEEPSEEK_API_KEY",
        endpoint = "https://api.lkeap.cloud.tencent.com/v1",
        model = "deepseek-r1",
      },
    },
  },
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = "make",
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    -- {
    --   -- support for image pasting
    --   "HakonHarnes/img-clip.nvim",
    --   event = "VeryLazy",
    --   keys = {
    --     {
    --       "<localleader>p",
    --       "<cmd>PasteImage<CR>",
    --       ft = "markdown",
    --       desc = "[P]Paste image from system clipboard",
    --     },
    --   },
    --   cmd = { "PasteImage" },
    --   opts = {
    --     -- recommended settings
    --     default = {
    --       embed_image_as_base64 = false,
    --       prompt_for_file_name = false,
    --       drag_and_drop = {
    --         insert_mode = true,
    --       },
    --       -- required for Windows users
    --       use_absolute_path = true,
    --     },
    --   },
    -- },
    {
      -- Make sure to set this up properly if you have lazy=true
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
    {
      "saghen/blink.cmp",
      dependencies = {
        "Kaiser-Yang/blink-cmp-avante",
      },
      opts = function(_, opts)
        opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
          providers = {
            avante = {
              module = "blink-cmp-avante",
              name = "Avante",
              opts = {},
            },
          },
        })
        vim.list_extend(opts.sources.default, { "avante" })
      end,
    },
  },
}
