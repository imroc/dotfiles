# ghostty scrollback copy mode
# 配合 Ghostty keybind:
#   super+i: write_screen_file:copy   → 当前屏幕内容
#   super+y: write_scrollback_file:copy → 完整 scrollback 历史
# 两者都会 new_split:right，新 split 启动时检测剪贴板中的临时文件路径，自动用 nvim 打开
if status is-interactive; and set -q GHOSTTY_RESOURCES_DIR
    set -l clip (pbpaste 2>/dev/null)
    if test -f "$clip"; and string match -rq '/T/.+/(screen|history)\.txt$' "$clip"
        # 最大化新 split（Cmd+Enter = toggle_split_zoom）
        osascript -e 'tell application "System Events" to keystroke return using command down' &
        exec ghostty-scrollback-copy
    end
end
