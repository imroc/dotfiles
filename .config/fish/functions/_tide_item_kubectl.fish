function _tide_item_kubectl
    if not command -sq kubectl
        return
    end

    set kubectl (command -s kubectl) # 避免调用到 kubectl 函数
    set context ($kubectl config view --minify --output 'jsonpath={.current-context}|{..namespace}' 2>/dev/null)
    set parts (string split "|" $context)
    set current_context "$parts[1]"
    set current_namespace "$parts[2]"
    set current_context "$KUBECTL_TKE_CLUSTER_ID"

    if test -n "$KUBECTL_TKE_CLUSTER_ID"
        if command -sq yq
            set cluster_alias (command yq ".$KUBECTL_TKE_CLUSTER_ID" <$HOME/.kube/tke-cluster-alias.yaml)
            if test $status -eq 0; and test "$cluster_alias" != null
                set current_context "$cluster_alias($KUBECTL_TKE_CLUSTER_ID)"
            end
        end
    end
    if test -n "$KUBECTL_NAMESPACE"
        set current_namespace "$KUBECTL_NAMESPACE"
    end

    if test -n "$current_context"
        if test -n "$current_namespace"; and test "$current_namespace" != default
            set prompt "$current_context|$current_namespace"
        else
            set prompt "$current_context"
        end
        _tide_print_item kubectl $tide_kubectl_icon' ' "$prompt"
    end
end
