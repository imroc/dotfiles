# 修复微信输入法导致终端 IRM 被意外切换的问题
# fish_prompt: 切到 Insert Mode，确保命令行编辑是插入模式
# fish_preexec: 切回 Replace Mode，确保 TUI 程序（nvim、fzf 等）正常渲染
function __fix_irm_insert --on-event fish_prompt
    printf '\e[4h'
end

function __fix_irm_replace --on-event fish_preexec
    printf '\e[4l'
end
