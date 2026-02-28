function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set("t", "<C-;>", [[<C-\><C-n>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")

--- Update the float window title to show "id:name"
---@param term table
local function update_float_title(term)
  if term:is_float() and term.window and vim.api.nvim_win_is_valid(term.window) then
    local name = term.display_name or vim.split(term.name or "", ";")[1] or ""
    local title = string.format(" %d:%s ", term.id, name)
    vim.api.nvim_win_set_config(term.window, { title = title, title_pos = "left" })
  end
end

---@param term table
local function do_rename(term)
  vim.ui.input({ prompt = "Terminal name: ", default = term.display_name or "" }, function(name)
    if name and #name > 0 then
      term.display_name = name
      update_float_title(term)
    end
  end)
  -- noice.nvim replaces vim.ui.input with a float window;
  -- schedule startinsert so it runs after the float is created
  vim.schedule(function()
    vim.cmd("startinsert")
  end)
end

local function rename_terminal()
  local terms = require("toggleterm.terminal")
  local focused_id = terms.get_focused_id()
  local term = focused_id and terms.get(focused_id)
  if term then
    do_rename(term)
    return
  end

  -- No focused terminal, let user pick from list
  local all = terms.get_all()
  if #all == 0 then
    vim.notify("No terminals to rename", vim.log.levels.WARN)
    return
  end

  vim.ui.select(all, {
    prompt = "Select terminal to rename:",
    format_item = function(t)
      return string.format("%d: %s", t.id, t:_display_name())
    end,
  }, function(selected)
    if selected then
      do_rename(selected)
    end
  end)
end

local ai_terminal = nil

--- Terminal focus history for <C-S-,>
local prev_terminal_id = nil
local current_terminal_id = nil

--- Called from global on_open to track terminal focus history
---@param term table
local function on_terminal_open(term)
  if current_terminal_id and current_terminal_id ~= term.id then
    prev_terminal_id = current_terminal_id
  end
  current_terminal_id = term.id
end

--- Cycle to next/prev terminal by id order
---@param direction 1|-1
local function cycle_terminal(direction)
  local terms = require("toggleterm.terminal")
  local all = terms.get_all()
  if #all == 0 then
    return
  end

  local focused_id = terms.get_focused_id()
  local current_idx = nil
  for i, t in ipairs(all) do
    if t.id == focused_id then
      current_idx = i
      break
    end
  end

  if not current_idx then
    all[1]:open()
    return
  end

  local next_idx = ((current_idx - 1 + direction) % #all) + 1
  all[next_idx]:open()
end

local function get_ai_terminal()
  local Terminal = require("toggleterm.terminal").Terminal
  if not ai_terminal then
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
      display_name = "AI",
    })
  end
  return ai_terminal
end

local function switch_to_ai_terminal()
  if ai_terminal and ai_terminal:is_focused() then
    return
  end
  get_ai_terminal():open()
end

local function switch_to_last_terminal()
  if not prev_terminal_id then
    vim.notify("No previous terminal", vim.log.levels.WARN)
    return
  end
  local terms = require("toggleterm.terminal")
  local term = terms.get(prev_terminal_id)
  if not term then
    vim.notify("Previous terminal no longer exists", vim.log.levels.WARN)
    prev_terminal_id = nil
    return
  end
  term:open()
end

--- Send file or selection to AI terminal as @ reference
---@param is_visual? boolean
local function send_to_ai_terminal(is_visual)
  local text = require("util.clipboard").get_ai_ref_text(is_visual)
  if not text then
    vim.notify("No file to send", vim.log.levels.WARN)
    return
  end

  local term = get_ai_terminal()
  if not term:is_open() then
    term:open()
  end

  vim.fn.chansend(term.job_id, text)
  if not term:is_focused() then
    term:focus()
  end
end

return {
  "akinsho/toggleterm.nvim",
  opts = {
    open_mapping = "<C-/>",
    direction = "float",
    auto_scroll = false,
    on_open = function(term)
      update_float_title(term)
      on_terminal_open(term)
      -- AI terminal specific styling
      if ai_terminal and term.id == ai_terminal.id then
        vim.wo[term.window].winhl = "FloatBorder:ToggleTermAIBorder"
      end
      -- Double vim.schedule to ensure startinsert runs after toggleterm's
      -- __restore_mode (which uses a single vim.schedule internally)
      vim.schedule(function()
        vim.schedule(function()
          if
            term.window
            and vim.api.nvim_win_is_valid(term.window)
            and term.window == vim.api.nvim_get_current_win()
          then
            vim.cmd("startinsert")
          end
        end)
      end)
    end,
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
      "<cmd>ToggleTerm<cr>",
      mode = { "n", "t", "i" },
      desc = "[P]Toggle Terminal",
    },
    {
      "<C-_>",
      "<cmd>ToggleTerm<cr>",
      mode = { "n", "t", "i" },
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
      "<C-S-n>",
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
      "<M-;>",
      mode = { "n", "t" },
      rename_terminal,
      desc = "[P]Rename Terminal",
    },
    {
      "<M-.>",
      mode = { "n", "t" },
      function()
        cycle_terminal(1)
      end,
      desc = "[P]Next Terminal",
    },
    {
      "<M-,>",
      mode = { "n", "t" },
      function()
        cycle_terminal(-1)
      end,
      desc = "[P]Prev Terminal",
    },
    {
      "<M-/>",
      mode = { "n", "t", "i" },
      switch_to_ai_terminal,
      desc = "[P]Switch to AI Terminal",
    },
    {
      "<C-.>",
      mode = { "n", "t" },
      switch_to_last_terminal,
      desc = "[P]Switch to Last Terminal",
    },
    {
      "<leader>aa",
      function()
        send_to_ai_terminal(false)
      end,
      mode = "n",
      desc = "[P]Send file to AI Terminal",
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
    -- Register visual mapping here (not in lazy keys) to avoid lazy's
    -- feedkeys replay losing the visual selection on first trigger.
    -- Use <Esc> prefix so '< '> marks are reliably set before the callback.
    vim.keymap.set("v", "<leader>aa", function()
      -- feedkeys <Esc> and schedule the actual work so marks are set
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
      vim.schedule(function()
        send_to_ai_terminal(true)
      end)
    end, { desc = "[P]Send selection to AI Terminal" })
  end,
}
