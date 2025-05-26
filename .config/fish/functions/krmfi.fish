function krmfi --description "remove all finalizers for a kind"
    set resource (command kubectl api-resources -o name | fzf -0)
    kubectl get $resource -o name | xargs -I {} kubectl patch {} -p '{"metadata":{"finalizers":null}}' --type=merge
end
