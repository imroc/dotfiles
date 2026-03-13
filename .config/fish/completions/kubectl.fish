kubectl completion fish 2>/dev/null | source

# 覆盖 __kubectl_perform_completion：过滤 tke kubectl 在 stdout 中多余的 directive 描述行
# tke kubectl __complete 会在 stdout 输出 "Completion ended with directive: ..." 行，
# 原始 kubectl 将其输出到 stderr（会被 2>/dev/null 丢弃），但 tke kubectl 混入了 stdout，
# 导致补全脚本中 math 解析 directive 失败
function __kubectl_perform_completion
    __kubectl_debug "Starting __kubectl_perform_completion"

    set -l args (commandline -opc)
    set -l lastArg (string escape -- (commandline -ct))

    __kubectl_debug "args: $args"
    __kubectl_debug "last arg: $lastArg"

    set -l requestComp "KUBECTL_ACTIVE_HELP=0 $args[1] __complete $args[2..-1] $lastArg"

    __kubectl_debug "Calling $requestComp"
    set -l results (eval $requestComp 2> /dev/null)

    # 过滤 tke kubectl 在 stdout 中输出的 "Completion ended with directive:" 行
    set -l filtered
    for line in $results
        if not string match -q 'Completion ended with directive:*' -- $line
            set -a filtered $line
        end
    end
    set results $filtered

    # Some programs may output extra empty lines after the directive.
    for line in $results[-1..1]
        if test (string trim -- $line) = ""
            set results $results[1..-2]
        else
            break
        end
    end

    set -l comps $results[1..-2]
    set -l directiveLine $results[-1]

    set -l flagPrefix (string match -r -- '-.*=' "$lastArg")

    __kubectl_debug "Comps: $comps"
    __kubectl_debug "DirectiveLine: $directiveLine"
    __kubectl_debug "flagPrefix: $flagPrefix"

    for comp in $comps
        printf "%s%s\n" "$flagPrefix" "$comp"
    end

    printf "%s\n" "$directiveLine"
end

function __fish_kubectl_ns
    kubectl get namespaces -o json | jq -r '.items[].metadata.name'
end

function __fish_kubectl_node_list_to_login
    kubectl get node -o json | jq -r '.items[].metadata.name' | grep -v eklet-
end

function __fish_kubectl_pod_list
    kubectl get pod -o json | jq -r '.items[].metadata.name'
end

complete -c kubectl -f -n "__fish_seen_subcommand_from ns" -a "(__fish_kubectl_ns)" -d Namespace
complete -c kubectl -f -n "__fish_seen_subcommand_from node-shell" -a "(__fish_kubectl_node_list_to_login)" -d NodeShell
complete -c kubectl -f -n "__fish_seen_subcommand_from pod-shell" -a "(__fish_kubectl_pod_list)" -d PodShell
