local clipboard = require("util.clipboard")
local job = require("util.job")

-- copy file path
vim.keymap.set("n", "<leader>yf", clipboard.copy_absolute_path, { desc = "[P]Copy Absolute Path" })
vim.keymap.set("n", "<leader>yn", clipboard.copy_filename, { desc = "[P]Copy Filename" })
vim.keymap.set("n", "<leader>yr", clipboard.copy_relative_path, { desc = "[P]Copy Relative Path" })
vim.keymap.set("n", "<leader>yR", clipboard.copy_current_root_directory, { desc = "[P]Copy Current Root Directory" })
vim.keymap.set("n", "<leader>yd", clipboard.copy_current_directory, { desc = "[P]Copy Current Directory" })

-- file permission
vim.keymap.set("n", "<leader>fx", "<cmd>!chmod +x %<cr>", { desc = "[P]Add executable permission" })

-- yazi
vim.keymap.set("n", "<leader>yZ", function()
  require("util.zellij").run({ "yazi", require("util.buffer").current_dir() }, { name = "yazi" })
end, { desc = "[P]Open Yazi (Zellij)" })

vim.keymap.set("n", "<leader>oc", function()
  job.run("code", { args = { "-r", LazyVim.root() } })
end, { desc = "[P]Open VSCode (Root Dir)" })

vim.keymap.set("n", "<leader>oz", function()
  job.run("zed", { args = { LazyVim.root() } })
end, { desc = "[P]Open Zed (Root Dir)" })

vim.keymap.set("n", "<leader>on", function()
  job.run("neovide", { args = { LazyVim.root() } })
end, { desc = "[P]Open Neovide (Root Dir)" })

vim.keymap.set("n", "<leader>ob", function()
  job.run("buddycn", { args = { "-r", LazyVim.root() } })
end, { desc = "[P]Open CodeBuddy (Root Dir)" })

-- rename file with iwiki.json sync
vim.keymap.set("n", "<leader>rn", function()
  local current_file = vim.fn.expand("%:p")
  local current_dir = vim.fn.expand("%:p:h")
  local current_name = vim.fn.expand("%:t:r") -- filename without extension
  local current_ext = vim.fn.expand("%:e")

  vim.ui.input({ prompt = "New filename: ", default = vim.fn.expand("%:t") }, function(new_name)
    if not new_name or new_name == "" or new_name == vim.fn.expand("%:t") then
      return
    end

    local new_file = current_dir .. "/" .. new_name
    local new_name_without_ext = new_name:match("(.+)%..+$") or new_name

    -- rename the file
    local ok, err = os.rename(current_file, new_file)
    if not ok then
      vim.notify("Failed to rename file: " .. err, vim.log.levels.ERROR)
      return
    end

    -- update buffer to new file
    vim.cmd("edit " .. vim.fn.fnameescape(new_file))
    vim.cmd("bdelete " .. vim.fn.bufnr(current_file))

    -- check and update iwiki.json if needed
    if current_ext == "md" then
      local iwiki_path = current_dir .. "/iwiki.json"
      local iwiki_file = io.open(iwiki_path, "r")
      if iwiki_file then
        local content = iwiki_file:read("*a")
        iwiki_file:close()

        local iwiki = vim.json.decode(content)
        if iwiki and iwiki[current_name] then
          local page_id = iwiki[current_name]
          iwiki[current_name] = nil
          iwiki[new_name_without_ext] = page_id

          local out_file = io.open(iwiki_path, "w")
          if out_file then
            out_file:write(vim.json.encode(iwiki))
            out_file:close()
            vim.notify("Renamed file and updated iwiki.json", vim.log.levels.INFO)
            return
          end
        end
      end
    else
      vim.notify("Renamed file", vim.log.levels.INFO)
    end
  end)
end, { desc = "[P]Rename file" })
