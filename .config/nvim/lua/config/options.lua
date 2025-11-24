if vim.g.vscode then
  return
end

if not vim.g.simpler_scrollback then
  vim.g.simpler_scrollback = vim.env.SIMPLER_SCROLLBACK or "default"
end

if not vim.g.neovim_mode then
  vim.g.neovim_mode = vim.env.NEOVIM_MODE or "default"
end

-- Conditional settings based on mode
if vim.g.neovim_mode == "skitty" then
  vim.opt.laststatus = 2
  vim.opt.statusline = "%m"

  -- Line numbers
  vim.opt.number = true
  vim.opt.relativenumber = true

  -- Disable the gutter
  vim.opt.signcolumn = "no"

  -- Text width and wrapping
  -- vim.opt.textwidth = 25
  vim.opt.textwidth = 80

  -- -- I tried these 2 with prettier prosewrap in "preserve" mode, and I'm not sure
  -- -- what they do, I think lines are wrapped, but existing ones are not, so if I
  -- -- have files with really long lines, they will remain the same, also LF
  -- -- characters were introduced at the end of each line, not sure, didn't test
  -- -- enough
  -- --
  -- -- Wrap lines at convenient points, this comes enabled by default in lazyvim
  vim.opt.linebreak = false

  -- Set to false by default in lazyvim
  -- If this is "false", when I'm typing around the 28/33 character, I see the screen
  -- scrolling to the right, and I don't want that, setting it to true seems to
  -- fix that
  -- Problem if set to true is that markdown links don't wrap, so they span
  -- across multiple lines
  vim.opt.wrap = false

  -- No colorcolumn in skitty
  vim.opt.colorcolumn = ""

  local colors = require("config.colors")
  -- -- Set the winbar to display "skitty-notes" with the specified color
  -- vim.opt.winbar = "%#WinBar1#   skitty-notes%*"
  -- -- Set the winbar to display the current file name on the left and "imroc.cc" aligned to the right
  -- vim.opt.winbar = "%#WinBar1# %t%*%=%#WinBar1# linkarzu.com %*"
  -- Set the winbar to display the current file name on the left (without the extension) and "imroc.cc" aligned to the right
  vim.opt.winbar = '%#WinBar1# %{luaeval(\'vim.fn.fnamemodify(vim.fn.expand("%:t"), ":r")\')}%*%=%#WinBar1# imroc.cc %*'
elseif vim.g.simpler_scrollback == "deeznuts" then
  -- disable winbar entirely
  vim.opt.winbar = ""
  -- Disable the gutter
  vim.opt.signcolumn = "no"
  -- Disables the statusbar at the bottom
  vim.opt.laststatus = 0
  -- No colorcolumn in skitty
  vim.opt.colorcolumn = ""
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
