local M = {}

local function detect_root_dir(dir)
  if not dir then
    return {}
  end

  local git_cmd = {
    "git",
    "-C",
    dir,
    "rev-parse",
    "--show-toplevel",
  }

  local output = vim.fn.system(git_cmd)
  if vim.v.shell_error == 0 then -- 找到 git 仓库根目录
    local dir, _ = output:gsub("^%s*(.-)%s*$", "%1")
    if dir then
      -- 检查目录名称是否为 debug-roc
      local root_name = vim.fn.fnamemodify(dir, ":t")
      if root_name == "debug-roc" then
        -- 向上一级目录查找
        local parent_dir = vim.fn.fnamemodify(dir, ":h")
        return detect_root_dir(parent_dir)
      else
        return { dir }
      end
    end
  else -- 不在 git 仓库中
    local config_dir = vim.fn.expand("$HOME/.config")
    if dir:sub(1, #config_dir) == config_dir then -- 在配置目录中
      local relative_path = dir:sub(#config_dir + 2) -- +2 to skip the slash
      local subdir_name = relative_path:match("^([^/]+)")
      if subdir_name then
        return { config_dir .. "/" .. subdir_name }
      end
      return { config_dir }
    end
  end
  return {}
end

function M.detect_project_root(buf)
  if vim.bo.buftype == "" then
    local buf_name = vim.api.nvim_buf_get_name(buf)
    local dir = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":p:h") or vim.fn.getcwd()
    return detect_root_dir(dir)
  end
end

return M
