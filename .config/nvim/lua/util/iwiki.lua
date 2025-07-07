---@diagnostic disable: undefined-global
-- Used for sync markdown file to tencent iwiki (tencent internal wiki platform)
local M = {}

local buffer = require("util.buffer")
local job = require("util.job")

function M.save_iwiki()
  local file_path = buffer.absolute_path()
  job.run_script('iwiki.sh save "' .. file_path .. '"', {
    on_exit = function(job, code, signal)
      if code == 0 then
        vim.notify("Successfully synced to iwiki")
      else
        local result = job:stderr_result()
        if next(result) == nil then
          result = job:result()
        end
        if next(result) ~= nil then
          local msg = table.concat(result, "\n")
          vim.notify(msg)
        end
      end
    end,
  })
end

function M.open_iwiki()
  local file_path = buffer.absolute_path()
  job.run_script('iwiki.sh open "' .. file_path .. '"')
end

return M
