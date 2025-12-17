function k9s --wraps=k9s --description "wrap k9s with extra advanced feature"
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
        command k9s $original_args
    else
        command k9s $common_args $argv
    end
end
