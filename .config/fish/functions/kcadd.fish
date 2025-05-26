function kcadd --description "Merge kubeconfig use kubecm"
    if test -z "$argv[1]"
        echo "need kubeconfig file name!"
        return
    end
    kubectl kc delete $argv[1]
    kubectl kc add --context-name=$argv[1] -cf $argv[1]
end
