function ainit --description "Unify AI init files: content in AGENTS.md, others as symlinks"
    set -l target AGENTS.md
    set -l files CLAUDE.md AGENTS.md CODEBUDDY.md GEMINI.md

    # 分类：有实际内容的普通文件 vs 已经是正确软链的 vs 存在但需要处理的
    set -l content_files
    set -l existing_files

    for f in $files
        if not test -e $f; and not test -L $f
            # 不存在，跳过
            continue
        end

        set -a existing_files $f

        if test -L $f
            # 是软链接
            set -l link_target (readlink $f)
            if test "$link_target" = "$target"
                # 已经正确指向 AGENTS.md，跳过
                continue
            end
            # 软链指向其他地方，视为有内容
            set -a content_files $f
        else if test -s $f
            # 普通文件且非空
            set -a content_files $f
        end
    end

    # 检查有内容的文件数量
    set -l count (count $content_files)

    if test $count -eq 0
        echo "错误：没有找到有内容的文件"
        return 1
    end

    if test $count -gt 1
        echo "错误：多个文件有不同内容，请手动处理："
        for f in $content_files
            echo "  - $f"
        end
        return 1
    end

    # 只有一个有内容的文件
    set -l source $content_files[1]

    # 如果内容不在 AGENTS.md，移动过去
    if test "$source" != "$target"
        mv $source $target
        echo "$source → 移动为 $target"
    end

    # 将其余文件全部确保为软链
    for f in $files
        test "$f" = "$target"; and continue

        # 已经是正确软链则跳过
        if test -L $f
            set -l link_target (readlink $f)
            if test "$link_target" = "$target"
                continue
            end
        end

        # 删除已存在的文件（包括错误的软链）
        if test -e $f; or test -L $f
            rm $f
        end

        ln -s $target $f
        echo "$f → 软链到 $target"
    end
end
