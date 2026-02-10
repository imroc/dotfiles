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
local ai_was_last_closed = false

--- Terminal focus history: prev_terminal_id is the one before current.
--- Updated in on_open so every terminal open (toggle, cycle, explicit) is tracked.
local prev_terminal_id = nil
local current_terminal_id = nil

--- Called from global on_open to track terminal focus history
---@param term table
local function on_terminal_open(term)
  if current_terminal_id and current_terminal_id ~= term.id then
    prev_terminal_id = current_terminal_id
  end
  current_terminal_id = term.id

  -- AI terminal specific styling
  if ai_terminal and term.id == ai_terminal.id then
    vim.wo[term.window].winhl = "FloatBorder:ToggleTermAIBorder"
    vim.api.nvim_win_set_config(term.window, { title = " AI ", title_pos = "left" })
  end
end

--- Cycle to next/prev terminal, skipping hidden (AI) terminals
---@param direction 1|-1
local function cycle_terminal(direction)
  local terms = require("toggleterm.terminal")
  local all = terms.get_all() -- excludes hidden terminals (AI)
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
      -- No on_open here; global on_open handles tracking and AI styling
      display_name = "AI",
      hidden = true,
    })
  end
  return ai_terminal
end

local function switch_to_ai_terminal()
  if ai_terminal and ai_terminal:is_focused() then
    return
  end
  ai_was_last_closed = false
  get_ai_terminal():open()
end

local function toggle_terminal()
  -- Close AI terminal if it's open
  if ai_terminal and ai_terminal:is_open() then
    ai_terminal:close()
    ai_was_last_closed = true
    return
  end
  -- Reopen AI terminal if it was the last one closed by <C-/> (only without count)
  local count = vim.v.count
  if count == 0 and ai_was_last_closed and ai_terminal then
    ai_was_last_closed = false
    ai_terminal:open()
    return
  end
  ai_was_last_closed = false
  vim.cmd(count .. "ToggleTerm")
end

local function switch_to_last_terminal()
  if not prev_terminal_id then
    vim.notify("No previous terminal", vim.log.levels.WARN)
    return
  end
  local terms = require("toggleterm.terminal")
  local term = terms.get(prev_terminal_id, true)
  if not term then
    vim.notify("Previous terminal no longer exists", vim.log.levels.WARN)
    prev_terminal_id = nil
    return
  end
  term:open()
end

--- Send file or selection to AI terminal as @ reference
local function send_to_ai_terminal()
  local term = get_ai_terminal()
  local file_path = vim.fn.expand("%:p")

  if file_path == "" then
    vim.notify("No file to send", vim.log.levels.WARN)
    return
  end

  local text
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "\22" then -- visual, visual line, visual block
    -- Get visual selection range
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    text = string.format('@"%s:%d-%d" ', file_path, start_line, end_line)
  else
    -- Normal mode: send entire file
    text = '@"' .. file_path .. '" '
  end

  -- Open AI terminal if not open
  if not term:is_open() then
    term:open()
  end

  -- Send the command to terminal without trailing newline
  -- Use chansend directly to avoid the automatic newline from term:send()
  vim.fn.chansend(term.job_id, text)
  if not term:is_focused() then
    term:focus()
  end
end

return {
  "akinsho/toggleterm.nvim",
  opts = {
    open_mapping = false,
    direction = "float",
    auto_scroll = false,
    on_open = function(term)
      update_float_title(term)
      on_terminal_open(term)
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
      "<C-.>",
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
      "<C-S-/>",
      mode = { "n", "t", "i" },
      switch_to_ai_terminal,
      desc = "[P]Switch to AI Terminal",
    },
    {
      "<C-S-,>",
      mode = { "n", "t" },
      switch_to_last_terminal,
      desc = "[P]Switch to Last Terminal",
    },
    {
      "<leader>aa",
      send_to_ai_terminal,
      mode = { "n", "v" },
      desc = "[P]Send file/selection to AI Terminal",
    },
  },
  config = function(_, opts)
    require("toggleterm").setup(opts)
  end,
}
