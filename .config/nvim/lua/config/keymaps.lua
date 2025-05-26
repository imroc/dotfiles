if not LazyVim then
  return
end

if vim.g.vscode then
  return
end

require("config.keymaps.terminal")
require("config.keymaps.git")
require("config.keymaps.file")
require("config.keymaps.lang")
require("config.keymaps.editor")
require("config.keymaps.kube")
