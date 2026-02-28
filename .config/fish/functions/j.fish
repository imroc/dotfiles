set -g __j_config "$HOME/.config/j.yaml"

function j --description "Jump to bookmarked directories"
    if not test -f $__j_config
        touch $__j_config
    end

    set -l subcmd $argv[1]

    if test -z "$subcmd"
        # fzf 选择别名
        set -l alias (yq e 'keys | .[]' $__j_config | fzf --height=40% --reverse --prompt="Jump to: ")
        if test -z "$alias"
            return
        end
        __j_cd $alias
        return
    end

    switch $subcmd
        case -h --help help
            echo "Usage: j [<alias>|<command>]"
            echo ""
            echo "Commands:"
            echo "  j              fzf 选择别名跳转"
            echo "  j <alias>      直接跳转到别名对应目录"
            echo "  j add [alias]  添加当前目录（默认用目录名作为别名）"
            echo "  j rm <alias>   删除书签"
            echo "  j tab [alias]  在 zellij 中新建 tab 并跳转"
            echo "  j list         列出所有书签"
            echo "  j wn           打开本周笔记"
            echo ""
            echo "Config: $__j_config"
        case add
            set -l alias $argv[2]
            if test -z "$alias"
                set alias (basename $PWD)
            end
            # 检查别名是否已存在
            set -l existing (yq e ".$alias // \"\"" $__j_config)
            if test -n "$existing"
                read -P "别名 '$alias' 已存在 ($existing)，覆盖? (y/N): " -l confirm
                if test "$confirm" != y; and test "$confirm" != Y
                    echo 已取消
                    return
                end
            end
            set -l dir (string replace $HOME '~' $PWD)
            yq -i ".$alias = \"$dir\"" $__j_config
            echo "已添加: $alias → $dir"
        case rm
            set -l alias $argv[2]
            if test -z "$alias"
                echo "Usage: j rm <alias>"
                return 1
            end
            set -l existing (yq e ".$alias // \"\"" $__j_config)
            if test -z "$existing"
                echo "别名 '$alias' 不存在"
                return 1
            end
            yq -i "del(.$alias)" $__j_config
            echo "已删除: $alias"
        case tab
            if not set -q ZELLIJ
                echo "不在 zellij 中"
                return 1
            end
            set -l alias $argv[2]
            if test -z "$alias"
                set alias (yq e 'keys | .[]' $__j_config | fzf --height=40% --reverse --prompt="Tab to: ")
                if test -z "$alias"
                    return
                end
            end
            set -l dir (yq e ".$alias // \"\"" $__j_config)
            if test -z "$dir"
                echo "别名 '$alias' 不存在"
                return 1
            end
            set dir (string replace '~' $HOME $dir)
            if not test -d $dir
                echo "目录不存在: $dir"
                return 1
            end
            zellij action new-tab --name $alias --cwd $dir
        case list ls
            yq e 'to_entries | .[] | [.key, .value] | @tsv' $__j_config | column -t -s (printf '\t')
        case wn
            weekly-note.sh
        case '*'
            # 当作别名直接跳转
            __j_cd $subcmd
    end
end

function __j_cd --description "cd to bookmarked directory by alias"
    set -l alias $argv[1]
    set -l dir (yq e ".$alias // \"\"" $__j_config)
    if test -z "$dir"
        echo "别名 '$alias' 不存在"
        return 1
    end
    set dir (string replace '~' $HOME $dir)
    if not test -d $dir
        echo "目录不存在: $dir"
        return 1
    end
    cd $dir
end
