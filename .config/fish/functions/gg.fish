function gg --description "Git auto commit and push"
    git add -A
    set -l msg "update at $(date '+%Y-%m-%d %H:%M:%S')"
    git commit -m $msg
    git push
end
