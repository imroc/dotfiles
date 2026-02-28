#!/usr/bin/env bash

# 打开本周的周笔记，如果不存在则自动创建
# 周的定义：周一为起始日，周日为结束日
# 文件路径：~/dev/note/weekly/<year>/<MMdd>-<MMdd>.md

main_note_dir=~/dev/note/weekly

# 获取当前日期信息
current_year=$(date +"%Y")
current_weekday=$(date +"%u") # 1=Monday, 7=Sunday

# 计算本周一和周日的日期
# macOS date 用 -v 调整日期
days_since_monday=$(( current_weekday - 1 ))
days_until_sunday=$(( 7 - current_weekday ))

monday_date=$(date -v-${days_since_monday}d +"%m%d")
sunday_date=$(date -v+${days_until_sunday}d +"%m%d")

# 周一所在的年份（用于目录）
monday_year=$(date -v-${days_since_monday}d +"%Y")

# 构建目录和文件名
note_dir=${main_note_dir}/${monday_year}
note_name=${monday_date}-${sunday_date}
full_path=${note_dir}/${note_name}.md

# 创建目录
if [ ! -d "$note_dir" ]; then
  mkdir -p "$note_dir"
fi

# 创建周笔记（如果不存在）
if [ ! -f "$full_path" ]; then
  cat <<EOF >"$full_path"
## 待办列表
EOF
fi

exec nvim --cmd "let g:neovim_mode = \"skitty\"" "$full_path"
