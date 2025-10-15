function cilium --wraps=cilium --description "wrap cilium with extra advanced feature"
    # 包装、增强指定的子命令
    set subcommand "$argv[1]"
    switch $subcommand
        case login
            set node (command kubectl get node -o json | jq -r '.items[].metadata.name' | grep -v eklet- | fzf -0)
            if test -z "$node"
                echo "no node selected"
                return
            end
            set -l pod $(kubectl --namespace=kube-system get pod --field-selector spec.nodeName=$node -l k8s-app=cilium -o json | jq -r '.items[0].metadata.name')
            kubectl --namespace=kube-system exec -it $pod -- bash
        case '*'
            command cilium $argv
    end
end
