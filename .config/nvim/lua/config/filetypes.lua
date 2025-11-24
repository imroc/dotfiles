local filetypes = {
  extension = {
    promql = "promql",
    service = "systemd",
    ets = "typescript",
    tmTheme = "xml",
    conflist = "json",
    ["kitty-session"] = "kitty",
  },
  filename = {
    ["PROJECT"] = "yaml",
    ["settings.json"] = "jsonc",
    ["keybindings.json"] = "jsonc",
    ["keymap.json"] = "jsonc",
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
