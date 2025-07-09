local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  -- bootstrap lazy.nvim
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    {
      "LazyVim/LazyVim",
      import = "lazyvim.plugins",
    },
    { import = "lazyvim.plugins.extras.vscode" },
    { import = "plugins" },
  },
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins will load during startup.
    -- If you know what you're doing, you can set this to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin that support versioning,
    -- have outdated releases, which may break your Neovim install.
    version = false, -- always use the latest git commit
    -- version = "*", -- try installing the latest stable version for plugins that support semver
  },
})

-- 定义全局变量保存输入法状态
vim.g.last_im_select = ""

-- 退出插入模式时：保存当前输入法 + 切换英文输入法
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  callback = function()
    -- 保存当前输入法状态 (需替换为你的英文输入法 ID)
    vim.g.last_im_select = vim.fn.system("im-select"):gsub("%s+", "")
    -- 强制切换到英文输入法 (需替换为你的英文输入法 ID)
    vim.fn.system("im-select com.apple.keylayout.ABC")
  end,
})

-- 进入插入模式时：恢复上次输入法
vim.api.nvim_create_autocmd("InsertEnter", {
  pattern = "*",
  callback = function()
    if vim.g.last_im_select ~= "" then
      vim.fn.system("im-select " .. vim.g.last_im_select)
    end
  end,
})

