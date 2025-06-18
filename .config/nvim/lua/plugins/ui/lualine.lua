---@diagnostic disable: missing-fields
---@diagnostic disable: undefined-global

local icons = LazyVim.config.icons
local Job = require("plenary.job")

return {
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections.lualine_c = {
        LazyVim.lualine.root_dir(),
        {
          "diagnostics",
          symbols = {
            error = icons.diagnostics.Error,
            warn = icons.diagnostics.Warn,
            info = icons.diagnostics.Info,
            hint = icons.diagnostics.Hint,
          },
        },
        -- { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } }, -- lualine_y 已展示文件类型，这里就不要了
        { LazyVim.lualine.pretty_path({ length = 8 }) }, -- LazyVim 默认展示 3 级路径，这里改为 8 级
      }
      vim.list_extend(
        opts.sections.lualine_y,
        { "filetype", icon_only = false, separator = "", padding = { left = 1, right = 0 } }
      )
      if vim.fn.executable("kubectl") == 1 then
        local job = Job:new({
          command = "kubectl",
          args = {
            "config",
            "view",
            "--minify",
            "--output",
            "jsonpath={.current-context}/{..namespace}",
          },
        })
        local result, code = job:sync()
        if code == 0 and type(result) == "table" and next(result) ~= nil then
          local kube_context = result[1]
          if kube_context then
            vim.list_extend(opts.sections.lualine_y, {
              {
                function()
                  return kube_context
                end,
                icon = { "󱃾", color = { fg = "#00BAD4" } },
              },
            })
          end
        end
      end
    end,
  },
}
