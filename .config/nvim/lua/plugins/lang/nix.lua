return {
  -- 补装 nixfmt：nix extra 只配了 conform formatters_by_ft（nix = { "nixfmt" }），
  -- 未配 Mason 安装，导致 ConformInfo 里 nixfmt unavailable（函数式追加避免
  -- ensure_installed 数组被 tbl_deep_extend 按索引合并顶掉）
  {
    "mason-org/mason.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "nixfmt" })
    end,
  },
}
