## 概述

基于 **LazyVim** 的 Neovim 配置，使用 **yadm** 管理 dotfiles，支持多机同步。面向 macOS + Kubernetes/云原生开发工作流。

## 代码格式化

Lua 代码使用 StyLua 格式化：

```bash
stylua --config-path stylua.toml <file>
```

规则：Spaces 缩进，2 空格，120 列宽。

## 架构

### 入口和加载流程

`init.lua` → `config.lazy`（插件管理器初始化）→ `config.filetypes`（自定义文件类型）

LazyVim 是核心框架，所有自定义配置都是在其基础上扩展/覆盖。

### Yadm Alternate Files（多机配置）

通过 `##default` / `##class.kube` 后缀区分不同机器的配置文件。yadm 会根据机器 class 自动选择对应文件链接为实际文件名：

- `lazy.lua##default` — 全功能配置（加载所有插件目录，包括 `plugins.ai`、`plugins.lang`）
- `lazy.lua##class.kube` — Kubernetes 开发机精简配置（不加载 `plugins.ai` 和完整 `plugins.lang`，只加载 `plugins.lang.yaml`）
- `lazyvim.json##default` — 全量 LazyVim extras（Go, Rust, Python, Java, C/C++, Docker, Terraform 等）
- `lazyvim.json##class.kube` — 精简 LazyVim extras（仅 YAML, JSON, Helm）

修改配置时注意：如果变更需要同时应用于两种机器，需要同时修改两个 alternate 文件。

### 自定义 filetype 检测

`config/filetypes.lua` 注册了自定义文件类型映射。特殊逻辑：含 `#` 的文件名（yadm alternate files）会提取 `#` 之前的部分来匹配 filetype。

### 运行模式

通过环境变量控制不同运行模式：

- `NEOVIM_MODE=skitty` — 简化的笔记编辑模式（禁用 winbar/signcolumn，简化 statusline）
- `SIMPLER_SCROLLBACK=deeznuts` — 简化滚动回溯模式（禁用 winbar/statusline/signcolumn）
- 默认模式 — 完整功能

### 插件目录结构

`lua/plugins/` 按功能分类：

| 目录      | 内容                                        |
| --------- | ------------------------------------------- |
| `ai/`     | AI 编程助手（gongfeng-copilot）             |
| `coding/` | 补全(blink.cmp)、treesitter、重构等         |
| `editor/` | mason、snacks.nvim、toggleterm、grug-far 等 |
| `files/`  | yazi、neo-tree、mini-files                  |
| `git/`    | fugitive、octo、diffview                    |
| `lang/`   | 各语言 LSP/工具配置                         |
| `ui/`     | 主题(tokyonight)、dashboard、诊断显示等     |

### 工具模块 (`lua/util/`)

提供各类辅助函数，被 keymaps 和 plugin configs 引用：

- `buffer.lua` / `clipboard.lua` — 缓冲区信息和路径复制
- `term.lua` / `zellij.lua` — 终端和 Zellij 集成
- `kube.lua` — Kubernetes 操作
- `make.lua` — Makefile 目标解析和执行
- `root.lua` — 项目根目录检测（自定义 `root_spec`）
- `iwiki.lua` — 腾讯内部 wiki 图片上传/下载
- `yadm.lua` — yadm worktree 管理
- `conform.lua` — 格式化控制
- `lsp.lua` — LSP 跳转

### 快捷键组织

`lua/config/keymaps.lua` 作为入口，按功能分文件加载 `config/keymaps/` 下的模块：terminal、git、file、lang、editor、kube、window、tab、buffer、coding、yadm。

约定：

- `<leader>` = 空格，`<localleader>` = 逗号
- 个人快捷键描述使用 `[P]` 前缀
- 禁用 LazyVim 默认快捷键的模式：`keys = { { "<key>", false } }`

### 全局默认行为

- `vim.g.autoformat = false` — 默认禁用自动格式化
- `vim.diagnostic.enable(false)` — 默认禁用诊断
- `vim.g.snacks_animate = false` — 禁用动画（避免 gg/G 问题）
- SSH 环境下自动启用 OSC 52 剪贴板
