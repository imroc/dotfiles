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
---@param opts? table
M.run_script = function(script, opts)
  require("floaterm.api").send_cmd({ cmd = script, close_on_exit = opts.close_on_exit })
end

return M
