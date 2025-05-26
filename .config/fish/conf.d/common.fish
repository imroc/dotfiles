abbr --add python python3
abbr --add pip pip3
abbr --add c "code -r"
abbr --add chrome "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
abbr --add m make
abbr --add duh 'du -sch * .*'

abbr --add typora "open -a typora"

abbr --add tf terraform

abbr --add bigfile "sudo find / -type f -size +100M -exec ls -lh {} \;"
abbr --add cosroc "coscli -c ~/.cos.image.yaml"
abbr --add lt "eza --icons --tree"
abbr --add l "eza --group --header --group-directories-first --long --binary --icons --all"

# 下载 go 依赖包
abbr --add gomd "go mod download -x"
# 下载 rust 依赖包
abbr --add cf "cargo fetch -vv"

# 覆盖 lazygit 在 MacOS 下的默认配置路径（~/Library/Application\ Support/jesseduffield/lazygit/config.yml）
set -gx XDG_CONFIG_HOME "$HOME/.config"

# 设置 locale 为中文，linux 与 macOS 通用
set -gx LANG "zh_CN.UTF-8"
set -gx LC_ALL "zh_CN.UTF-8"
