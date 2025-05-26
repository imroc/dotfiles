if true then
  return {}
end
local path_separator = package.config:sub(1, 1)
local config_dir = vim.fn.stdpath("config")

local kubeschema_dir = config_dir .. path_separator .. "kubeschema"
local kubeschemas_dir = config_dir .. path_separator .. "kubeschemas"
local crd_json = kubeschema_dir .. path_separator .. "crdSchemas" .. path_separator .. "all.json"
local k8s_json = kubeschemas_dir .. path_separator .. "all.json"

return {
  {
    "someone-stole-my-name/yaml-companion.nvim",
    lazy = true,
    ft = "yaml",
    dependencies = {
      { "neovim/nvim-lspconfig" },
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
    },
    keys = {
      { "<leader>fy", "<cmd>Telescope yaml_schema<cr>", desc = "[P]Select Yaml Schema" },
    },
    config = function()
      require("telescope").load_extension("yaml_schema")
      local cfg = require("yaml-companion").setup({
        builtin_matchers = {
          kubernetes = { enabled = false },
        },
        -- 额外的 schema，通过 <leader>fy 选择
        schemas = {
          {
            name = "Kubernetes CRDs",
            uri = "file://" .. crd_json,
          },
          {
            name = "Kubernetes",
            uri = "file://" .. k8s_json,
          },
        },

        lspconfig = {
          settings = {
            yaml = {
              validate = true,
              schemaStore = {
                enable = false,
                url = "",
              },

              -- 只启用 schemastore 中部分 schema，具体名称参考 catalog 中的 name:
              -- https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/api/json/catalog.json
              schemas = require("schemastore").yaml.schemas({
                select = {
                  "kustomization.yaml",
                  "GitHub Workflow",
                },
              }),
            },
          },
        },
      })
      require("lspconfig")["yamlls"].setup(cfg)
    end,
  },
}
