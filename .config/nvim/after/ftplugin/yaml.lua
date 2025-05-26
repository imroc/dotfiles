local get_fx_script = function()
  local buffer = require("util.buffer")
  local filename = buffer.absolute_path()
  return "yaml2json < " .. filename .. " | fx"
end

vim.keymap.set("n", "<localleader>f", function()
  local term = require("util.term")
  term.run_script(get_fx_script(), { close_on_exit = true })
end, { buffer = 0, desc = "[P]View yaml with fx using lazyterm" })

vim.keymap.set("n", "<localleader>F", function()
  local zellij = require("util.zellij")
  local buffer = require("util.buffer")
  zellij.run_script(get_fx_script(), { name = buffer.file_name(), close_on_exit = true })
end, { buffer = 0, desc = "[P]View yaml with fx using zellij" })
