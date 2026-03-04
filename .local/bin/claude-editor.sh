#!/usr/bin/env bash

if [[ -z "$ZELLIJ" ]]; then
  exec nvim "$@"
fi

# 命名管道作为同步信号，nvim 退出后写入即解除阻塞
pipe=$(mktemp -u /tmp/claude-editor-pipe.XXXXXX)
mkfifo "$pipe"

zellij run -n "提示词" -ci -- bash -c "nvim '+normal G$' +startinsert! \"$1\"; echo done > \"$pipe\""

# 阻塞等待管道写入
read <"$pipe"
rm -f "$pipe"
