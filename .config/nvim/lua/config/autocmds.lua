---@diagnostic disable: undefined-global
---@diagnostic disable: undefined-field
-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- disable the default wrap and check for spell in LazyVim
vim.api.nvim_create_augroup("lazyvim_wrap_spell", { clear = true })

-- auto change cwd to root dir
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(ev)
    local root = LazyVim.root()
    if root == vim.uv.cwd() then
      return
    end
    vim.cmd("tcd " .. root)
  end,
})

-- setup yadm keymap for files under ~/.config
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("yadm_config_files", { clear = true }),
  callback = function(ev)
    local yadm = require("util.yadm")
    local config_dir = vim.fn.expand("$HOME/.config")
    local absolute_path = require("util.buffer").absolute_path()
    if vim.startswith(absolute_path, config_dir) then
      vim.keymap.set("n", "<leader>ga", function()
        require("util.yadm").git_add(absolute_path)
      end, {
        buffer = ev.buf,
        desc = "Yadm add current file",
      })
    end
  end,
})

-- 避免一些特殊的缓冲区被 LSP 处理导致报错
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    local bufname = vim.api.nvim_buf_get_name(event.buf)
    if bufname:find("^fugitive://") or bufname:find("^diffview://") then
      vim.schedule(function()
        vim.lsp.buf_detach_client(event.buf, event.data.client_id)
      end)
      return
    end
  end,
})
