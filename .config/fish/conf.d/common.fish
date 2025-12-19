abbr --add chrome "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
abbr --add m make
abbr --add duh 'du -sch * .*'

abbr --add typora "open -a typora"

abbr --add cb codebuddy-cli
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

# kitty 下使用 ssh 登录远程机器可能奇怪问题，用 ssh alias 解决: https://wiki.archlinux.org/title/Kitty#Terminal_issues_with_SSH
if test "$TERM" = xterm-kitty
    alias ssh="kitty +kitten ssh"
end
