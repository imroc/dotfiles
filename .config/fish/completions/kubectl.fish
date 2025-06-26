kubectl completion fish 2>/dev/null | source

function __fish_kubectl_ns
    command kubectl get namespaces -o json | jq -r '.items[].metadata.name'
end

function __fish_kubectl_node_shell
    command kubectl get node -o json | jq -r '.items[].metadata.name' | grep -v eklet-
end

function __fish_kubectl_pod_shell
    command kubectl get pod -o json | jq -r '.items[].metadata.name'
end

complete -c kubectl -f -n "__fish_seen_subcommand_from ns" -a "(__fish_kubectl_ns)" -d Namespace
complete -c kubectl -f -n "__fish_seen_subcommand_from node-shell" -a "(__fish_kubectl_node_shell)" -d NodeShell
complete -c kubectl -f -n "__fish_seen_subcommand_from pod-shell" -a "(__fish_kubectl_pod_shell)" -d PodShell
