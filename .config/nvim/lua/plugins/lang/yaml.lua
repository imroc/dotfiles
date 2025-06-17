return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "imroc/kubeschema.nvim",
        -- dir = "~/dev/kubeschema.nvim",
        opts = {
          schema = {
            dir = "~/.config/kubeschemas",
          },
          ignore_file_patterns = {},
        },
      },
      "b0o/SchemaStore.nvim",
    },
    opts = function(_, opts)
      opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
        yamlls = {
          capabilities = {
            workspace = {
              didChangeConfiguration = {
                -- kubeschema.nvim relies on workspace.didChangeConfiguration to implement dynamic schema loading of yamlls.
                -- It is recommended to enable dynamicRegistration (it's also OK not to enable it, but warning logs will be
                -- generated from LspLog, but it will not affect the function of kubeschema.nvim)
                dynamicRegistration = true,
              },
            },
          },
          -- IMPORTANT!!! Set kubeschema's on_attch to yamlls so that kubeschema can dynamically and accurately match the
          -- corresponding schema file based on the yaml file content (APIVersion and Kind).
          on_attach = require("kubeschema").on_attach,
          on_new_config = function(new_config)
            new_config.settings.yaml = vim.tbl_deep_extend("force", new_config.settings.yaml or {}, {
              editor = {
                formatOnType = false,
              },
              format = {
                enable = false,
              },
              schemaStore = {
                enable = false,
              },
              -- Use other schemas from SchemaStore
              -- https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/api/json/catalog.json
              schemas = require("schemastore").yaml.schemas({
                -- Optional ignore schemas from SchemaStore, each item is a schema name in SchemaStore's catalog.json
                ignore = {
                  -- Rancher Fleet's fileMatch is 'fleet.yaml', which may conflict with the kubernetes yaml file of the same name.
                  -- e.g. https://github.com/googleforgames/agones/blob/main/examples/fleet.yaml
                  "Rancher Fleet",
                },
                extra = {
                  {
                    description = "CNB",
                    fileMatch = ".cnb.yml",
                    name = "CNB",
                    url = "https://docs.cnb.woa.com/conf-schema.json",
                  },
                },
              }),
            })
          end,
        },
      })
    end,
  },
  {
    "cuducos/yaml.nvim",
    ft = { "yaml" },
    keys = {
      {
        "<localleader>s",
        "<cmd>YAMLSnacks<CR>",
        ft = "yaml",
        desc = "[P]YAML structure",
      },
      {
        "<localleader>k",
        "<cmd>YAMLYankKey +<CR>",
        ft = "yaml",
        desc = "[P]Copy YAML Key",
      },
      {
        "<localleader>v",
        "<cmd>YAMLYankValue +<CR>",
        ft = "yaml",
        desc = "[P]Copy YAML Value",
      },
      {
        "<localleader>c",
        "<cmd>YAMLView<CR>",
        ft = "yaml",
        desc = "[P]View Current key and value",
      },
    },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        yaml = { "yamlfmt" },
      })
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "yamlfmt" })
    end,
  },
  {
    "Allaman/kustomize.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    ft = "yaml",
    opts = {
      enable_key_mappings = false,
      enable_lua_snip = false,
      build = {
        additional_args = {
          "--enable-helm",
          "--load-restrictor=LoadRestrictionsNone",
        },
      },
    },
    keys = {
      {
        "<leader>kb",
        "<cmd>KustomizeBuild<cr>",
        desc = "[P]Build (kustomize)",
      },
    },
  },
}
