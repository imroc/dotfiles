local M = {}

function M.setup(keymaps)
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(args)
      local buf_id = args.data.buf_id
      local grugfar = require("grug-far")
      local picker = require("util.picker")
      local zellij = require("util.zellij")
      local term = require("util.term")
      local get_dir = function()
        local curr_entry = MiniFiles.get_fs_entry()
        if curr_entry then
          return curr_entry.fs_type == "directory" and curr_entry.path or vim.fn.fnamemodify(curr_entry.path, ":h") -- Use parent directory if entry is a file
        end
      end
      local map_dir_handler = function(lhs, handler, desc, close)
        vim.keymap.set("n", lhs, function()
          local dir = get_dir()
          if not dir then
            return
          end
          if close then
            MiniFiles.close()
          end
          if handler then
            handler(dir)
          end
        end, { buffer = buf_id, desc = desc })
      end

      if keymaps.toggle_explorer then
        map_dir_handler(keymaps.toggle_explorer, nil, "[P]Toggle explorer", true)
      end

      if keymaps.search_text then
        map_dir_handler(keymaps.search_text, function(dir)
          picker.grep({
            cwd = dir,
            regex = false,
          })
        end, "[P]Search Text", true)
      end

      if keymaps.find_files then
        map_dir_handler(keymaps.find_files, function(dir)
          picker.files({ cwd = dir })
        end, "[P]Find Files", true)
      end

      if keymaps.open_zellij then
        map_dir_handler(keymaps.open_zellij, function(dir)
          zellij.open_float(dir)
        end, "[P]Open Zellij", true)
      end

      if keymaps.open_terminal then
        map_dir_handler(keymaps.open_terminal, function(dir)
          term.toggle(dir)
        end, "[P]Open Terminal", true)
      end

      if keymaps.replace then
        map_dir_handler(keymaps.replace, function(dir)
          grugfar.open({
            prefills = {
              paths = dir,
            },
          })
        end, "[P]Replace", true)
      end
    end,
  })
end

return M
