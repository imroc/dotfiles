return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      vim.api.nvim_create_user_command("MasonInstallAll", function()
        -- Combine all packages into a single list
        local packages_to_install = {}

        -- Add packages from ensure_installed of mason.nvim
        for _, tool in ipairs(require("mason.settings").current.ensure_installed) do
          table.insert(packages_to_install, tool)
        end

        -- Add packages from ensure_installed of mason-lspconfig.nvim
        local lspconfig_to_package = require("mason-lspconfig.mappings.server").lspconfig_to_package
        for _, server in ipairs(require("mason-lspconfig.settings").current.ensure_installed) do
          local pkg = lspconfig_to_package[server]
          if pkg then
            table.insert(packages_to_install, pkg)
          end
        end

        -- Remove duplicates
        local seen = {}
        local unique_packages = {}
        for _, pkg in ipairs(packages_to_install) do
          if not seen[pkg] then
            seen[pkg] = true
            table.insert(unique_packages, pkg)
          end
        end

        -- Install all unique packages
        for _, pkg in ipairs(unique_packages) do
          vim.notify("Installing " .. pkg, vim.log.levels.INFO)
          vim.cmd("MasonInstall " .. pkg)
        end
      end, {})
      return opts
    end,
  },
}
