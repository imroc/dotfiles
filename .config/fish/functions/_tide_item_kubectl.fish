function _tide_item_kubectl
    if not command -sq kubectl
        return
    end

    set kubectl (command -s kubectl) # 避免调用到 kubectl 函数

    set current_context "$KUBECTL_CONTEXT_NAME"
    set current_namespace "$KUBECTL_NAMESPACE"
    if test -z "$current_context"; or test -z "$current_namespace"
        set context ($kubectl config view --minify --output 'jsonpath={.current-context}|{..namespace}' 2>/dev/null)
        set parts (string split "|" $context)
        if test -z "$current_context"
            set current_context "$parts[1]"
        end
        if test -z "$current_namespace"
            set current_namespace "$parts[2]"
        end
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
