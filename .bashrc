# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# 核心加载逻辑
source_config() {
  local dir="$1"
  [[ -d "$dir" ]] || return
  for file in "$dir"/*.sh; do
    [[ -f "$file" ]] && source "$file"
  done
}

source_config "$HOME/.bashrc.d"
