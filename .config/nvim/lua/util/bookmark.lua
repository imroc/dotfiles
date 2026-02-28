---@diagnostic disable: undefined-global

local picker = require("util.picker")

local M = {}

local config_path = vim.fn.expand("$HOME/.config/j.yaml")

--- 解析 j.yaml，返回 { {alias, dir}, ... }
---@return {alias: string, dir: string}[]
function M.parse_bookmarks()
  local entries = {}
  local f = io.open(config_path, "r")
  if not f then
    return entries
  end
  for line in f:lines() do
    local alias, dir = line:match("^(%S+):%s*(.+)$")
    if alias and dir then
      dir = dir:gsub("^~", vim.env.HOME)
      table.insert(entries, { alias = alias, dir = dir })
    end
  end
  f:close()
  return entries
end

--- 弹出 alias 选择框，选中后回调 on_select(alias, dir)
---@param on_select fun(alias: string, dir: string)
function M.pick_alias(on_select)
  local bookmarks = M.parse_bookmarks()
  if #bookmarks == 0 then
    vim.notify("j.yaml 为空或不存在", vim.log.levels.WARN)
    return
  end

  local items = {}
  for _, b in ipairs(bookmarks) do
    table.insert(items, {
      text = b.alias .. "  " .. b.dir,
      alias = b.alias,
      dir = b.dir,
    })
  end

  Snacks.picker({
    title = "Jump Bookmarks",
    items = items,
    format = function(item)
      return {
        { item.alias, "Keyword" },
        { "  " },
        { item.dir, "Comment" },
      }
    end,
    confirm = function(p, item)
      p:close()
      if item then
        on_select(item.alias, item.dir)
      end
    end,
  })
end

--- <leader>fj: 选择 alias → 在对应目录下搜索文件
function M.find_files()
  M.pick_alias(function(_, dir)
    picker.files({ cwd = dir })
  end)
end

--- <leader>fJ: 选择 alias → 选择子目录 → 在子目录下搜索文件
function M.find_files_subdir()
  M.pick_alias(function(_, dir)
    Snacks.picker({
      title = "Select Subdirectory in " .. dir,
      finder = function(opts, ctx)
        return require("snacks.picker.source.proc").proc(
          ctx:opts({
            cmd = "fd",
            args = { "--type", "d", "--max-depth", "1", "--color", "never", "-E", ".git" },
            cwd = dir,
            ---@param item snacks.picker.finder.Item
            transform = function(item)
              item.file = dir .. "/" .. item.text
              item.dir = true
            end,
          }),
          ctx
        )
      end,
      confirm = function(p, item)
        p:close()
        if item then
          picker.files({ cwd = item.file })
        end
      end,
    })
  end)
end

return M
