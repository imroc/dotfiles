---@diagnostic disable: undefined-global

local M = {}

M.files = function(opts)
  opts = opts or {}
  opts.hidden = true
  opts.ignored = true
  opts.follow = true
  Snacks.picker.files(opts)
end

M.grep = function(opts)
  opts = opts or {}
  opts.hidden = true
  opts.ignored = true
  opts.follow = true
  Snacks.picker.grep(opts)
end

return M
