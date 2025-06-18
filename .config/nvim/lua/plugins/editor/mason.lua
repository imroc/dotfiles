return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        local config = require("mason.settings").current
        for _, tool in ipairs(config.ensure_installed) do
          vim.cmd("MasonInstall " .. tool)
        end

        local mason_lsp_config = require("mason-lspconfig.settings").current
        local lspconfig_to_package = require("mason-lspconfig.mappings.server").lspconfig_to_package
        for _, server in ipairs(mason_lsp_config.ensure_installed) do
          local pkg = lspconfig_to_package[server]
          if pkg then
            vim.cmd("MasonInstall " .. pkg)
          end
        end
      end, {})
      return opts
    end,
  },
}
