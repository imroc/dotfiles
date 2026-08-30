## 概述

Fish shell 配置，面向 Kubernetes/云原生开发工作流。插件通过 Fisher 管理，配置按模块拆分。

## 添加插件

```bash
fisher add <plugin>
update_fish_plugins   # 重新生成 conf.d/003-fisher-plugin-variables.fish
```

当前插件清单在 `fish_plugins` 文件中：autopair、fzf、fisher、plugin-git。

## conf.d/ 加载顺序

编号文件按顺序加载，保证依赖关系：

1. `001-path.fish` — PATH 配置（Homebrew、Go、Cargo、Krew 等）
2. `002-auto-attach-zellij.fish` — SSH 到容器时自动 attach zellij
3. `003-fisher-plugin-variables.fish` — **自动生成，勿手动编辑**
4. `004-fisher.fish` — Fisher 初始化，设置插件路径到 `plugins/` 目录

未编号文件按字母顺序加载，每个文件对应一个工具/主题。

## 架构要点

### 配置模式

- 环境变量用 `set -gx`，缩写用 `abbr --add`
- 每个工具独立一个 conf.d 文件，不混合职责
- `private.fish` 通过软链接加载 `~/.config/fish/private/` 下的私有配置（不入库）

### 插件隔离

Fisher 插件安装在 `plugins/` 子目录，通过 `004-fisher.fish` 将 `plugins/{functions,completions,conf.d}` 注入到 fish 搜索路径中，与用户自定义函数隔离。

### KUBE_CONTEXT 环境变量

这是贯穿多个工具的核心设计：`functions/kubectl.fish`、`functions/helm.fish`、`functions/k9s.fish`、`functions/cilium.fish` 等包装函数都会读取 `$KUBE_CONTEXT` 并自动传递 `--context` 参数。通过 `kubectl ctx` 子命令切换上下文。

### kubectl 增强函数 (`functions/kubectl.fish`)

包装了大量子命令，核心扩展：

- `kubectl ns [name]` — 切换命名空间（支持 fzf）
- `kubectl get -e/-E` — 用 nvim 打开资源（-E 经 kubectl neat 清理）
- `kubectl get -j` — JSON 用 fx 查看
- `kubectl get -p/-P` — 查看 configmap/secret 文件内容
- `kubectl get -c/-C` — 查看证书信息
- `kubectl get -d` — 用 neat 清理 yaml 输出
- `kubectl node-shell/pod-shell` — fzf 选择后登录节点/Pod

### update git 仓库同步 (`functions/update.fish`)

`update git` 的仓库清单来自 `~/.config/repos.conf`，每行一条『<仓库 URL> <本地路径>』（`~` 代表 $HOME）：

- 本地路径不存在（或为空目录）→ 自动 `git clone`
- 已存在 → `git pull`；因本地有未 push 提交导致 pull 失败 → 自动 `pull --rebase`
- 非空且非 git 仓库的目录 → 跳过；yadm dotfiles（yi/yu）不在此配置，由 `update git` 单独处理

新增同步仓库只需改该配置文件，无需改函数。

## 函数命名约定

- 工具包装函数：直接用工具名（`kubectl`、`helm`、`cilium`、`k9s`）
- 内部辅助函数：双下划线前缀（`__parse_subcommand`、`__kubecolor`）
- 短命令函数：缩写风格（`gg`、`gca`、`za`、`dr`、`arg`、`kay`）

## 缩写体系（abbr）

核心缩写定义在各 conf.d 文件中：

- `k` → kubectl, `g` → git, `v` → nvim, `m` → make, `lg` → lazygit
- `tf` → terraform, `c` → `code -r`
- kubectl 缩写约 300 个在 `kubectl-aliases.fish`（如 `kgp`、`kgd`、`kgno` 等）

## 补全文件 (`completions/`)

自定义补全文件为各种 CLI 工具提供 tab 补全。修改补全时遵循 fish 补全 API（`complete -c <cmd> -s/-l/-a`）。
