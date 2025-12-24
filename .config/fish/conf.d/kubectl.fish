# watch events sort by timestamp
abbr --add kge "kubectl get events --sort-by='.lastTimestamp' -w"

abbr --add sd0 'kubectl get deployments.v1.apps | grep -v NAME | awk \'{print $1}\' | xargs -I {} kubectl scale deployments.v1.apps --replicas=0 {}'
abbr --add sd1 'kubectl get deployments.v1.apps | grep -v NAME | awk \'{print $1}\' | xargs -I {} kubectl scale deployments.v1.apps --replicas=1 {}'

# kubectl plugins
abbr --add kvc kubectl view-cert
abbr --add kc kubectl kc
abbr --add kk kubectl klock
abbr --add krew kubectl krew
abbr --add kf kubectl fuzzy
abbr --add kfd 'kubectl fuzzy describe'
abbr --add kxp kubectl explore
abbr --add kn kubectl neat

# kustomize 相关
abbr --add kz kustomize
abbr --add kb 'kustomize build --enable-helm --load-restrictor=LoadRestrictionsNone .'
abbr --add kka 'kustomize build --enable-helm --load-restrictor=LoadRestrictionsNone . | kubectl apply --server-side=true -f -'
abbr --add kkd 'kustomize build --enable-helm --load-restrictor=LoadRestrictionsNone . | kubectl delete --server-side=true -f -'

abbr --add km 'kubectl -n monitoring'
abbr --add kr 'kubectl api-resources'
abbr --add kgpa 'kubectl get pod -o wide -A'
abbr --add kgpw 'kubectl get pod -o wide'
abbr --add kgvh 'kubectl get validatingwebhookconfigurations'
abbr --add kgmh 'kubectl get mutatingwebhookconfigurations'

# 获取 ingress 的 conditon
abbr --add kgingc 'kubectl get ingress -o jsonpath='\''{.metadata.annotations.ingress\.cloud\.tencent\.com\/status\.conditions}'\'''

abbr --add kx "kubie ctx"
abbr --add ks "kubectl ns"
abbr --add kss "kubectl ns kube-system"
abbr --add ksd "kubectl ns default"
abbr --add kst "kubectl ns test"

abbr --add kgc "kubectl get pods -o jsonpath='{.spec.containers[*].name}'"
abbr --add kno "kubectl node-shell"
abbr --add kpo "kubectl pod-shell"
abbr --add ke "kubectl edit"
abbr --add kl "kubectl logs --tail 2000"

# 获取 node 的 uuid
abbr --add kguuid "kubectl get node -o=custom-columns=NAME:.metadata.name,UUID:.status.nodeInfo.systemUUID"
# 获取 podCIDR
abbr --add kgcidr "kubectl get node -o=custom-columns=NAME:.metadata.name,INTERNAL-IP:.status.addresses[0].address,CIDR:.spec.podCIDR"
# 获取 node IP (公网+内网+podCIDR)
abbr --add kgnodeip "kubectl get no -o=custom-columns=NAME:.metadata.name,INTERNAL-IP:.status.addresses[0].address,EXTERNAL-IP:.status.addresses[1].address,CIDR:.spec.podCIDR"
# 获取 node 可用区
abbr --add kgzone 'kubectl get node -o custom-columns=NAME:.metadata.name,ZONE:".metadata.labels.topology\.kubernetes\.io/zone"'
# 获取命名空间内pod的镜像列表
abbr --add kgimages 'kubectl get pod -ojsonpath=\'{range .items[*]}{range .spec.containers[*]}{"\n"}{.image}{end}{end}\' | sort | uniq'

# watch
abbr --add kw 'kubectl klock pod -o wide'
abbr --add kwn 'kubectl klock node -o wide'
