abbr --add chrome "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
abbr --add m make

abbr --add typora "open -a typora"
abbr --add tf terraform
abbr --add ta "terraform apply -auto-approve"
abbr --add td "terraform apply -destroy -auto-approve"

abbr --add bigfile "sudo find / -type f -size +100M -exec ls -lh {} \;"
abbr --add cosroc "coscli -c ~/.cos.image.yaml"

# 覆盖 lazygit 在 MacOS 下的默认配置路径（~/Library/Application\ Support/jesseduffield/lazygit/config.yml）
set -gx XDG_CONFIG_HOME "$HOME/.config"

# 设置 locale 为中文，linux 与 macOS 通用
set -gx LANG "zh_CN.UTF-8"
set -gx LC_ALL "zh_CN.UTF-8"

# 默认编辑器设为 neovim（许多 cli 工具会读这个 env，如 git、zellij、k9s 等）
set -gx EDITOR nvim

# man 默认使用 neovim 打开
set -gx MANPAGER 'nvim +Man!'

# task 启用远程 include
set -gx TASK_X_REMOTE_TASKFILES 1

# kitty 下使用 ssh 登录远程机器可能奇怪问题，用 ssh alias 解决: https://wiki.archlinux.org/title/Kitty#Terminal_issues_with_SSH
alias kssh="kitten ssh"

# Homebrew: 抑制各种 env hints（tap trust 警告、cleanup 自动运行提示等啰嗦信息），不影响真正的报错
set -gx HOMEBREW_NO_ENV_HINTS 1
# Homebrew: 保持"非官方 tap 默认信任"行为，未来 Homebrew 升级也不强制要求显式 trust（已安装的非官方 tap 都是有意为之）
set -gx HOMEBREW_NO_REQUIRE_TAP_TRUST 1
