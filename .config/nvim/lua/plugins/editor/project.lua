return {
  {
    "ahmedkhalf/project.nvim",
    enabled = vim.g.simpler_scrollback ~= "deeznuts",
    opts = {
      manual_mode = true,
      detection_methods = { "pattern", "lsp" },
      patterns = {
        ".git",
        -- "_darcs",
        ".hg",
        -- ".bzr",
        ".svn",
        "Makefile",
        -- "package.json",
        -- "pom.xml",
        ".repo",
      },
    },
    keys = {
      {
        "<C-p>",
        function()
          Snacks.picker.projects()
        end,
        desc = "[P]Projects",
      },
    },
  },
}
