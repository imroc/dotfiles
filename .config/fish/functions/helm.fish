function helm --wraps=helm --description "wrap helm with extra advanced feature"
    set original_args $argv
    argparse --ignore-unknown "kube-context=" -- $original_args 2>/dev/null

    set common_args ()
    if test -z "$_flag_kube_context"; and test -n "$KUBECTL_CONTEXT"
        set -a common_args --kube-context "$KUBECTL_CONTEXT"
    end

    if test -z "$common_args"
        command helm $original_args
    else
        command helm $common_args $argv
    end
end
