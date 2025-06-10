---@diagnostic disable: undefined-global

local M = {}

local get_project_name = function()
  local root_dir = LazyVim.root()
  local folder_name = root_dir:match("([^/\\]+)[/\\]?$")
  return folder_name
end

-- dir could be a function or a string
M.open_float = function(dir)
  local cmd = {
    "zellij",
    "run",
    "-c",
    "-f",
    "-n",
    get_project_name(),
    "--",
    "fish",
  }
  if type(dir) == "function" then
    dir = dir() or ""
  end
  if dir then
    vim.list_extend(cmd, { "-c", "cd " .. dir .. " && exec fish -i" })
  end
  vim.system(cmd)
end

local buffer = require("util.buffer")

--- @param cmd (string[]|string) Command to execute
--- @param opts? table
M.run = function(cmd, opts)
  opts = opts or {}
  local cmd_concat = { "zellij", "run", "-f" }
  local cwd = ""
  if opts.cwd then
    cwd = opts.cwd
  else
    cwd = buffer.current_dir()
  end
  vim.list_extend(cmd_concat, { "--cwd", cwd })
  if opts.name then
    vim.list_extend(cmd_concat, { "-n", opts.name })
  end
  if opts.close_on_exit then
    vim.list_extend(cmd_concat, { "-c" })
  end
  vim.list_extend(cmd_concat, { "--" })
  if type(cmd) == "string" then
    cmd = { cmd }
  end
  vim.list_extend(cmd_concat, cmd)
  vim.system(cmd_concat)
end

--- @param script (string) Command to execute
--- @param opts? table
M.run_script = function(script, opts)
  M.run({ "bash", "-c", script }, opts)
end

--- @param script (string) Command to execute
--- @param opts? table
M.run_fish_script = function(script, opts)
  M.run({ "fish", "-c", script }, opts)
end

return M
