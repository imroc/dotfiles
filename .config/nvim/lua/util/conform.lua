---@diagnostic disable: undefined-global

local M = {}

local conform = require("conform")

function M.format_and_save_async()
  local bufnr = vim.api.nvim_get_current_buf()
  conform.format({
    async = true,
    quiet = true,
  }, function()
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd("w")
    end)
  end)
end

return M
