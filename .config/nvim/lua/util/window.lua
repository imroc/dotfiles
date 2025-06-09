local M = {}

local closable_filetypes = {
  "noice",
  "help",
  "snacks_terminal",
  "grug-far",
}

local closable_filetypes_map = {}
for _, ft in ipairs(closable_filetypes) do
  closable_filetypes_map[ft] = true
end

local function close_windows()
  local wins = vim.api.nvim_list_wins()
  for _, winid in ipairs(wins) do
    if vim.api.nvim_win_is_valid(winid) then
      local bufnr = vim.api.nvim_win_get_buf(winid)
      local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
      if closable_filetypes_map[ft] then
        vim.api.nvim_win_close(winid, true)
      end
    end
  end
end

---create a vsplit buffer in the current window
---@return integer
---@return integer
M.vsplit = function()
  vim.api.nvim_command("vsplit")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(true, true)
  return win, buf
end

M.clear = function()
  vim.cmd("cclose")
  vim.cmd("lclose")
  vim.cmd("noh")
  local trouble = package.loaded["trouble"]
  if trouble then
    trouble.close()
  end
  local noice = package.loaded["noice"]
  if noice then
    noice.cmd("dismiss")
  end
  local outline = package.loaded["outline"]
  if outline then
    if outline.is_open() then
      outline.close()
    end
  end
  -- local neotree = package.loaded["neo-tree.command"]
  -- if neotree then
  --   neotree.execute({ action = "close" })
  -- end
  close_windows()
end

local size = 8

---@return boolean
local function is_window_on_right()
  local win = vim.api.nvim_get_current_win()
  local col = vim.fn.win_screenpos(win)[2]
  local width = vim.api.nvim_win_get_width(win)
  local screen_width = vim.o.columns
  local right_pos = screen_width - col - width
  return right_pos <= 1
end
---@return boolean
local function is_window_on_bottom()
  local win = vim.api.nvim_get_current_win()
  local row = vim.fn.win_screenpos(win)[1]
  local height = vim.api.nvim_win_get_height(win)
  local screen_height = vim.o.lines
  local bottom_pos = screen_height - row - height
  return bottom_pos <= 1
end

function M.resize_width_left()
  -- 只有最右边的 window 才变宽，其它都变窄
  if is_window_on_right() then
    vim.cmd("vertical resize +" .. size)
  else
    vim.cmd("vertical resize -" .. size)
  end
end

function M.resize_width_right()
  -- 只有最右边的 window 才变窄，其它都变宽
  if is_window_on_right() then
    vim.cmd("vertical resize -" .. size)
  else
    vim.cmd("vertical resize +" .. size)
  end
end

function M.resize_height_down()
  -- 只有最下边的 window 才变矮，其它都变高
  if is_window_on_bottom() then
    vim.cmd("resize -" .. size)
  else
    vim.cmd("resize +" .. size)
  end
end

function M.resize_height_up()
  -- 只有最边边的 window 才变高，其它都变矮
  if is_window_on_bottom() then
    vim.cmd("resize +" .. size)
  else
    vim.cmd("resize -" .. size)
  end
end

return M
