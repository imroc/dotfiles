return {
  "folke/trouble.nvim",
  init = function()
    vim.api.nvim_create_autocmd("BufReadPost", {
      group = vim.api.nvim_create_augroup("quickfix_to_trouble", { clear = true }),
      callback = function(ev)
        if vim.bo[ev.buf].buftype == "quickfix" then
          vim.schedule(function()
            vim.cmd("cclose")
            require("trouble").open("qflist")
          end)
        end
      end,
    })
  end,
  keys = {
    {
      "<leader>uj",
      function()
        require("trouble").toggle("snacks")
      end,
      desc = "[P]Toggle Trouble (Snacks)",
    },
  },
  opts = {
    -- win = {
    --   size = 20,
    -- },
    modes = {
      lsp = {
        win = {
          position = "bottom",
        },
      },
    },
    keys = {
      -- If I close the incorrect pane, I can bring it up with ctrl+o
      ["<esc>"] = "close",
    },
  },
}
