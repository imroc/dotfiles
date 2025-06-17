return {
  "mason-org/mason.nvim",
  opts = function(_, opts)
    vim.api.nvim_create_user_command("MasonInstallAll", function()
      local config = require("mason.settings").current
      for _, tool in ipairs(config.ensure_installed) do
        vim.cmd("MasonInstall " .. tool)
      end
    end, {})
    return opts
  end,
}
