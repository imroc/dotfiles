if vim.env.USER ~= "roc" and vim.fn.hostname() ~= "VM-55-160-tencentos" and vim.fn.hostname() ~= "devcontainer" then -- 只允许笔记本和 devcloud 机器使用工蜂 Copilot
  return {}
end

-- https://git.woa.com/help/menu/solutions/copilot.html#_5-vim-neovim
return {
  "gongfeng-copilot",
  url = "git@git.woa.com:rockerchen/gongfeng-copilot.git",
  enabled = vim.g.simpler_scrollback ~= "deeznuts",
  lazy = true,
  event = "InsertEnter",
  cond = function()
    local absolute_path = require("util.buffer").absolute_path()
    if string.match(absolute_path, "secret") then
      return false
    end
    return true
  end,
}
