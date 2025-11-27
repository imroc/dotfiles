function kglbr --description "获取指定的 LoadBalancerResource 概览信息"
    set -l lbr "$argv[1]"
    if test -z "$lbr"
        echo "请输入 LoadBalancerResource 名称"
        return 1
    end
    kubectl get LoadBalancerResource -ojsonpath='{.metadata.name}{range .spec.listeners[*]}{"\n"}{"\t"}{.port} {.protocol}{range .references[*]}{"\n"}{"\t\t"}{.kind}{"\t"}{.namespace}/{.name}{end}{end}{"\n"}' "$lbr"
end
