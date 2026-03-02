abbr --add g git
#abbr --add gs 'git status'
#abbr --add gr 'git remote -v'
#abbr --add gpull "git pull"
#abbr --add gpush "git push"
abbr --add groot 'cd $(git rev-parse --show-toplevel)'
abbr --add gsa 'git submodule add --depth=1'
#abbr --add gsu 'git submodule update --init --depth=1'
abbr --add gls "git pull --recurse-submodule=yes"
abbr --add gc1 "git clone --depth=1"

abbr --add lg lazygit

abbr --add gwa git worktree add
abbr --add gwl git worktree list
abbr --add gwr git worktree remove
