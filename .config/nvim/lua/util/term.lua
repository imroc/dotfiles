local M = {}

M.toggle = function(cwd)
  if not cwd then
    if last_term == nil or not last_term:buf_valid() then
      last_term = Snacks.terminal(nil)
    else
      last_term:toggle()
    end
  else
    last_term = Snacks.terminal(nil, { cwd = cwd })
  end
end

local wrap_script = function(script)
  return script
    .. [=[

while true; do
  echo "Press 'q' or 'ESC' to exit, any other key to continue:"
  read -rsn1 input
  if [[ $input == "q" ]] || [[ $input == $'\e' ]]; then
  	exit 0
  else
  	exec fish -i
  fi
done
  ]=]
end

---@param script string
---@param opts? table
M.run_script = function(script, opts)
  opts = opts or {}
  local close_on_exit = false
  if not opts.close_on_exit then
    script = wrap_script(script)
  end
  Snacks.terminal({ "bash", "-c", script }, opts)
end

return M
