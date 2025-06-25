function _tide_item_kubectl
    if not command -sq kubectl
        return
    end

    set kubectl (command -s kubectl) # 避免调用到 kubectl 函数
    set context ($kubectl config view --minify --output 'jsonpath={.current-context}/{..namespace}' 2>/dev/null)
    set parts (string split "/" $context)
    set current_context "$parts[1]"
    set current_namespace "$parts[2]"
    if test -n "$current_context"; and test -n "$current_namespace"; and test "$current_namespace" != default
        set prompt "$current_context/$current_namespace"
        _tide_print_item kubectl $tide_kubectl_icon' ' "$prompt"
    end
end
