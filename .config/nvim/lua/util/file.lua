---@diagnostic disable: undefined-global
-- Used for sync markdown file to tencent iwiki (tencent internal wiki platform)
local M = {}

function M.rename()
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
            -- format with jq
            vim.fn.system({ "jq", ".", iwiki_path, "--sort-keys", "-o", iwiki_path })
            vim.notify("Renamed file and updated iwiki.json", vim.log.levels.INFO)
            return
          end
        end
      end
    else
      vim.notify("Renamed file", vim.log.levels.INFO)
    end
  end)
end

return M
