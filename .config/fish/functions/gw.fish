function gw --description "Git worktree manager"
    # Help
    if test (count $argv) -ge 1; and contains -- $argv[1] -h --help
        _gw_help
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
            case n new
                _gw_new $argv[2..]
            case b branch
                _gw_branch $argv[2..]
            case d delete
                _gw_delete $argv[2..]
            case '*'
                echo "gw: unknown command '$argv[1]'" >&2
                echo "Run 'gw -h' for help" >&2
                return 1
        end
    end
end

function _gw_help
    echo "Usage: gw [command]"
    echo ""
    echo "Commands:"
    echo "  (none)      fzf select a worktree and cd into it"
    echo "  a, add      create a new worktree from remote branch/tag"
    echo "  n, new      create a new worktree with a new branch off the remote's"
    echo "              default branch (fetches first): gw new <new-branch> [base-ref]"
    echo "  b, branch   create a new worktree with a new branch from current HEAD"
    echo "  d, delete   fzf multi-select worktrees and remove them"
    echo "              (Tab: multi-select, Ctrl+A: select all, trunk never deleted)"
    echo "              options: -f/--force (discard changes), -y/--yes (skip confirm)"
    echo "  -h, --help  show this help"
end

# Emit one line per worktree: "<label>\t<path>\t<main|linked>".
# The main worktree (the trunk) is labeled with its branch name instead of the
# repository directory name, so the list reads "main" rather than "my-repo".
function _gw_worktree_entries
    set -l cur_path ""
    set -l cur_branch ""
    set -l first 1

    for line in (git worktree list --porcelain)
        if string match -q -- 'worktree *' $line
            set cur_path (string sub --start 10 -- $line)
            set cur_branch ""
        else if string match -q -- 'branch *' $line
            set cur_branch (string replace -- 'branch refs/heads/' '' $line)
        else if test -z "$line"
            _gw_worktree_entry $cur_path $cur_branch $first
            set first 0
            set cur_path ""
        end
    end
    if test -n "$cur_path"
        _gw_worktree_entry $cur_path $cur_branch $first
    end
end

function _gw_worktree_entry
    set -l path $argv[1]
    set -l branch $argv[2]
    set -l is_main $argv[3]

    if test "$is_main" = 1
        set -l label (basename $path)
        test -n "$branch"; and set label $branch
        printf '%s\t%s\tmain\n' $label $path
    else
        printf '%s\t%s\tlinked\n' (basename $path) $path
    end
end

function _gw_select
    set -l tab (printf '\t')
    set -l entries (_gw_worktree_entries)
    if test (count $entries) -eq 0
        echo "gw: no worktrees found" >&2
        return 1
    end

    set -l chosen (printf '%s\n' $entries | fzf --delimiter=$tab --with-nth=1 --prompt="worktree> ")
    if test -z "$chosen"
        return 0
    end

    cd (string split $tab -- $chosen)[2]
end

function _gw_main_root
    set -l common_dir (git rev-parse --git-common-dir)
    if string match -q '/*' $common_dir
        dirname $common_dir
    else
        git rev-parse --show-toplevel
    end
end

# Print the remote to use: the only one, or an fzf pick when several exist.
function _gw_pick_remote
    if test (count $argv) -le 1
        echo $argv[1]
        return 0
    end
    printf '%s\n' $argv | fzf --prompt="remote> "
end

# Print the commit-ish a new branch should start from when the user gave none:
# the remote's default branch (origin/HEAD), else a common trunk name, else HEAD.
function _gw_default_base
    set -l remote $argv[1]

    set -l ref (git symbolic-ref --quiet --short refs/remotes/$remote/HEAD 2>/dev/null)
    if test -z "$ref"
        for candidate in main master develop trunk
            if git show-ref --verify --quiet refs/remotes/$remote/$candidate
                set ref $remote/$candidate
                break
            end
        end
    end
    if test -z "$ref"
        echo "gw: cannot detect '$remote' default branch, using current HEAD" >&2
        set ref HEAD
    end

    echo $ref
end

# Create a worktree under "<repo>/.worktrees/" for a new branch and cd into it.
# The directory name is the branch name with "/" replaced by "-".
# $argv[1] = new branch name, $argv[2] = optional base commit-ish (defaults to HEAD).
function _gw_create_worktree
    set -l branch_name $argv[1]
    set -l base $argv[2]

    if not git check-ref-format --branch $branch_name >/dev/null 2>&1
        echo "gw: invalid branch name '$branch_name'" >&2
        return 1
    end

    set -l git_root (_gw_main_root)
    set -l dir_name (string replace --all '/' '-' $branch_name)
    set -l wt_dir "$git_root/.worktrees/$dir_name"

    if test -d "$wt_dir"
        echo "gw: worktree directory already exists: $wt_dir" >&2
        cd $wt_dir
        return 0
    end

    if git show-ref --verify --quiet refs/heads/$branch_name
        echo "gw: branch '$branch_name' already exists locally, use 'gw add' to check it out" >&2
        return 1
    end

    mkdir -p "$git_root/.worktrees"

    # --no-track keeps the new branch from tracking the base, so a stray
    # pull/push cannot hit the base branch; the first push sets upstream.
    set -l add_args --no-track -b $branch_name $wt_dir
    test -n "$base"; and set -a add_args $base

    if not git worktree add $add_args
        echo "gw: failed to create worktree" >&2
        return 1
    end

    set -l detail "branch: $branch_name"
    test -n "$base"; and set detail "$detail, base: $base"
    echo "Worktree created: $wt_dir ($detail)"

    set -l remotes (git remote)
    if test (count $remotes) -gt 0
        set -l push_remote origin
        contains -- origin $remotes; or set push_remote $remotes[1]
        echo "First push: git push -u $push_remote $branch_name"
    end

    cd $wt_dir
end

function _gw_delete
    set -l force 0
    set -l yes 0
    for arg in $argv
        switch $arg
            case -f --force
                set force 1
            case -y --yes
                set yes 1
            case -h --help
                echo "Usage: gw delete [-f|--force] [-y|--yes]"
                echo ""
                echo "  fzf multi-select worktrees to remove (Tab: multi-select, Ctrl+A: select all)."
                echo "  The trunk worktree is never removed, even when selecting all."
                echo "  Branches are kept; worktrees with uncommitted changes need -f."
                return 0
            case '*'
                echo "gw delete: unknown option '$arg'" >&2
                return 1
        end
    end

    set -l main_root (_gw_main_root)
    set -l tab (printf '\t')
    set -l entries (_gw_worktree_entries)
    if test (count $entries) -eq 0
        echo "gw: no worktrees found" >&2
        return 1
    end

    set -l trunk_label
    for entry in $entries
        set -l fields (string split $tab -- $entry)
        if test "$fields[3]" = main
            set trunk_label $fields[1]
        end
    end

    set -l header "trunk '$trunk_label' is never deleted | Tab: multi-select | Ctrl+A: select all"
    set -l chosen (printf '%s\n' $entries | fzf -m --delimiter=$tab --with-nth=1 --prompt="delete> " --header="$header" --bind="ctrl-a:select-all")
    if test -z "$chosen"
        return 0
    end

    set -l targets
    set -l skipped_trunk 0
    for line in $chosen
        set -l fields (string split $tab -- $line)
        if test "$fields[3]" = main
            set skipped_trunk 1
        else
            set -a targets $fields[2]
        end
    end

    if test $skipped_trunk -eq 1
        echo "gw: trunk '$trunk_label' is never deleted, skipped" >&2
    end
    if test (count $targets) -eq 0
        return 0
    end

    echo "Will remove (branches are kept):"
    for target in $targets
        echo "  $target"
    end

    if test $yes -eq 0
        read -l -P "Confirm removal? [y/N] " answer
        if not string match -qi 'y*' -- "$answer"
            echo "gw: aborted"
            return 0
        end
    end

    set -l failed 0
    set -l cwd (pwd -P)
    for target in $targets
        # Never keep the shell inside a worktree that is about to disappear.
        if test "$cwd" = "$target"; or string match -q -- "$target/*" $cwd
            cd $main_root
            set cwd (pwd -P)
        end

        set -l remove_args
        test $force -eq 1; and set remove_args --force
        if git worktree remove $remove_args $target
            echo "Removed: $target"
        else
            set failed 1
            echo "gw: failed to remove $target (uncommitted changes? use -f)" >&2
        end
    end

    git worktree prune
    return $failed
end

function _gw_add
    # Determine remote
    set -l remotes (git remote)
    if test (count $remotes) -eq 0
        echo "gw: no remotes configured" >&2
        return 1
    end
    set -l remote (_gw_pick_remote $remotes)
    if test -z "$remote"
        return 0
    end

    # Fetch latest
    echo "Fetching $remote..."
    git fetch $remote

    # List remote branches and tags. Full refnames are used because git shortens
    # refs/remotes/<remote>/HEAD to plain "<remote>", which would leak a bogus entry.
    set -l refs
    set -l prefix "refs/remotes/$remote/"
    for ref in (git for-each-ref --format='%(refname)' $prefix)
        set -l name (string replace -- $prefix '' $ref)
        test "$name" = HEAD; and continue
        set -a refs "branch:$name"
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

    set -l git_root (_gw_main_root)

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

# New branch off the remote's default branch: gw new <new-branch> [base-ref]
function _gw_new
    set -l args
    for arg in $argv
        switch $arg
            case -h --help
                echo "Usage: gw new <new-branch> [base-ref]"
                echo ""
                echo "  Fetch the remote, then create a worktree holding a new branch based on"
                echo "  <base-ref> (default: the remote's default branch, e.g. origin/main)."
                echo "  Without a configured remote the base defaults to the current HEAD."
                echo "  The branch is created with --no-track; push it with 'git push -u origin <name>'."
                return 0
            case '-*'
                echo "gw new: unknown option '$arg'" >&2
                echo "Usage: gw new <new-branch> [base-ref]" >&2
                return 1
            case '*'
                set -a args $arg
        end
    end

    if test (count $args) -eq 0
        echo "gw new: missing new branch name" >&2
        echo "Usage: gw new <new-branch> [base-ref]" >&2
        return 1
    end

    set -l branch_name $args[1]
    set -l base
    test (count $args) -ge 2; and set base $args[2]

    if not git check-ref-format --branch $branch_name >/dev/null 2>&1
        echo "gw new: invalid branch name '$branch_name'" >&2
        return 1
    end

    set -l remotes (git remote)
    if test (count $remotes) -gt 0
        set -l remote (_gw_pick_remote $remotes)
        if test -z "$remote"
            return 0
        end

        echo "Fetching $remote..."
        if not git fetch $remote
            echo "gw new: failed to fetch '$remote'" >&2
            return 1
        end

        # A same-named remote branch means an existing branch to check out, not a new one.
        if git show-ref --verify --quiet refs/remotes/$remote/$branch_name
            echo "gw new: branch '$branch_name' already exists on '$remote', use 'gw add' to check it out" >&2
            return 1
        end

        test -z "$base"; and set base (_gw_default_base $remote)
    end

    if test -n "$base"; and not git rev-parse --verify --quiet "$base^{commit}" >/dev/null
        echo "gw new: base '$base' not found" >&2
        return 1
    end

    _gw_create_worktree $branch_name $base
end

# New branch off the current HEAD: gw branch <name>
function _gw_branch
    if test (count $argv) -eq 0
        echo "gw branch: missing branch name" >&2
        echo "Usage: gw branch <name>" >&2
        return 1
    end

    switch $argv[1]
        case -h --help
            echo "Usage: gw branch <name>"
            echo ""
            echo "  Create a worktree holding a new branch based on the current HEAD (no fetch)."
            echo "  See 'gw new' for a new branch based on the remote's default branch."
            return 0
        case '-*'
            echo "gw branch: unknown option '$argv[1]'" >&2
            return 1
    end

    _gw_create_worktree $argv[1]
end
