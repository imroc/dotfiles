function ailink --description "Ensure all AI prompt files are symlinked to AGENTS.md (and .local.md to AGENTS.local.md)"
    # AI 工具对应的提示词文件名（不含 AGENTS.md 本身，它是 link 目标）
    set -l names CLAUDE CODEBUDDY GEMINI

    # 处理两组：普通文件 → CLAUDE.md，.local.md → CLAUDE.local.md
    for suffix in "" .local
        set -l target "AGENTS$suffix.md"

        # 目标文件不存在时，尝试从有内容的文件 mv 过来
        if not test -e $target; and not test -L $target
            set -l content_files
            for name in $names
                set -l f "$name$suffix.md"
                if test -f $f; and not test -L $f; and test -s $f
                    set -a content_files $f
                end
            end

            if test (count $content_files) -eq 0
                # 没有任何文件，.local.md 静默跳过，普通组提示
                if test -z "$suffix"
                    echo "跳过：$target 不存在"
                end
                continue
            else if test (count $content_files) -eq 1
                mv $content_files[1] $target
                echo "$content_files[1] → 移动为 $target"
            else
                echo "错误：$target 不存在，且多个文件有内容，请手动处理："
                for f in $content_files
                    echo "  - $f"
                end
                continue
            end
        end

        for name in $names
            set -l f "$name$suffix.md"

            # 已经是正确的软链，跳过
            if test -L $f
                set -l link_target (readlink $f)
                if test "$link_target" = "$target"
                    continue
                end
            end

            # 存在但不是正确软链的情况
            if test -e $f; or test -L $f
                # 如果是有实际内容的普通文件，提示用户
                if test -f $f; and not test -L $f; and test -s $f
                    echo "警告：$f 有实际内容，跳过（请手动处理后重试）"
                    continue
                end
                rm $f
            end

            ln -s $target $f
            echo "$f → $target"
        end
    end
end
