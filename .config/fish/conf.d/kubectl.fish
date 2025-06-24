# watch events sort by timestamp
abbr --add kge "kubectl get events --sort-by='.lastTimestamp' -w"

abbr --add sd0 'kubectl get deployments.v1.apps | grep -v NAME | awk \'{print $1}\' | xargs -I {} kubectl scale deployments.v1.apps --replicas=0 {}'
abbr --add sd1 'kubectl get deployments.v1.apps | grep -v NAME | awk \'{print $1}\' | xargs -I {} kubectl scale deployments.v1.apps --replicas=1 {}'

# kubectl plugins
abbr --add kvc kubectl-view-cert
abbr --add kc kubectl-kc
abbr --add kk kubectl-klock
abbr --add krew kubectl-krew
abbr --add kf kubectl-fuzzy
abbr --add kfd 'kubectl-fuzzy describe'
abbr --add kxp kubectl-explore
abbr --add kn kubectl-neat

# kustomize 相关
abbr --add kz kustomize
abbr --add kb 'kustomize build --enable-helm --load-restrictor=LoadRestrictionsNone .'
abbr --add kka 'kustomize build --enable-helm --load-restrictor=LoadRestrictionsNone . | kubectl apply --server-side=true -f -'

abbr --add km 'kubectl -n monitoring'
abbr --add kgpa 'kubectl get pod -o wide -A'
abbr --add kgpw 'kubectl get pod -o wide'

# 获取 LBR 的概览信息
abbr --add kglbr 'kubectl get LoadBalancerResource -ojsonpath='\''{.metadata.name}{range .spec.listeners[*]}{"\n"}{"\t"}{.port} {.protocol}{range .references[*]}{"\n"}{"\t\t"}{.kind}{"\t"}{.namespace}/{.name}{end}{end}{"\n"}'\'''
abbr --add kglbrs 'kubectl get LoadBalancerResource -ojsonpath='\''{range .items[*]}{.metadata.name}{range .spec.listeners[*]}{"\n"}{"\t"}{.port} {.protocol}{range .references[*]}{"\n"}{"\t\t"}{.kind}{"\t"}{.namespace}/{.name}{end}{end}{"\n"}{end}'\'''

# 获取 ingress 的 conditon
abbr --add kgingc 'kubectl get ingress -o jsonpath='\''{.metadata.annotations.ingress\.cloud\.tencent\.com\/status\.conditions}'\'''

# kubie 相关
abbr --add kx "kubie ctx"
abbr --add ks "kubie ns"
abbr --add kss "kubie ns kube-system"

abbr --add kns "kubectl ns"
abbr --add knss "kubectl ns kube-system"
abbr --add kgc "kubectl get pods -o jsonpath='{.spec.containers[*].name}'"
abbr --add kno "kubectl node-shell"
abbr --add ke "kubectl edit"
abbr --add kl "kubectl logs --tail 2000"
