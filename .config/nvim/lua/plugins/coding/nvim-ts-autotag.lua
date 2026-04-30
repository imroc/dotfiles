return {
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup({
        per_filetype = {
          ["markdown"] = {
            enable_close = false,
          },
        },
      })
    end,
    lazy = true,
    event = "InsertEnter",
  },
}
