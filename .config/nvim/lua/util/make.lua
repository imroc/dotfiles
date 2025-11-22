---@diagnostic disable: missing-fields

local M = {}

local Job = require("plenary.job")
local job = require("util.job")
local buffer = require("util.buffer")
local term = require("util.term")
local zellij = require("util.zellij")
local run_target = function(run)
  local result, code = Job
    :new({
      command = "bash",
      args = {
        "-c",
        [[make -f ]]
          .. buffer.file_name()
          .. [[ -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | grep -Ev '^Makefile$' | sort -u ]],
      },
      cwd = buffer.current_dir(),
    })
    :sync(10000)

  if code ~= 0 then
    return
  end
  if not result then
    return
  end
  Snacks.picker.select(result, { prompt = "Run Target" }, function(target)
    if target then
      run(target)
    end
  end)
end

function M.run_in_terminal_or_zellij(close_on_exit)
  if os.getenv("ZELLIJ") then
    M.run_in_zellij(close_on_exit)
  else
    M.run_in_terminal(close_on_exit)
  end
end

function M.run_in_background()
  run_target(function(target)
    job.run("make", {
      args = { "-f", buffer.file_name(), target },
      cwd = buffer.current_dir(),
    })
  end)
end

function M.run_in_terminal(close_on_exit)
  run_target(function(target)
    term.run_script(
      "cd " .. buffer.current_dir() .. " && make -f " .. buffer.file_name() .. " " .. target,
      { cwd = buffer.current_dir(), close_on_exit = close_on_exit }
    )
  end)
end

function M.run_in_zellij(close_on_exit)
  run_target(function(target)
    zellij.run(
      { "make", "-f", buffer.file_name(), target },
      { name = "make " .. target, close_on_exit = close_on_exit }
    )
  end)
end

return M
