local get_node_dir = function(state)
  local tree = state.tree
  local node = tree:get_node()
  local path = node:get_id()
  if node.type == "directory" then
    return path
  else
    return string.match(path, "(.+)/[^/]+$")
  end
end

local picker = require("util.picker")

return {
  -- https://github.com/nvim-neo-tree/neo-tree.nvim
  "nvim-neo-tree/neo-tree.nvim",
  lazy = true,
  keys = {
    { "<leader>E", false },
    { "<leader>e", false },
  },
  opts = {
    source_selector = {
      winbar = true, -- toggle to show selector on winbar
      statusline = true, -- toggle to show selector on statusline
    },
    commands = {
      prev_tab = function()
        vim.api.nvim_input("<C-l><S-h>")
      end,
      next_tab = function()
        vim.api.nvim_input("<C-l><S-l>")
      end,
    },
    window = {
      -- position = "right", -- left, right, top, bottom, float, current
      mappings = {
        ["z"] = "none", -- 让 zz 居中能够生效
        ["W"] = "close_all_nodes",
        -- 让左右切换 buffer 在 neo-tree 下也能生效
        ["H"] = "prev_tab",
        ["L"] = "next_tab",
      },
    },
    filesystem = {
      -- LazyRoot 同步到 cwd，即然 root 与 cwd 相同，避免一些不一致问题，比如用 snacks.nvim 搜索的结果给 trouble 打开，最终无法定位文件
      bind_to_cwd = true,
      commands = {
        go_zellij = function(state)
          require("util.zellij").open_float(get_node_dir(state))
        end,
        go_terminal = function(state)
          require("util.term").toggle(get_node_dir(state))
        end,
      },
      window = {
        mappings = {
          ["gf"] = {
            function(state)
              require("util.picker").files({ cwd = get_node_dir(state) })
            end,
            desc = "Find Files",
          },
          ["gr"] = {
            function(state)
              require("grug-far").open({
                prefills = {
                  paths = get_node_dir(state),
                },
              })
            end,
            desc = "Search and Replace",
          },
          ["gs"] = {
            function(state)
              picker.grep({
                cwd = get_node_dir(state),
                regex = false,
              })
            end,
            desc = "Search File Content (Plain Text)",
          },
          ["gS"] = {
            function(state)
              picker.grep({
                cwd = get_node_dir(state),
              })
            end,
            desc = "Search File Content",
          },
          ["gt"] = {
            function(state)
              require("util.term").toggle(get_node_dir(state))
            end,
            desc = "Open Terminal",
          },
          ["gz"] = {
            function(state)
              require("util.zellij").open_float(get_node_dir(state))
            end,
            desc = "Open Floating Zellij Pane",
          },
          ["h"] = "toggle_hidden",
        },
      },
      filtered_items = {
        visible = true,
        never_show = {
          ".git",
        },
      },
    },
  },
}
