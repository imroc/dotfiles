vim.keymap.set("n", "<localleader>f", function()
  local term = require("util.term")
  local buffer = require("util.buffer")
  term.run_script("cfssl certinfo -cert " .. buffer.absolute_path() .. " | fx", { close_on_exit = true })
end, { buffer = 0, desc = "[P]View json with fx using lazyterm" })

vim.keymap.set("n", "<localleader>F", function()
  local zellij = require("util.zellij")
  local buffer = require("util.buffer")
  zellij.run_script(
    "cfssl certinfo -cert " .. buffer.absolute_path() .. " | fx",
    { close_on_exit = true, name = buffer.file_name() }
  )
end, { buffer = 0, desc = "[P]View json with fx using zellij" })

vim.keymap.set("n", "<localleader>o", function()
  local buffer = require("util.buffer")
  local Job = require("plenary.job")
  local job = Job:new({
    command = "openssl",
    args = { "x509", "-text", "-noout", "-in", buffer.absolute_path() },
  })
  job:sync()
  local err = job:stderr_result()
  if next(err) ~= nil then
    local err_msg = table.concat(err, "\n")
    vim.notify(err_msg, vim.log.levels.ERROR, { title = "openssl x509" })
    return
  end
  local result = job:result()
  local window = require("util.window")
  local win, buf = window.vsplit()
  vim.api.nvim_win_set_buf(win, buf)
  -- vim.api.nvim_buf_set_name(buf, "openssl x509 for " .. buffer.file_name())
  vim.api.nvim_buf_set_lines(buf, 0, -1, true, result)
end, { buffer = 0, desc = "[P]View cert info with openssl" })
