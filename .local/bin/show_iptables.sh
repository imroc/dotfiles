#!/bin/bash

# 脚本用于动态分析指定iptables表的链关系并以树状结构展示
#set -x
# 定义颜色（兼容更多终端）
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
BLUE=$'\033[34m'
PURPLE=$'\033[35m'
CYAN=$'\033[36m'
GRAY=$'\033[90m'
NC=$'\033[0m'

# 临时文件
TEMP_FILE="/tmp/iptables_rules.txt"

# 全局关联数组（显式声明）
declare -A VISITED_CHAINS

# 获取所有可用表
get_tables() {
  if [[ -f /proc/net/ip_tables_names ]]; then
    cat /proc/net/ip_tables_names 2>/dev/null
  else
    # 兼容旧系统
    iptables -L -n 2>/dev/null | grep -Po 'Table: \K\w+' | sort -u
  fi
}

# 提取链名（增加过滤）
extract_chains() {
  grep -E "^:[A-Za-z0-9_-]+ " "$TEMP_FILE" | cut -d ' ' -f 1 | tr -d ':' | grep -v '^$'
}

# 获取链的规则（增强过滤）
find_rules_for_chain() {
  local chain=$1
  [[ -z "$chain" ]] && return
  grep -E "^-A $chain " "$TEMP_FILE" | sed '/^#/d'
}

# 提取目标链（严格校验）
extract_targets() {
  local rule=$1
  echo "$rule" | grep -oP '\s-(j|g)\s+\K[^\s]+' | grep -E '^[A-Za-z0-9_-]+$'
}

# 规则格式化（防御性处理）
format_rule() {
  local rule=$1
  # 移除链声明和注释
  rule=$(echo "$rule" | sed -E 's/^-A [^ ]* //; s/(--comment "[^"]*")//g')
  # 高亮关键元素
  echo "$rule" | sed -E \
    -e "s/(-j |-g )([^ ]+)/${RED}\1${YELLOW}\2${NC}/g" \
    -e "s/(-[pm] |--(src|dport|sport|destination|match))/${CYAN}\1${NC}/g"
}

# 树状打印（关键修复）
print_tree() {
  local chain=$1
  local prefix=$2
  local visited=$3
  local depth=$4

  # 空链名防御
  if [[ -z "$chain" ]]; then
    echo -e "${prefix}${RED}⚠ 无效空链名${NC}"
    return
  fi

  # 循环检测
  if [[ "$visited" == *"|$chain|"* ]]; then
    echo -e "${prefix}${RED}└── ⚠ 循环引用: $chain${NC}"
    return
  fi

  # 深度限制
  if ((depth > 15)); then
    echo -e "${prefix}${YELLOW}└── ⚠ 达到最大深度${NC}"
    return
  fi

  # 记录访问链（安全写入）
  if [[ -n "$chain" ]]; then
    VISITED_CHAINS["$chain"]=1
  fi

  # 获取规则
  local rules=()
  while IFS= read -r rule; do
    rules+=("$rule")
  done <<<"$(find_rules_for_chain "$chain")"

  # 提取子链
  local targets=()
  for rule in "${rules[@]}"; do
    while IFS= read -r target; do
      if [[ -n "$target" && ! " ${targets[*]} " =~ " $target " ]]; then
        targets+=("$target")
      fi
    done <<<"$(extract_targets "$rule")"
  done

  # 打印当前链
  local color
  case $((depth % 6)) in
  0) color=$BLUE ;;
  1) color=$GREEN ;;
  2) color=$PURPLE ;;
  3) color=$CYAN ;;
  4) color=$YELLOW ;;
  *) color=$RED ;;
  esac
  echo -e "${prefix}${color}├── ${chain}${NC}"

  # 打印规则
  local rule_prefix="│   "
  for rule in "${rules[@]}"; do
    echo -e "${prefix}${rule_prefix}${GRAY}├─ ▪ ${NC}$(format_rule "$rule")"
  done

  # 打印子链
  local total=${#targets[@]}
  for i in "${!targets[@]}"; do
    local target=${targets[$i]}
    if ((i == total - 1)); then
      print_tree "$target" "${prefix}    └── " "${visited}|$chain|" $((depth + 1))
    else
      print_tree "$target" "${prefix}    ├── " "${visited}|$chain|" $((depth + 1))
    fi
  done
}

# 主程序
main() {
  echo -e "${GREEN}■ iptables链关系拓扑 (规则内联显示) ■${NC}"
  echo -e "${YELLOW}说明："
  echo -e "  ${GRAY}▪ 灰色条目为规则${NC}"
  echo -e "  ${RED}红色${NC}表示跳转目标"
  echo -e "  ${CYAN}青色${NC}表示匹配条件\n"

  echo -e "${BLUE}▏ 链 [${selected_chain}] 拓扑：${NC}"
  print_tree "$selected_chain" "" "" 0
  echo ""
}

# 执行流程
# 1. 选择表
tables=($(get_tables))
if [[ ${#tables[@]} -eq 0 ]]; then
  echo -e "${RED}❌ 错误：未找到任何iptables表${NC}"
  exit 1
fi

echo "可用iptables表："
select selected_table in "${tables[@]}"; do
  if [[ -n "$selected_table" ]]; then
    break
  else
    echo -e "${RED}❌ 无效选择，请重新输入${NC}"
  fi
done

# 2. 选择链
iptables-save -t "$selected_table" >"$TEMP_FILE"
chains=($(extract_chains))

if [[ ${#chains[@]} -eq 0 ]]; then
  echo -e "${RED}❌ 错误：表 ${selected_table} 中未找到任何链${NC}"
  rm -f "$TEMP_FILE"
  exit 1
fi

echo "表 ${selected_table} 的可用链："
select selected_chain in "${chains[@]}"; do
  if [[ -n "$selected_chain" ]]; then
    break
  else
    echo -e "${RED}❌ 无效选择，请重新输入${NC}"
  fi
done

# 3. 执行分析
main
rm -f "$TEMP_FILE"
