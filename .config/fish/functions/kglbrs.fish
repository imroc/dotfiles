function kglbrs --description "获取全部的 LoadBalancerResource 概览信息"
    kubectl get LoadBalancerResource -ojsonpath='{range .items[*]}{.metadata.name}{range .spec.listeners[*]}{"\n"}{"\t"}{.port} {.protocol}{range .references[*]}{"\n"}{"\t\t"}{.kind}{"\t"}{.namespace}/{.name}{end}{end}{"\n"}{end}'
end
