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

-- function insert_at_cursor(text)
--   local cursor = vim.api.nvim_win_get_cursor(0)
--   vim.api.nvim_buf_set_text(0, cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2], { text })
--   vim.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] + #text })
-- end

function M.insert_image()
  local file_path = buffer.absolute_path()
  local Job = require("plenary.job")
  local result, code = Job:new({
    command = "iwiki.sh",
    args = { "upload", file_path },
  }):sync()

  local msg = ""
  if next(result) ~= nil then
    msg = table.concat(result, "\n")
  end

  if code == 0 then
    if next(result) ~= nil then
      vim.notify("successfully upload image to iwiki")
      vim.fn.setreg(vim.v.register, msg)
    else
      vim.notify("empty result", vim.log.levels.WARN)
    end
  else
    vim.notify("failed to upload image to iwiki:" .. msg, vim.log.levels.ERROR)
  end
end

return M
