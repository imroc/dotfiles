# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 概述

使用 [yadm](https://github.com/yadm-dev/yadm) 管理的个人 dotfiles 仓库，用于多机同步。主要面向 macOS 系统，适用于 Kubernetes/云原生开发工作流。

## 目录结构

```
.config/
├── nvim/          # Neovim (基于 LazyVim)
├── fish/          # Fish shell (主要使用的 shell)
├── wezterm/       # WezTerm 终端
├── kitty/         # Kitty 终端
├── zellij/        # 终端复用器
├── aerospace/     # macOS 平铺窗口管理器
├── sketchybar/    # macOS 菜单栏替代
├── lazygit/       # Git TUI
├── k9s/           # Kubernetes TUI
├── git/           # Git 配置，包含大量别名
└── ...
.local/bin/        # 自定义脚本
.bashrc.d/         # Bash 配置模块
```

## Yadm 工作流

同步 dotfiles：
```bash
yadm pull
yadm status
```

强制覆盖本地文件：
```bash
yadm reset --hard HEAD
```

## Fish Shell

**添加插件：**
```bash
fisher add <plugin>
update_fish_plugins
```

Fish 插件通过 Fisher 管理。`update_fish_plugins` 函数会重新生成 `.config/fish/conf.d/003-fisher-plugin-variables.fish`。

配置按模块拆分在 `.config/fish/conf.d/` 下：
- `kubectl-aliases.fish` - 大量 kubectl 快捷命令
- `kubectl.fish` - Kubernetes 相关设置
- `yadm.fish` - Yadm 别名
- `common.fish` - 通用缩写

## Neovim

基于 LazyVim 的配置。使用 yadm 的 alternate files 特性区分不同机器：
- `lazyvim.json##default` - 标准配置
- `lazyvim.json##class.kube` - Kubernetes 开发配置
- `lazy.lua##default` / `lazy.lua##class.kube` - 不同机器类型加载不同插件集

插件结构在 `.config/nvim/lua/plugins/`：
- `ai/` - AI 编程助手
- `lang/` - 语言相关 (Go, YAML, Lua 等)
- `git/` - Git 集成
- `files/` - 文件管理 (yazi)
- `ui/` - UI 增强
- `coding/` - 代码编辑辅助
- `editor/` - 编辑器功能

工具函数在 `.config/nvim/lua/util/`，提供 Kubernetes、Git、Zellij 集成等辅助功能。

## Makefile

部分配置提供 Makefile 用于更新默认配置：

```bash
# 更新 AeroSpace 默认配置
make -C .config/aerospace update-default-config

# 更新 SketchyBar 默认配置
make -C .config/sketchybar update-default-config

# 更新 Kitty 默认配置和主题
make -C .config/kitty update

# 更新 Zellij 默认配置
make -C .config/zellij update-default
```

## Git 配置

Git 配置在 `.config/git/config`：
- 使用 delta 作为 pager
- 自定义 hooks 路径在 `~/.git-hooks`
- 大量别名集合在 `.config/git/alias` (来自 gitalias.com)

常用别名：`git ll` (日志列表)、`git aa` (添加全部)、`git cm` (提交)、`git co` (checkout)

## 关键工具集成

- **Lazygit**: `.config/yadm/lazygit.yml` 中自定义快捷键 (避免大仓库 Ctrl+A 卡死)
- **Starship**: 提示符配置在 `.config/starship.toml`
- **bat/eza/zoxide**: 现代 CLI 工具替代品
