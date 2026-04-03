# ghostty scrollback copy mode
# 配合 Ghostty keybind (super+y): write_scrollback_file:copy → new_split:right
# 新 split 启动时检测剪贴板中是否有刚生成的 scrollback 文件，有则自动打开 nvim
if status is-interactive; and set -q GHOSTTY_RESOURCES_DIR
    set -l clip (pbpaste 2>/dev/null)
    if test -f "$clip"; and string match -rq '/T/.+/history\.txt$' "$clip"
        # 最大化新 split（Cmd+Enter = toggle_split_zoom）
        osascript -e 'tell application "System Events" to keystroke return using command down' &
        exec ghostty-scrollback-copy
    end
end
