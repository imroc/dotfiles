local M = {}

local function reverse_table(original)
  local reversed = {}
  for i = #original, 1, -1 do
    table.insert(reversed, original[i])
  end
  return reversed
end

M.reverse_str = function(str, sep)
  local parts = vim.split(str, sep, { plain = true })
  return table.concat(reverse_table(parts), sep)
end

return M
