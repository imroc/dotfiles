#!/bin/bash

# 安全添加路径函数（无重复添加）
pathadd() {
  local path_to_add="$1"
  local position=${2:-"append"} # 默认追加，可选"prepend"置前

  # 校验路径是否存在
  if [ ! -d "$path_to_add" ]; then
    return 0 # 不存在，跳过添加
  fi

  # 标准化路径格式（去除结尾的/）
  path_to_add="${path_to_add%/}"

  # 检查是否已在 PATH 中存在
  case ":${PATH}:" in
  *":${path_to_add}:"*)
    return 0 # 已存在，跳过添加
    ;;
  *)
    # 根据位置参数添加路径
    if [ "$position" = "prepend" ]; then
      export PATH="${path_to_add}:${PATH}"
    else
      export PATH="${PATH}:${path_to_add}"
    fi
    ;;
  esac
}

# 批量添加路径数组
declare -a paths_to_add=(
  $HOME/.local/bin
  $HOME/.bin
  $HOME/.cargo/bin
  $HOME/go/bin
  $HOME/.krew/bin
  $HOME/.fzf/bin
  /opt/go/bin
  /opt/homebrew/bin
  /opt/homebrew/opt/openjdk/bin
  /home/linuxbrew/.linuxbrew/bin
  /home/linuxbrew/.linuxbrew/sbin
  /opt/homebrew/opt/make/libexec/gnubin
  /opt/maven/bin
  /nix/var/nix/profiles/default/bin
  $HOME/.nix-profile/bin
)

# 循环添加路径（排除已存在项）
for p in "${paths_to_add[@]}"; do
  pathadd "$p" prepend # 将新路径添加到最前面
done

# 清理临时变量
unset p paths_to_add
