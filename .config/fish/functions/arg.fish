function arg --description "argocd app get"
    set app (command argocd app list -o name | fzf -0)
    command argocd app get $app
end
