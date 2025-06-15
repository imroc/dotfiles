if vim.g.vscode then
  return
end
-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

-- opt.conceallevel = 0 -- no hidden character
opt.clipboard = "unnamedplus"

opt.list = false -- 禁用显示不可见字符（比如 tab 展示成 >，比较丑陋）

-- disable auto format by default
vim.g.autoformat = false
-- diable diagnostic by default
vim.diagnostic.enable(false)

local function detect_git_root_dir(dir)
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
  local dir, _ = output:gsub("^%s*(.-)%s*$", "%1")
  if vim.v.shell_error == 0 and dir then
    -- 检查目录名称是否为 debug-roc
    local root_name = vim.fn.fnamemodify(dir, ":t")
    if root_name == "debug-roc" then
      -- 向上一级目录查找
      local parent_dir = vim.fn.fnamemodify(dir, ":h")
      return detect_git_root_dir(parent_dir)
    else
      return { dir }
    end
  else
    return {}
  end
end

-- 检测 git 项目根目录，如果是调试git目录（debug-roc)，则向上一级目录查找真正的 git 项目根目录
local function detect_project_git_root(buf)
  -- 获取当前文件路径并提取所在目录
  local buf_name = vim.api.nvim_buf_get_name(buf)
  local buf_dir = buf_name ~= "" and vim.fn.fnamemodify(buf_name, ":p:h") or vim.fn.getcwd()
  return detect_git_root_dir(buf_dir)
end

vim.g.root_spec = { detect_project_git_root, { ".git" }, "cwd" }
-- vim.g.root_spec = { "cwd" }

vim.g.maplocalleader = ","

-- 如果启用动画会导致 gg/G 可能无法移动到首行/尾行
vim.g.snacks_animate = false

if vim.env.SSH_TTY then
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
  }
end
