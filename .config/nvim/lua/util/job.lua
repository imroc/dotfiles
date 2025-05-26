local M = {}

local buffer = require("util.buffer")

---@param command string Command to run
---@param job Job
M.run = function(command, job)
  if not job.cwd then
    job.cwd = buffer.current_dir()
  end
  on_exit = job.on_exit
  job = vim.tbl_deep_extend("force", job, {
    command = command,
    on_exit = function(job, code, signal)
      if on_exit then
        on_exit(job, code, signal)
        return
      end
      local result = job:stderr_result()
      if next(result) == nil then
        result = job:result()
      end
      if next(result) ~= nil then
        local msg = table.concat(result, "\n")
        if not vim.g.vscode then
          vim.notify(msg)
        end
      else
        if not vim.g.vscode then
          vim.notify("done")
        end
      end
    end,
  })
  local Job = require("plenary.job")
  Job:new(job):start()
end

---@param script string Bash script to run
---@param job Job
M.run_script = function(script, job)
  job = job or {}
  job = vim.tbl_deep_extend("force", job, {
    args = { "-c", script },
  })
  return M.run("bash", job)
end

return M
