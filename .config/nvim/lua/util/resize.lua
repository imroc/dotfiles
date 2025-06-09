local M = {}

local size = 8

local function is_window_on_right()
  local win = vim.api.nvim_get_current_win()
  local col = vim.fn.win_screenpos(win)[2]
  local width = vim.api.nvim_win_get_width(win)
  local screen_width = vim.o.columns
  local right_pos = screen_width - col - width
  return right_pos <= 1
end
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
