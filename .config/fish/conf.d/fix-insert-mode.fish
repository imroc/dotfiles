# 修复微信输入法在 Ghostty 终端中导致 Insert Mode 被切换为 Replace Mode 的问题
# 每次执行命令前自动重置为 Insert Mode（SM 4），防止吞字
function __fix_insert_mode --on-event fish_preexec
    printf '\e[4h'
end
