# ── ghostty scrollback copy mode (仅 ghostty 原生环境) ─────────────────
#
# 工作原理:
#   ghostty keybind Cmd+I 触发 write_screen_file:copy + chain=new_split:right
#   1. ghostty 将屏幕内容写入临时文件（路径格式 /T/.../screen.txt）
#   2. 文件路径自动存入系统剪贴板
#   3. chain=new_split:right 在右侧创建新 split
#   4. 新 split 启动 fish，此钩子在启动时执行
#   5. 钩子检测到剪贴板中的临时文件路径，自动用 nvim 打开
#
# cmux 环境下不触发:
#   cmux 中 Cmd+I 由 Karabiner 拦截，执行 ~/.local/bin/cmux-scrollback-copy
#   即使 ghostty keybind 意外触发，此钩子也通过 CMUX_SURFACE_ID 判断跳过
#
# 相关文件:
#   - ~/.config/ghostty/config             — Cmd+I keybind 定义
#   - ~/.local/bin/ghostty-scrollback-copy — nvim 打开脚本（yank 后自动退出）
#   - ~/.local/bin/cmux-scrollback-copy    — cmux 环境专用脚本
#   - ~/.config/karabiner/karabiner.json   — cmux 环境 Cmd+I 拦截规则
# ──────────────────────────────────────────────────────────────────────────
if status is-interactive; and set -q GHOSTTY_RESOURCES_DIR; and not set -q CMUX_SURFACE_ID
    set -l clip (pbpaste 2>/dev/null)
    if test -f "$clip"; and string match -rq '/T/.+/(screen|history)\.txt$' "$clip"
        # 最大化新 split（Cmd+Enter = toggle_split_zoom）使其全屏显示
        osascript -e 'tell application "System Events" to keystroke return using command down' &
        exec ghostty-scrollback-copy
    end
end
