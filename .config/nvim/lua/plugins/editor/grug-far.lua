return {
  -- https://github.com/MagicDuck/grug-far.nvim
  "MagicDuck/grug-far.nvim",
  init = function()
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("grug-far-keybindings", { clear = true }),
      pattern = { "grug-far" },
      callback = function()
        vim.keymap.set("n", "<localleader>F", function()
          local state = unpack(require("grug-far").get_instance(0):toggle_flags({ "--fixed-strings" }))
          vim.notify("grug-far: toggled --fixed-strings " .. (state and "ON" or "OFF"))
        end, { buffer = true, desc = "[P]Toggle --fixed-strings" })
        vim.keymap.set("n", "<localleader>I", function()
          local state = unpack(require("grug-far").get_instance(0):toggle_flags({ "--ignore-case" }))
          vim.notify("grug-far: toggled --ignore-case " .. (state and "ON" or "OFF"))
        end, { buffer = true, desc = "[P]Toggle --ignore-case" })
        vim.keymap.set("n", "<C-enter>", function()
          require("grug-far").get_instance(0):open_location()
          require("grug-far").get_instance(0):close()
        end, { buffer = true })
        -- ---@alias GrugFarInputName "search" | "rules" | "replacement" | "filesFilter" | "flags" | "paths"
        vim.keymap.set("n", "<localleader>1", function()
          require("grug-far").get_instance(0):goto_first_input()
        end, { buffer = true, desc = "[P]Goto First Input (Search)" })
        vim.keymap.set("n", "<localleader>2", function()
          require("grug-far").get_instance(0):goto_input("replacement")
        end, { buffer = true, desc = "[P]Goto Second Input (Repalce)" })
        vim.keymap.set("n", "<localleader>3", function()
          require("grug-far").get_instance(0):goto_input("filesFilter")
        end, { buffer = true, desc = "[P]Goto Third Input (Files Filter)" })
        vim.keymap.set("n", "<localleader>]", function()
          require("grug-far").get_instance(0):goto_next_input()
        end, { buffer = true, desc = "[P]Goto Next Input" })
        vim.keymap.set("n", "<localleader>[", function()
          require("grug-far").get_instance(0):goto_prev_input()
        end, { buffer = true, desc = "[P]Goto Prev Input" })
        vim.keymap.set("n", "<localleader>m", function()
          require("grug-far").get_instance(0):goto_next_match()
        end, { buffer = true, desc = "[P]Goto Next Match" })
      end,
    })
  end,
  keys = {
    { "<leader>r", "", desc = "+[P]replace", mode = { "n", "v" } },
    {
      "<leader>rs",
      function()
        require("grug-far").open({
          visualSelectionUsage = "operate-within-range",
        })
      end,
      mode = "v",
      desc = "[P]Replace in Selected Range",
    },
    {
      "<leader>rf",
      function()
        require("grug-far").open({
          prefills = {
            paths = vim.fn.expand("%"),
          },
        })
      end,
      mode = { "n", "v" },
      desc = "[P]Replace in Current File",
    },
    {
      "<leader>rd",
      function()
        require("grug-far").open({
          prefills = {
            paths = require("util.buffer").current_dir(),
          },
        })
      end,
      mode = { "n", "v" },
      desc = "[P]Replace in Current Directory",
    },
    {
      "<leader>rr",
      function()
        require("grug-far").open({
          prefills = {
            paths = LazyVim.root(),
          },
        })
      end,
      mode = { "n", "v" },
      desc = "[P]Replace in Root Directory",
    },
  },
}
