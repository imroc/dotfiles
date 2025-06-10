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
        end, { buffer = buf_id, noremap = true, silent = true, desc = desc })
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

      -- Copy the current file or directory to the lamw25wmal system clipboard
      -- NOTE: This works only on macOS
      if keymaps.copy_to_clipboard then
        vim.keymap.set("n", keymaps.copy_to_clipboard, function()
          -- Get the current entry (file or directory)
          local curr_entry = MiniFiles.get_fs_entry()
          if curr_entry then
            local path = curr_entry.path
            -- Build the osascript command to copy the file or directory to the clipboard
            local cmd = string.format([[osascript -e 'set the clipboard to POSIX file "%s"' ]], path)
            local result = vim.fn.system(cmd)
            if vim.v.shell_error ~= 0 then
              vim.notify("Copy failed: " .. result, vim.log.levels.ERROR)
            else
              vim.notify(vim.fn.fnamemodify(path, ":t"), vim.log.levels.INFO)
              vim.notify("Copied to system clipboard", vim.log.levels.INFO)
            end
          else
            vim.notify("No file or directory selected", vim.log.levels.WARN)
          end
        end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Copy file/directory to clipboard" })
      end

      -- Paste the current file or directory from the system clipboard into the current directory in mini.files
      -- NOTE: This works only on macOS
      if keymaps.paste_from_clipboard then
        map_dir_handler(keymaps.paste_from_clipboard, function(dir)
          local script = [[
            tell application "System Events"
              try
                set theFile to the clipboard as alias
                set posixPath to POSIX path of theFile
                return posixPath
              on error
                return "error"
              end try
            end tell
          ]]
          local output = vim.fn.system("osascript -e " .. vim.fn.shellescape(script)) -- Execute AppleScript command
          if vim.v.shell_error ~= 0 or output:find("error") then
            vim.notify("Clipboard does not contain a valid file or directory.", vim.log.levels.WARN)
            return
          end
          local source_path = output:gsub("%s+$", "") -- Trim whitespace from clipboard output
          if source_path == "" then
            vim.notify("Clipboard is empty or invalid.", vim.log.levels.WARN)
            return
          end
          local dest_path = dir .. "/" .. vim.fn.fnamemodify(source_path, ":t") -- Destination path in current directory
          local copy_cmd = vim.fn.isdirectory(source_path) == 1 and { "cp", "-R", source_path, dest_path }
            or { "cp", source_path, dest_path } -- Construct copy command
          local result = vim.fn.system(copy_cmd) -- Execute the copy command
          if vim.v.shell_error ~= 0 then
            vim.notify("Paste operation failed: " .. result, vim.log.levels.ERROR)
            return
          end
          -- vim.notify("Pasted " .. source_path .. " to " .. dest_path, vim.log.levels.INFO)
          MiniFiles.synchronize() -- Refresh mini.files to show updated directory content
          vim.notify("Pasted successfully.", vim.log.levels.INFO)
        end, "[P]Paste from clipboard", false)
      end

      -- Copy the current file or directory path (relative to home) to clipboard
      if keymaps.copy_path then
        vim.keymap.set("n", keymaps.copy_path, function()
          -- Get the current entry (file or directory)
          local curr_entry = MiniFiles.get_fs_entry()
          if curr_entry then
            -- Convert path to be relative to home directory
            local home_dir = vim.fn.expand("~")
            local relative_path = curr_entry.path:gsub("^" .. home_dir, "~")
            vim.fn.setreg("+", relative_path) -- Copy the relative path to the clipboard register
            vim.notify(vim.fn.fnamemodify(relative_path, ":t"), vim.log.levels.INFO)
            vim.notify("Path copied to clipboard: ", vim.log.levels.INFO)
          else
            vim.notify("No file or directory selected", vim.log.levels.WARN)
          end
        end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Copy relative path to clipboard" })
      end

      -- Preview the selected image in macOS Quick Look
      --
      -- NOTE: This is for macOS, to preview in a neovim popup see below
      --
      -- This wonderful Idea was suggested by @iduran in my youtube video:
      -- https://youtu.be/BzblG2eV8dU
      --
      -- Don't use "i" as it conflicts wit "insert"
      if keymaps.preview_image then
        vim.keymap.set("n", keymaps.preview_image, function()
          local curr_entry = MiniFiles.get_fs_entry()
          if curr_entry then
            -- Preview the file using Quick Look
            vim.system({ "qlmanage", "-p", curr_entry.path }, {
              stdout = false,
              stderr = false,
            })
            -- Activate Quick Look window after a small delay
            vim.defer_fn(function()
              vim.system({ "osascript", "-e", 'tell application "qlmanage" to activate' })
            end, 200)
          else
            vim.notify("No file selected", vim.log.levels.WARN)
          end
        end, { buffer = buf_id, noremap = true, silent = true, desc = "[P]Preview with macOS Quick Look" })
      end
    end,
  })
end

return M
