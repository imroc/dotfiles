function k9s --wraps=k9s --description "wrap k9s with extra advanced feature"
    set original_args $argv
    argparse --ignore-unknown "context=" -- $original_args 2>/dev/null

    set common_args ()
    if test -z "$_flag_context"; and test -n "$KUBE_CONTEXT"
        set -a common_args --context "$KUBE_CONTEXT"
    end

    if test -z "$common_args"
        k9s $original_args
    else
        k9s $common_args $argv
    end
end
