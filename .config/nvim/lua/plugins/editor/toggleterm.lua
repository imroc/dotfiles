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

---@param buf integer
---@return boolean
local function comparator(buf)
  if vim.bo[buf].filetype ~= "toggleterm" then
    return false
  end
  return vim.b[buf].toggle_number ~= nil
end

--- @param num number
local function toggle_nth_term(num)
  local terms = require("toggleterm.terminal")
  local ui = require("toggleterm.ui")
  local term = terms.get_or_create_term(num)
  ui.update_origin_window(term.window)
  term:toggle()
  -- Save the terminal in view if it was last closed terminal.
  if not ui.find_open_windows() then
    ui.save_terminal_view({ term.id }, term.id)
  end
end

local function smart_toggle()
  local ui = require("toggleterm.ui")
  local has_open, windows = ui.find_open_windows(comparator)
  local terms = require("toggleterm.terminal")
  if not has_open then
    if not ui.open_terminal_view() then
      local term_id = terms.get_toggled_id()
      terms.get_or_create_term(term_id):open()
    end
  else
    ui.close_and_save_terminal_view(windows)
  end
end

local ai_terminal = nil

---@return Terminal
local function get_ai_terminal()
  local Terminal = require("toggleterm.terminal").Terminal
  -- Lazy create ai terminal
  if not ai_terminal then
    -- Define highlight for AI terminal border (linked to DiagnosticInfo for blue)
    vim.api.nvim_set_hl(0, "ToggleTermAIBorder", { link = "DiagnosticInfo" })

    ai_terminal = Terminal:new({
      direction = "float",
      float_opts = {
        width = function()
          return math.floor(vim.o.columns * 0.99)
        end,
        height = function()
          return math.floor(vim.o.lines * 0.99)
        end,
      },
      on_open = function(term)
        vim.wo[term.window].winhl = "FloatBorder:ToggleTermAIBorder"
        vim.bo[term.bufnr].filetype = "aiterm"
      end,
      display_name = "AI",
      hidden = true,
    })
  end
  return ai_terminal
end

local function toggle_ai_terminal()
  local term = get_ai_terminal()
  local terms = require("toggleterm.terminal")
  local focused_id = terms.get_focused_id()

  if focused_id == term.id then
    -- If currently in ai terminal, close it
    term:close()
  else
    -- Otherwise, open it
    term:open()
  end
end

local function toggle_terminal()
  local count = vim.v.count
  if count and count >= 1 then
    toggle_nth_term(count)
  else
    smart_toggle()
  end
end

return {
  "akinsho/toggleterm.nvim",
  opts = {
    open_mapping = false,
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
      mode = { "n", "t", "i" },
      toggle_terminal,
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
      "<C-,>",
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
      "<M-/>",
      mode = { "n", "t" },
      "<cmd>TermNew<cr>",
      desc = "[P]New Terminal",
    },
    {
      "<leader>tr",
      rename_terminal,
      desc = "[P]Rename Terminal",
    },
    {
      "<M-,>",
      mode = { "n", "t" },
      rename_terminal,
      desc = "[P]Rename Terminal",
    },
    {
      "<C-.>",
      mode = { "n", "t", "i" },
      toggle_ai_terminal,
      desc = "[P]Toggle AI Terminal",
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
  end,
}
