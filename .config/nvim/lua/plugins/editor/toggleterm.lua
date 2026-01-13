function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<C-;>", [[<C-\><C-n>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

local function rename_terminal()
  local focused_id = require("toggleterm.terminal").get_focused_id()
  if focused_id then
    vim.cmd(focused_id .. "ToggleTermSetName")
  else
    vim.cmd("ToggleTermSetName")
  end
end

return {
  "akinsho/toggleterm.nvim",
  opts = {
    open_mapping = [[<C-/>]],
    direction = "float",
    auto_scroll = false,
    size = function(term)
      if term.direction == "horizontal" then
        return vim.o.lines * 0.4
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
  },
  keys = {
    {
      "<C-/>",
      mode = { "n", "t" },
      "<cmd>ToggleTerm<cr>",
      desc = "[P]Toggle Terminal",
    },
    {
      "<leader>t",
      "",
      desc = "[P]Terminal",
    },
    {
      "<leader>tj",
      "<cmd>ToggleTerm direction=horizontal<cr>",
      desc = "[P]Open Horizontal Terminal",
    },
    {
      "<leader>tl",
      "<cmd>ToggleTerm direction=vertical<cr>",
      desc = "[P]Open Vertical Terminal",
    },
    {
      "<leader>tf",
      "<cmd>ToggleTerm direction=float<cr>",
      desc = "[P]Open Float Terminal",
    },
    {
      "<leader>tt",
      "<cmd>TermSelect<cr>",
      desc = "[P]Select Terminal",
    },
    {
      "<C-.>",
      mode = { "n", "t" },
      "<cmd>TermSelect<cr>",
      desc = "[P]Select Terminal",
    },
    {
      "<leader>tn",
      "<cmd>TermNew<cr>",
      desc = "[P]New Terminal",
    },
    {
      "<C-\\>",
      mode = { "n", "t" },
      "<cmd>TermNew<cr>",
      desc = "[P]New Terminal",
    },
    {
      "<leader>tr",
      rename_terminal,
      desc = "[P]Rename Terminal",
    },
  },
  config = true,
}
