if vim.env.USER ~= "roc" and vim.fn.hostname() ~= "VM-55-160-tencentos" and vim.fn.hostname() ~= "devcontainer" then -- 只允许笔记本和 devcloud 机器使用工蜂 Copilot
  return {}
end

return {
  "gongfeng-copilot",
  url = "git@git.woa.com:felikszhou/gongfeng-operation-platform.git",
  enabled = vim.g.simpler_scrollback ~= "deeznuts",
  lazy = true,
  event = "InsertEnter",
  cmd = { "CodeBuddy" },
  cond = function()
    local absolute_path = require("util.buffer").absolute_path()
    if string.match(absolute_path, "secret") then
      return false
    end
    return true
  end,
}
