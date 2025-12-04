function _tide_item_kubectl
    if not command -sq kubectl
        return
    end

    set kubectl (command -s kubectl) # 避免调用到 kubectl 函数

    set current_context "$KUBECTL_CONTEXT"
    if test -z "$current_context"
        set current_context ($kubectl config current-context)
    end

    if test -n "$current_context"
        set current_namespace ($kubectl config view --output jsonpath="{.contexts[?(@.name==\"$current_context\")].context.namespace}" 2>/dev/null)
        if test -n "$current_namespace"; and test "$current_namespace" != default
            set prompt "$current_context|$current_namespace"
        else
            set prompt "$current_context"
        end
        _tide_print_item kubectl $tide_kubectl_icon' ' "$prompt"
    end
end
