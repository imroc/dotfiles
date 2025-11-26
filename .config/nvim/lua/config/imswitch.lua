local M = {}

-- 发送系统快捷键的函数
local function send_hotkey(keys)
  -- 使用AppleScript发送组合键
  local script = string.format(
    [[
        tell application "System Events"
            keystroke "%s" using {shift down, option down, command down}
        end tell
    ]],
    keys
  )

  -- 异步执行，避免阻塞Neovim
  vim.fn.jobstart({ "osascript", "-e", script }, {
    detach = true,
    on_exit = function() end,
  })
end

-- Normal模式触发 Shift+Option+Command+Y
local function on_normal_mode()
  send_hotkey("y")
  vim.notify("进入Normal模式", vim.log.levels.INFO)
end

-- Insert模式触发 Shift+Option+Command+P
local function on_insert_mode()
  send_hotkey("p")
  vim.notify("进入Insert模式", vim.log.levels.INFO)
end

function M.setup()
  -- 设置自动命令
  local group = vim.api.nvim_create_augroup("ModeSwitchHotkeys", { clear = true })

  -- 进入Normal模式时触发
  vim.api.nvim_create_autocmd({ "ModeChanged" }, {
    group = group,
    pattern = "*:*",
    callback = function(args)
      local current_mode = vim.api.nvim_get_mode().mode
      local previous_mode = args.match:match(".*:(.)")

      -- 从插入模式切换到普通模式
      if (previous_mode == "i" or previous_mode == "c") and current_mode == "n" then
        vim.defer_fn(on_normal_mode, 10) -- 延迟10ms执行，确保模式切换完成
      end
    end,
  })

  -- 进入Insert模式时触发
  vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    group = group,
    callback = function(args)
      -- 从普通模式切换到插入模式
      vim.defer_fn(on_insert_mode, 10)
    end,
  })

  -- 初始启动时也设置一次
  vim.api.nvim_create_autocmd({ "InsertLeave", "CmdlineLeave" }, {
    group = group,
    callback = function()
      if vim.api.nvim_get_mode().mode == "n" then
        on_normal_mode()
      end
    end,
  })
end

-- 手动触发函数（用于测试）
function M.trigger_normal()
  send_hotkey("y")
end

function M.trigger_insert()
  send_hotkey("p")
end

return M
