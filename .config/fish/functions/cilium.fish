function cilium --wraps=cilium --description "wrap cilium with extra advanced feature"

    # 包装、增强指定的子命令
    set subcommand "$argv[1]"
    switch $subcommand
        case login
            set -l node "$argv[2]"
            if test -z "$node"
                set node (kubectl get node -o json | jq -r '.items[].metadata.name' | grep -v eklet- | fzf -0)
                if test -z "$node"
                    echo "no node selected"
                    return
                end
            end
            set -l pod (kubectl --namespace=kube-system get pod --field-selector spec.nodeName=$node -l k8s-app=cilium -o json | jq -r '.items[0].metadata.name')
            if test -z "$pod"
                echo "cilium pod not found on node $node"
                return 1
            end
            kubectl --namespace=kube-system exec -it $pod -- bash
            return
    end

    set original_args $argv
    argparse --ignore-unknown \
        "n/namespace=" "context=" \
        -- $original_args 2>/dev/null

    set common_args ()
    if test -z "$_flag_context"; and test -n "$KUBECTL_CONTEXT"
        set -a common_args --context "$KUBECTL_CONTEXT"
    end
    if test -z "$_flag_n"; and test -n "$KUBECTL_NAMESPACE"
        set -a common_args --namespace "$KUBECTL_NAMESPACE"
    end

    if test -z "$common_args"
        command cilium $original_args
    else
        command cilium $common_args $argv
    end
end
