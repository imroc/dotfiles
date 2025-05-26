function arr --description "argocd app get --refresh"
    set app (command argocd app list -o name | fzf -0)
    command argocd app get --refresh $app
end
