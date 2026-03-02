function gw --description "Git worktree manager"
    # Help
    if test (count $argv) -ge 1; and contains -- $argv[1] -h --help
        echo "Usage: gw [command]"
        echo ""
        echo "Commands:"
        echo "  (none)      fzf select a worktree and cd into it"
        echo "  a, add      create a new worktree from remote branch/tag"
        echo "  -h, --help  show this help"
        return 0
    end

    # Check git repo
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "gw: not a git repository" >&2
        return 1
    end

    # Subcommand dispatch
    if test (count $argv) -eq 0
        _gw_select
    else
        switch $argv[1]
            case a add
                _gw_add
            case '*'
                echo "gw: unknown command '$argv[1]'" >&2
                echo "Run 'gw -h' for help" >&2
                return 1
        end
    end
end

function _gw_select
    set -l lines (git worktree list --porcelain | string match --regex '^worktree .+' | string replace 'worktree ' '')
    if test (count $lines) -eq 0
        echo "gw: no worktrees found" >&2
        return 1
    end

    # Build display: basename -> full path
    set -l names
    for p in $lines
        set -a names (basename $p)
    end

    set -l chosen (printf '%s\n' $names | fzf --prompt="worktree> ")
    if test -z "$chosen"
        return 0
    end

    # Find matching full path
    for i in (seq (count $names))
        if test "$names[$i]" = "$chosen"
            cd $lines[$i]
            return 0
        end
    end
end

function _gw_add
    set -l git_root (git rev-parse --show-toplevel)

    # Determine remote
    set -l remotes (git remote)
    if test (count $remotes) -eq 0
        echo "gw: no remotes configured" >&2
        return 1
    else if test (count $remotes) -eq 1
        set -f remote $remotes[1]
    else
        set -f remote (printf '%s\n' $remotes | fzf --prompt="remote> ")
        if test -z "$remote"
            return 0
        end
    end

    # Fetch latest
    echo "Fetching $remote..."
    git fetch $remote

    # List remote branches and tags
    set -l refs
    for ref in (git for-each-ref --format='%(refname:short)' refs/remotes/$remote/ | string replace "$remote/" '')
        test "$ref" != HEAD; and set -a refs "branch:$ref"
    end
    for ref in (git tag -l)
        set -a refs "tag:$ref"
    end

    if test (count $refs) -eq 0
        echo "gw: no branches or tags found on $remote" >&2
        return 1
    end

    set -l chosen (printf '%s\n' $refs | fzf --prompt="ref> ")
    if test -z "$chosen"
        return 0
    end

    # Parse type and name
    set -l ref_type (string split ':' $chosen)[1]
    set -l ref_name (string split ':' $chosen)[2]

    # Sanitize directory name (replace / with -)
    set -l dir_name (string replace --all '/' '-' $ref_name)
    set -l wt_dir "$git_root/.worktrees/$dir_name"

    if test -d "$wt_dir"
        echo "gw: worktree directory already exists: $wt_dir" >&2
        echo "cd into it directly." >&2
        cd $wt_dir
        return 0
    end

    mkdir -p "$git_root/.worktrees"

    if test "$ref_type" = branch
        # Check if local branch already exists
        if git show-ref --verify --quiet refs/heads/$ref_name
            git worktree add "$wt_dir" $ref_name
        else
            git worktree add -b $ref_name "$wt_dir" $remote/$ref_name
        end
    else
        # Tag: detached HEAD or create branch from tag
        git worktree add -b $ref_name "$wt_dir" $ref_name
    end

    if test $status -eq 0
        echo "Worktree created: $wt_dir"
        cd $wt_dir
    else
        echo "gw: failed to create worktree" >&2
        return 1
    end
end
