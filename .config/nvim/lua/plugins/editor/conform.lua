local function format_save_asynchronously()
  local conform = require("conform")
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

return {
  "stevearc/conform.nvim",
  lazy = true,
  keys = {
    {
      "<leader>;",
      mode = { "n", "v" },
      desc = "[P]Format and Save file asynchronously",
      format_save_asynchronously,
    },
    {
      "<leader>;",
      mode = { "n", "v", "i" },
      desc = "[P]Format and Save file asynchronously",
      format_save_asynchronously,
    },
  },
}
