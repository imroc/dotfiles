local M = {}

local Outline = require("outline")

function M.goto_localtion()
  local sidebar = Outline._get_sidebar()
  if sidebar then --  有 sidebar，直接跳转
    if sidebar.view:is_open() then
      sidebar:__goto_location(true)
    else
      sidebar:open({ focus_outline = false })
      vim.defer_fn(function()
        sidebar:__goto_location(true)
      end, 100)
    end
  else -- 没有 sidebar，先创建一个，再跳转
    Outline.open_outline({ focus_outline = false })
    sidebar = Outline._get_sidebar()
    if sidebar then
      vim.defer_fn(function()
        sidebar:__goto_location(true)
      end, 100)
    else
      vim.notify("failed to create outline sidebar")
    end
  end
end

return M
