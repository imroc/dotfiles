function update --description 更新常用软件工具
    # -------------------------------------------------------
    # 工具分组定义
    # 新增工具到分组时，只需修改这里的列表
    # -------------------------------------------------------

    # macOS 判断：brew --cask 安装的应用需要桌面环境，Linux 无桌面无法安装
    set -g _is_mac (string match -q 'Darwin*' (uname -s); and echo true; or echo false)
    set -l ai_tools tclaude claude codebuddy gemini-internal tcodex opencode hapi multica codex
    set -l terminal_tools ghostty wezterm kitty fish-shell
    set -l multiplexer_tools zellij tmux herdr
    set -l all_tools $ai_tools $terminal_tools $multiplexer_tools iwiki-cli

    # -------------------------------------------------------
    # 帮助信息：无参数或 -h/--help 时显示
    # -------------------------------------------------------
    if test (count $argv) -eq 0; or contains -- -h $argv; or contains -- --help $argv
        echo "update - 更新常用软件工具"
        echo ""
        echo "用法:"
        echo "    update <tool> [tool2 ...]"
        echo "    update ai          更新所有 AI 工具"
        echo "    update terminal    更新所有终端相关工具"
        echo "    update multiplexer 更新所有终端复用器"
        echo "    update all         更新所有工具"
        echo "    update git         更新常用代码仓库"
        echo "    update skills      更新 AI 技能（项目级）"
        echo "    update skills --global  更新 AI 技能（全局级）"
        echo ""
        echo "可用工具:"
        echo "    iwiki-cli          iWiki CLI"
        echo "    tclaude            TClaude (内部版)"
        echo "    claude             Claude Code (官方脚本)"
        echo "    codebuddy          CodeBuddy Code"
        echo "    gemini-internal    Gemini CLI (内部版)"
        echo "    tcodex             TCodex (内部版)"
        echo "    opencode           OpenCode"
        echo "    hapi               Hapi"
        echo "    multica            Multica (formula)"
        echo "    codex              Codex CLI (cask)"
        echo "    ghostty            Ghostty 终端 (cask, 仅 macOS)"
        echo "    wezterm            WezTerm 终端 (cask, 仅 macOS)"
        echo "    kitty              Kitty 终端 (cask, 仅 macOS)"
        echo "    fish-shell         Fish Shell (formula)"
        echo "    zellij             Zellij 终端复用器 (formula)"
        echo "    tmux               Tmux 终端复用器 (formula)"
        echo "    herdr              Herdr 终端复用器 (formula)"
        echo ""
        echo "代码仓库:"
        echo "    git                ~/work, ~/dev/skills, ~/dev/tke/aikit, 公共/私有 dotfiles (yi pull && yu pull)"
        echo ""
        echo "工具组:"
        echo "    ai                 $ai_tools"
        echo "    terminal           $terminal_tools"
        echo "    multiplexer        $multiplexer_tools"
        echo "    all                所有工具"
        echo ""
        echo "选项:"
        echo "    -h, --help         显示此帮助信息"
        return 0
    end


    # -------------------------------------------------------
    # skills 子命令：支持可选 --global 标志
    # -------------------------------------------------------
    if contains -- skills $argv
        echo -e "\n🔄 Updating skills..."
        if contains -- --global $argv
            bash $HOME/dev/skills/scripts/update-skills.sh --global
        else
            bash $HOME/dev/skills/scripts/update-skills.sh
        end
        if test $status -ne 0
            echo -e "❌ skills 更新失败"
        end
        # 从参数列表中移除 skills 和 --global，继续处理其余工具
        set -e argv[(contains -i -- skills $argv)]
        if contains -- --global $argv
            set -e argv[(contains -i -- --global $argv)]
        end
        if test (count $argv) -eq 0
            return 0
        end
    end

    # -------------------------------------------------------
    # 核心逻辑：遍历参数，逐个更新
    # -------------------------------------------------------
    set -l total 0
    set -l failed 0

    for tool in $argv
        switch $tool
            # --- 分组：展开为具体工具列表，递归调用 ---
            case ai
                update $ai_tools
                return $status
            case terminal
                update $terminal_tools
                return $status
            case multiplexer
                update $multiplexer_tools
                return $status
            case all
                update $all_tools
                return $status

            case git
                echo -e "\n📦 Updating repos..."
                set -l repo_failed 0
                set -l repos ~/work ~/dev/skills ~/dev/tke/aikit
                for repo_dir in $repos
                    if test -d "$repo_dir/.git"
                        echo -e "\n🔄 git pull: $repo_dir"
                        if not git -C "$repo_dir" pull
                            set repo_failed (math $repo_failed + 1)
                            echo -e "❌ $repo_dir 更新失败"
                        end
                    else
                        echo -e "\n⏭️  Skipping $repo_dir (不是 git 仓库)"
                    end
                end
                echo -e "\n🔄 yi pull (私有 dotfiles)..."
                if not yi pull
                    set repo_failed (math $repo_failed + 1)
                    echo -e "❌ 私有 dotfiles 更新失败"
                end
                echo -e "\n🔄 yu pull (公共 dotfiles)..."
                if not yu pull
                    set repo_failed (math $repo_failed + 1)
                    echo -e "❌ 公共 dotfiles 更新失败"
                end
                echo -e "\n✅ Repos updated ($repo_failed failures)"
                if test $repo_failed -gt 0
                    return 1
                end
                return 0

                # --- 具体工具 ---
            case iwiki-cli
                set total (math $total + 1)
                echo -e "\n🔄 Updating iwiki-cli..."
                # 已安装则升级，未安装则用安装脚本安装
                if type -q iwiki-cli
                    if not iwiki-cli upgrade
                        set failed (math $failed + 1)
                        echo -e "❌ iwiki-cli 更新失败"
                    end
                else
                    echo -e "iwiki-cli 未安装，正在安装..."
                    if not env IWIKI_CLI_INSTALL_DIR=$HOME/.local/bin bash -c "curl -fsSL https://mirrors.tencent.com/repository/generic/iwiki-cli/install.sh | bash"
                        set failed (math $failed + 1)
                        echo -e "❌ iwiki-cli 安装失败"
                    end
                end

            case tclaude
                set total (math $total + 1)
                echo -e "\n🔄 Updating tclaude..."
                if not npm install -g @tencent/tclaude --engine-strict --registry=https://mirrors.tencent.com/npm
                    set failed (math $failed + 1)
                    echo -e "❌ tclaude 更新失败"
                end

            case claude
                set total (math $total + 1)
                echo -e "\n🔄 Updating claude..."
                # 已安装则用 claude update 更新，未安装则用官方脚本安装
                if type -q claude
                    if not claude update
                        set failed (math $failed + 1)
                        echo -e "❌ claude 更新失败"
                    end
                else
                    if not curl -fsSL https://claude.ai/install.sh | bash
                        set failed (math $failed + 1)
                        echo -e "❌ claude 安装失败"
                    end
                end

            case codebuddy
                set total (math $total + 1)
                echo -e "\n🔄 Updating codebuddy..."
                # 已安装则用 codebuddy update 更新，未安装则用 npm 安装
                if type -q codebuddy
                    if not codebuddy update
                        set failed (math $failed + 1)
                        echo -e "❌ codebuddy 更新失败"
                    end
                else
                    if not npm install -g @tencent-ai/codebuddy-code
                        set failed (math $failed + 1)
                        echo -e "❌ codebuddy 安装失败"
                    end
                end

            case gemini-internal
                set total (math $total + 1)
                echo -e "\n🔄 Updating gemini-internal..."
                if not npm install -g --registry=https://mirrors.tencent.com/npm @tencent/gemini-cli-internal
                    set failed (math $failed + 1)
                    echo -e "❌ gemini-internal 更新失败"
                end

            case tcodex
                set total (math $total + 1)
                echo -e "\n🔄 Updating tcodex..."
                if not npm i -g @tencent/tcodex --registry=https://mirrors.tencent.com/npm
                    set failed (math $failed + 1)
                    echo -e "❌ tcodex 更新失败"
                end

            case opencode
                set total (math $total + 1)
                echo -e "\n🔄 Updating opencode..."
                if not brew install opencode
                    set failed (math $failed + 1)
                    echo -e "❌ opencode 更新失败"
                end

            case hapi
                set total (math $total + 1)
                echo -e "\n🔄 Updating hapi..."
                if not npm install -g --registry=https://mirrors.tencent.com/npm @tencent/hapi
                    set failed (math $failed + 1)
                    echo -e "❌ hapi 更新失败"
                end

            case multica
                set total (math $total + 1)
                echo -e "\n🔄 Updating multica..."
                if not brew install multica
                    set failed (math $failed + 1)
                    echo -e "❌ multica 更新失败"
                end

            case codex
                set total (math $total + 1)
                echo -e "\n🔄 Updating codex..."
                if not brew install --cask codex
                    set failed (math $failed + 1)
                    echo -e "❌ codex 更新失败"
                end

            case ghostty
                set total (math $total + 1)
                if test "$_is_mac" = false
                    echo -e "\n⏭️  Skipping ghostty (非 macOS，无桌面环境)"
                    continue
                end
                echo -e "\n🔄 Updating ghostty..."
                if not brew install --cask ghostty
                    set failed (math $failed + 1)
                    echo -e "❌ ghostty 更新失败"
                end

            case wezterm
                set total (math $total + 1)
                if test "$_is_mac" = false
                    echo -e "\n⏭️  Skipping wezterm (非 macOS，无桌面环境)"
                    continue
                end
                echo -e "\n🔄 Updating wezterm..."
                if not brew install --cask wezterm
                    set failed (math $failed + 1)
                    echo -e "❌ wezterm 更新失败"
                end

            case kitty
                set total (math $total + 1)
                if test "$_is_mac" = false
                    echo -e "\n⏭️  Skipping kitty (非 macOS，无桌面环境)"
                    continue
                end
                echo -e "\n🔄 Updating kitty..."
                if not brew install --cask kitty
                    set failed (math $failed + 1)
                    echo -e "❌ kitty 更新失败"
                end

            case fish-shell
                set total (math $total + 1)
                echo -e "\n🔄 Updating fish..."
                if not brew install fish
                    set failed (math $failed + 1)
                    echo -e "❌ fish 更新失败"
                end

            case zellij
                set total (math $total + 1)
                echo -e "\n🔄 Updating zellij..."
                if not brew install zellij
                    set failed (math $failed + 1)
                    echo -e "❌ zellij 更新失败"
                end

            case tmux
                set total (math $total + 1)
                echo -e "\n🔄 Updating tmux..."
                if not brew install tmux
                    set failed (math $failed + 1)
                    echo -e "❌ tmux 更新失败"
                end

            case herdr
                set total (math $total + 1)
                echo -e "\n🔄 Updating herdr..."
                if not brew install herdr
                    set failed (math $failed + 1)
                    echo -e "❌ herdr 更新失败"
                end

                # --- 未知工具名 ---
            case '*'
                echo -e "❌ 未知工具: $tool" >&2
                set total (math $total + 1)
                set failed (math $failed + 1)
        end
    end

    # -------------------------------------------------------
    # 结果汇总
    # -------------------------------------------------------
    set -l succeeded (math $total - $failed)
    echo -e "\n✅ Updated $succeeded/$total tools successfully"

    # 有失败则返回非零状态码
    if test $failed -gt 0
        return 1
    end
    return 0
end
