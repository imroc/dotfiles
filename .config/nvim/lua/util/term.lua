---@diagnostic disable: undefined-global

local M = {}

M.toggle = function(cwd)
  if not cwd then
    if LastTerm == nil or not LastTerm:buf_valid() then
      LastTerm = Snacks.terminal(nil)
    else
      LastTerm:toggle()
    end
  else
    LastTerm = Snacks.terminal(nil, { cwd = cwd })
  end
end

---@param script string
M.run_script = function(script)
  local last_focused = require("toggleterm.terminal").get_last_focused()
  if last_focused then
    vim.cmd(last_focused.id .. 'TermExec cmd="' .. script .. '"')
  else
    vim.cmd('TermExec cmd="' .. script .. '"')
  end
end

M.goto = function(dir)
  return M.run_script("cd " .. dir)
end

return M
