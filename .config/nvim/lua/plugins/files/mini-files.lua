return {
  "echasnovski/mini.files",
  keys = {
    { "<leader>a", "<leader>fm", desc = "[P]Open mini.files (Directory of Current File)", remap = true },
    { "<leader>A", "<leader>fM", desc = "[P]Open mini.files (cwd)", remap = true },
  },
  init = function()
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

        map_dir_handler("<leader>a", nil, "[P]Toggle explorer", true)

        map_dir_handler("<localleader>s", function(dir)
          picker.grep({
            cwd = dir,
            regex = false,
          })
        end, "[P]Search Text", true)

        map_dir_handler("<localleader>f", function(dir)
          picker.files({ cwd = dir })
        end, "[P]Find Files", true)

        map_dir_handler("<localleader>z", function(dir)
          zellij.open_float(dir)
        end, "[P]Open Zellij", true)

        map_dir_handler("<localleader>t", function(dir)
          term.toggle(dir)
        end, "[P]Open Terminal", true)

        map_dir_handler("<localleader>r", function(dir)
          grugfar.open({
            prefills = {
              paths = dir,
            },
          })
        end, "[P]Replace", true)
      end,
    })
  end,
  opts = {
    windows = {
      preview = false,
    },
    mappings = {
      go_in_plus = "<CR>",
      go_in_horizontal_plus = "-",
      go_in_vertical_plus = "\\",
    },
  },
}
