function kgvip --description "kubectl get vip"
    kubectl get vip -o json | jq -r '
    .items[] | 
    [
      .metadata.name,
      (if .spec.type == "Elastic Kubernetes Service" then "EKS" else .spec.type end),
      .status.phase,
      (.metadata.labels["tke.cloud.tencent.com/eni-id"] // .spec.resourceID // " " * 12),
       (.spec.cniType // " " * 13),
      (if .spec.type == "Pod" then 
        (.spec.claimRef.namespace + "/" + .spec.claimRef.name)
       elif .spec.type == "Node" then 
        .spec.necRef.name
       else 
        ""
       end)
    ] | join("\t")
  '
end
