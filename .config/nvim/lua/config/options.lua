if vim.g.vscode then
  return
end

-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local opt = vim.opt

-- opt.conceallevel = 0 -- no hidden character
opt.clipboard = "unnamedplus"

-- enable modeline even in root, but keep safe
opt.modeline = true
opt.modelines = 1
opt.modelineexpr = false

opt.list = false -- 禁用显示不可见字符（比如 tab 展示成 >，比较丑陋）

-- disable auto format by default
vim.g.autoformat = false
-- diable diagnostic by default
vim.diagnostic.enable(false)

local root = require("util.root")
vim.g.root_spec = { root.detect_project_root, { ".git" }, "cwd" }

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
