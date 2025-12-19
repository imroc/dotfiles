function __fish_cilium_node_list_to_login
    kubectl get node -o json | jq -r '.items[].metadata.name' | grep -v eklet-
end

complete -c cilium -f -n "__fish_seen_subcommand_from login" -a "(__fish_cilium_node_list_to_login)" -d CiliumLogin
