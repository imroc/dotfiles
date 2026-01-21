#!/bin/bash

# 查找所有 nvim 进程的 PID
pids=$(pgrep -f nvim)

if [ -z "$pids" ]; then
  echo "没有找到正在运行的 nvim 进程。"
  exit 0
fi

echo "找到以下 nvim 进程："

# 使用 BSD ps 兼容方式显示进程信息（避免 -o）
# 方法1：直接用 pgrep 显示
echo "$pids" | while read pid; do
  cmd=$(ps -p $pid -o comm=)
  ppid=$(ps -p $pid -o ppid=)
  echo "PID: $pid, PPID: $ppid, Command: $cmd"
done

echo "正在终止..."
# 先尝试正常终止
kill $pids

# 等待 1 秒，检查是否还有残留
sleep 1

# 检查是否还有 nvim 进程
remaining_pids=$(pgrep -f nvim)

if [ -n "$remaining_pids" ]; then
  echo "部分进程未终止，强制终止..."
  kill -9 $remaining_pids
fi

echo "清理完成。"
