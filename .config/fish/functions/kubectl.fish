function kubectl --wraps=kubectl --description "wrap kubectl with extra advanced feature"
    # 保留原始参数备用
    set original_args $argv
    # 解析全局参数并从 argv 中移除，以便后续判断子命令与子命令参数
    argparse --ignore-unknown \
        "n/namespace=" "o/output=" \
        "context=" "v/v=" "kubeconfig=" \
        "s/server=" "cluster=" "user=" "username=" "token=" "password=" \
        "client-certificate=" "client-key=" "tls-server-name=" "certificate-authority=" insecure-skip-tls-verify \
        "as=" "as-group=" "as-uid=" \
        -- $original_args 2>/dev/null # 忽略解析错误，因为 argparse

    # 包装、增强指定的子命令
    set subcommand "$argv[1]"
    switch $subcommand
        case cc # clean config
            set -e KUBECONFIG
            echo "KUBECONFIG has been unset"
            return
        case color
            if not command -sq kubecolor
                echo "kubecolor not installed"
                return
            end
            if set -q DISABLE_KUBECTL_COLOR
                set -e DISABLE_KUBECTL_COLOR
                echo "color enabled"
            else
                set -g DISABLE_KUBECTL_COLOR 1
                echo "color disabled"
            end
            return
        case node-shell login # kubectl login / kubectl node-shell 登录节点，支持 fzf 补全节点
            set node $argv[2]
            if test -z "$node" # 子命令后没有参数，列出所有节点并用 fzf 选择（不包含无法登录的虚拟节点）
                # 利用 node-shell 登录节点
                set node (command kubectl get node -o json | jq -r '.items[].metadata.name' | grep -v eklet- | fzf -0)
                if test -n "$node"
                    command kubectl node-shell $node
                else
                    echo "no node selected"
                end
                return
            end
        case get # 增强 kubectl get，支持用 bat 美化输出、用 neovim 以 yaml 格式打开、用 fx 以 json 格式打开、获取 configmap/secret 中的文件内容等
            set resource_type $argv[2]
            set resource_name $argv[3]
            # 如果没有指定资源类型和资源名，不再执行后面的解析
            if test -n "$resource_type" -a -n "$resource_name"
                # 解析增加的自定义参数 -e -E -j -p -P -c -C -W 来扩展 get 命令的功能
                argparse --ignore-unknown e E j p P c C W -- $original_args
                set args $argv

                if set -q _flag_c; or set -q _flag_C # 设置了 -c/-C 参数，查看证书信息，支持 certificate 和 secret 资源类型
                    if string match -rq '^cert' -- "$resource_type" # 证书类型资源
                        set cmd cmctl status certificate $resource_name
                    else if string match -rq '^secrets?$' -- "$resource_type" # secret 类型资源
                        set cmd cmctl inspect secret $resource_name
                    end
                    if set -q cmd
                        if test -n "$_flag_n" # 追加 namespace
                            set -a cmd -n $_flag_n
                        end
                        if set -q _flag_context # 追加 context
                            set -a cmd --context $_flag_context
                        end
                        if set -q _flag_C
                            command $cmd | nvim
                        else
                            command $cmd | less
                        end
                    else
                        echo "'-c' 和 '-C' 参数仅支持 certificate 和 secret 资源类型"
                    end
                    return
                else if set -q _flag_p; or set -q _flag_P # 设置了 -p/-P 参数，选择 configmap/secret 中的文件名打开。-p 直接将文件内容打印到终端；-P 使用 neovim 打开文件内容。
                    set filename (command kubectl $args -o json | jq -r '.data | keys | .[]' | fzf -1 -0)
                    if test -z "$filename" # 空 configmap/secret，直接返回
                        echo "empty configmap or secret"
                        return
                    end
                    set escaped_filename (string replace -a '.' '\\.' $filename)
                    set -a args -o jsonpath="{.data.$escaped_filename}"
                    set filename /tmp/$filename
                    if string match -rq '^secrets?$' -- "$resource_type" # secret 类型需 base64 解码
                        if set -q _flag_P
                            command kubectl $args | base64 -d >$filename && nvim $filename && rm $filename
                        else
                            command kubectl $args | base64 -d
                        end
                    else
                        if set -q _flag_P
                            command kubectl $args >$filename && nvim $filename && rm $filename
                        else
                            command kubectl $args
                        end
                    end
                    return
                else if set -q _flag_j # 设置了 -j 参数，用 json 格式输出并用 fx 打开
                    command kubectl $args -o json | fx
                    return
                else if set -q _flag_W # 设置了 -W 参数，watch 事件
                    command kubectl $args -o json 2>&1 | read -z output
                    if not test $status -eq 0
                        echo "Error fetching resource: $output"
                        return
                    end
                    # watch 该资源的相关事件（根据资源是否是集群范围的来决定是否需要加 -A 参数）
                    if echo $output | jq -e '.metadata | has("namespace")' >/dev/null
                        __kubecolor events --for="$resource_type/$resource_name" -w
                        return
                    else
                        __kubecolor events --for="$resource_type/$resource_name" -w -A
                        return
                    end
                else if set -q _flag_e # 设置了 -e 参数，将内容存到文件并用 nvim 打开（会启动 LSP，提供提示和补全的能力）
                    set -l output_format $_flag_o
                    if test -z "$output_format"
                        set -a args -o yaml
                        set output_format yaml
                    end
                    set filename /tmp/$resource_type-$resource_name.$output_format
                    command kubectl $args >$filename && nvim $filename && rm $filename
                    return
                else if set -q _flag_E # 设置了 -E 参数，将内容通过 kubectl neat 精简后存到文件并用 nvim 打开（会启动 LSP，提供提示和补全的能力）
                    set -l output_format $_flag_o
                    if test -z "$output_format"
                        set -a args -o yaml
                        set output_format yaml
                    end
                    set filename /tmp/$resource_type-$resource_name.$output_format
                    command kubectl $args | kubectl neat >$filename && nvim $filename && rm $filename
                    return
                end
                # 没有为 kubectl get 设置任何自定义参数，尝试根据 "-o/--output" 参数指定的格式用 bat 渲染内容
                if not test "$DISABLE_KUBECTL_COLOR" = 1; and test -n "$_flag_o"
                    switch $_flag_o
                        case yaml json
                            command kubectl $args | bat --language "$_flag_o"
                            return
                    end
                end
            end
    end
    __kubecolor $original_args
end

function __kubecolor
    if not test "$DISABLE_KUBECTL_COLOR" = 1; and command -sq kubecolor
        command kubecolor $argv
    else
        command kubectl $argv
    end
end
