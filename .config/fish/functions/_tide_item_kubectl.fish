function _tide_item_kubectl
    if not command -sq kubectl
        return
    end

    set kubectl (command -s kubectl) # 避免调用到 kubectl 函数

    # 获取当前 context
    set current_context "$KUBECTL_CONTEXT"
    if test -z "$current_context"
        set -l context ($kubectl config current-context 2>/dev/null)
        if test $status -eq 0; and test -n "$context"
            set current_context $context
        end
    end

    if test -n "$current_context"
        set context_name "$KUBECTL_CONTEXT_NAME"
        if test -z "$context_name"
            set context_name "$current_context"
        end
        set current_namespace ($kubectl config view --output jsonpath="{.contexts[?(@.name==\"$current_context\")].context.namespace}" 2>/dev/null)
        if test -n "$current_namespace"; and test "$current_namespace" != default
            set prompt "$context_name|$current_namespace"
        else
            set prompt "$context_name"
        end
        _tide_print_item kubectl $tide_kubectl_icon' ' "$prompt"
    end
end
