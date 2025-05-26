local filetypes = {
  extension = {
    promql = "promql",
    service = "systemd",
    ets = "typescript",
    tmTheme = "xml",
  },
  filename = {
    ["PROJECT"] = "yaml",
    ["settings.json"] = "jsonc",
    ["keybindings.json"] = "jsonc",
    ["keymap.json"] = "jsonc",
    -- [".gitalias"] = "gitconfig",
  },
  pattern = {
    [".*Dockerfile.*"] = "dockerfile",
    [".*kube/config"] = "yaml",
    [".*ssh/config"] = "sshconfig",
    [".*argocd/config"] = "yaml",
    [".*ghostty/config"] = "toml",
    [".*aws/config"] = "toml",
    [".*aws/credentials"] = "toml",
  },
}

vim.filetype.add(filetypes)
