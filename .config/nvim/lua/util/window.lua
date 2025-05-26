local M = {}

local closable_filetypes = {
  "noice",
  "help",
  "snacks_terminal",
  "grug-far",
}

local closable_filetypes_map = {}
for _, ft in ipairs(closable_filetypes) do
  closable_filetypes_map[ft] = true
end

local function close_windows()
  local wins = vim.api.nvim_list_wins()
  for _, winid in ipairs(wins) do
    if vim.api.nvim_win_is_valid(winid) then
      local bufnr = vim.api.nvim_win_get_buf(winid)
      local ft = vim.api.nvim_get_option_value("filetype", { buf = bufnr })
      if closable_filetypes_map[ft] then
        vim.api.nvim_win_close(winid, true)
      end
    end
  end
end

---create a vsplit buffer in the current window
---@return integer
---@return integer
M.vsplit = function()
  vim.api.nvim_command("vsplit")
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_create_buf(true, true)
  return win, buf
end

M.clear = function()
  vim.cmd("cclose")
  vim.cmd("lclose")
  vim.cmd("noh")
  local trouble = package.loaded["trouble"]
  if trouble then
    trouble.close()
  end
  local noice = package.loaded["noice"]
  if noice then
    noice.cmd("dismiss")
  end
  local outline = package.loaded["outline"]
  if outline then
    if outline.is_open() then
      outline.close()
    end
  end
  -- local neotree = package.loaded["neo-tree.command"]
  -- if neotree then
  --   neotree.execute({ action = "close" })
  -- end
  close_windows()
end

return M
