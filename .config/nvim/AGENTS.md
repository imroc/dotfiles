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

```
init.lua
  → config.lazy（lazy.nvim 初始化 + 插件加载）
  → config.filetypes（自定义文件类型检测）
  → [LazyVim 自动加载] config.options / config.keymaps / config.autocmds
```

LazyVim 是核心框架，所有自定义配置都是在其基础上扩展/覆盖。`options.lua`、`keymaps.lua`、`autocmds.lua` 由 LazyVim 约定自动加载，无需在 `init.lua` 中显式引入。

### Yadm Alternate Files（多机配置）

通过 `##default` / `##class.kube` 后缀区分不同机器的配置文件。yadm 会根据机器 class 自动选择对应文件链接为实际文件名：

- `lazy.lua##default` — 全功能配置（加载所有插件目录，包括 `plugins.ai`、`plugins.lang`）
- `lazy.lua##class.kube` — Kubernetes 开发机精简配置（不加载 `plugins.ai` 和完整 `plugins.lang`，只加载 `plugins.lang.yaml`）
- `lazyvim.json##default` — 全量 LazyVim extras（Go, Rust, Python, Java, C/C++, Docker, Terraform, TypeScript, Nix 等 38 个）
- `lazyvim.json##class.kube` — 精简 LazyVim extras（仅 YAML, JSON, Helm 等 9 个）

修改配置时注意：如果变更需要同时应用于两种机器，需要同时修改两个 alternate 文件。

### 自定义 filetype 检测

`config/filetypes.lua` 注册了自定义文件类型映射。特殊逻辑：含 `#` 的文件名（yadm alternate files）会提取 `#` 之前的部分来匹配 filetype。

### 运行模式

通过环境变量控制不同运行模式（逻辑在 `config/options.lua` 开头）：

- `NEOVIM_MODE=skitty` — 简化的笔记编辑模式（禁用 winbar/signcolumn，简化 statusline，设置 textwidth=80）
- `SIMPLER_SCROLLBACK=deeznuts` — 简化滚动回溯模式（禁用 winbar/statusline/signcolumn）
- 默认模式 — 完整功能

### 插件目录结构

`lua/plugins/` 按功能分类，共 51 个插件配置文件：

| 目录      | 插件                                                                                                                                |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| `ai/`     | gongfeng-copilot                                                                                                                    |
| `coding/` | mini-pairs、nvim-treesitter、nvim-ts-autotag、refactoring、tiny-inline-diagnostic、treesj                                           |
| `editor/` | blink-cmp、cutlass、flash、grug-far、im-select、mason、project、snacks、toggleterm、trouble、urlview、which-key、winresize          |
| `files/`  | yazi、neo-tree、mini-files                                                                                                          |
| `git/`    | vim-fugitive、octo、diffview、git-blame、openingh                                                                                   |
| `lang/`   | lspconfig、go、yaml、markdown、bash、fish、lua、vim、jsonnet、kdl、bpftrace、promql、rego                                           |
| `ui/`     | tokyonight、lualine、bufferline、noice、nvim-navbuddy、nvim-scrollview、showkeys、stay-centered、kitty-scrollback、vim-highlighturl |

其中 `lang/markdown.lua` 是最大的单个配置文件（370+ 行），集成了 render-markdown、marp、markdown-preview、checkmate、img-clip 等多个 markdown 编辑工具。

### 工具模块 (`lua/util/`)

提供各类辅助函数，被 keymaps 和 plugin configs 引用（共 22 个模块）：

- `buffer.lua` / `clipboard.lua` — 缓冲区信息和路径复制
- `term.lua` / `zellij.lua` — 终端和 Zellij 集成
- `kube.lua` — Kubernetes 操作
- `make.lua` — Makefile 目标解析和执行
- `root.lua` — 项目根目录检测（自定义 `root_spec`，供 `options.lua` 中 `vim.g.root_spec` 使用）
- `iwiki.lua` — 腾讯内部 wiki 图片上传/下载
- `yadm.lua` — yadm worktree 管理
- `conform.lua` — 格式化控制
- `lsp.lua` — LSP 跳转
- `git.lua` — Git 辅助操作
- `job.lua` — 异步任务执行
- `window.lua` — 窗口操作
- `bookmark.lua` — jumplist.yaml 书签解析
- `file.lua` — 文件操作（含 iwiki 同步）
- `markdown.lua` — Markdown 折叠等工具函数
- `mini-files-git.lua` / `mini-files-keymaps.lua` — mini-files 的 git 集成和自定义快捷键
- `outline.lua` — 大纲相关
- `picker.lua` — Snacks picker 包装
- `strings.lua` — 字符串工具

### 自动命令 (`config/autocmds.lua`)

- **自动切换 cwd** — BufEnter 时自动 `tcd` 到 `LazyVim.root()` 检测的项目根目录
- **yadm 快捷键注入** — `~/.config` 下的文件自动绑定 `<leader>ga` 执行 yadm add
- **LSP 缓冲区过滤** — 自动 detach LSP client，避免 fugitive:// 和 diffview:// 缓冲区触发 LSP 报错
- **禁用 LazyVim 默认 wrap/spell** — 清空 `lazyvim_wrap_spell` augroup

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
- `vim.g.root_spec` — 自定义项目根检测：先用 `root.detect_project_root`，再找 `.git`，最后 fallback 到 `cwd`
- `vim.opt.list = false` — 禁用不可见字符显示
- `vim.opt.modeline = true` — 启用 modeline 但禁用表达式（`modelineexpr = false`）
- SSH 环境下自动启用 OSC 52 剪贴板
