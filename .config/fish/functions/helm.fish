function helm --wraps=helm --description "wrap helm with extra advanced feature"
    set original_args $argv
    argparse --ignore-unknown "kube-context=" -- $original_args 2>/dev/null

    set common_args ()
    if test -z "$_flag_kube_context"; and test -n "$KUBE_CONTEXT"
        set -a common_args --kube-context "$KUBE_CONTEXT"
    end

    set -l proxy_env
    if set -q KUBE_PROXY
        set proxy_env HTTPS_PROXY=$KUBE_PROXY
    end

    if test -z "$common_args"
        env $proxy_env helm $original_args
    else
        env $proxy_env helm $common_args $argv
    end
end
