function kubectl --wraps=kubectl --description "wrap kubectl with extra advanced feature"
    set -l subcommand (__parse_subcommand $argv)
    if test -z "$subcommand"
        __kubecolor $argv
        return
    end

    switch $subcommand
        case ns
            __switch_ns $argv[2..-1]
        case clear # Clear kubeconfig
            __clear_kube_env
        case color
            __toggle_color
        case node-shell # kubectl node-shell to login to node, supports fzf completion for nodes
            __login_node $argv[2..-1]
        case pod-shell # kubectl pod-shell to login to pod, supports fzf completion for pods
            __login_pod $argv[2..-1]
        case get # Enhanced kubectl get: supports bat for pretty output, neovim for yaml, fx for json, get configmap/secret file content, view certificate info, watch resource events, etc.
            __kubectl_get $argv
        case ianvs ctx neat krew # kubectl plugins that don't need global arguments passed through (to avoid errors from unsupported flags)
            __kubecolor $argv
        case '*'
            __kubectl_with_common_args $argv
    end
end

function __kubecolor
    if not test "$__kubectl_disable_color" = 1; and command -sq kubecolor
        command kubecolor $argv
    else
        command kubectl $argv
    end
end

function __kubectl_with_common_args
    # pass common args to subcommands by default
    set -l common_args (__get_common_args $argv)
    # If first argument starts with - (is a flag, not subcommand), put common_args at the front.
    # Otherwise, first argument is the subcommand, which might be a kubectl plugin.
    # common_args must come after the plugin name, otherwise it errors that flags cannot precede plugins.
    if string match -q -- '-*' $argv[1]
        __kubecolor $common_args $argv
    else
        __kubecolor $argv[1] $common_args $argv[2..-1]
    end
end

function __parse_subcommand
    # Parse subcommand: skip flags and their values to find the actual subcommand
    # Boolean flags (no value): -v, -h, --help, --version, etc.
    # Value flags: -n <ns>, --context <ctx>, -s <server>, etc.
    set -l i 1
    set -l bool_flags v h help version warnings
    while test $i -le (count $argv)
        set -l arg $argv[$i]
        if string match -q -- '-*' $arg
            # Flag argument, check if it needs a value
            # 1. --key=value or -k=value format: no need to skip next arg
            # 2. Boolean flags: no need to skip next arg
            # 3. Other flags: skip next arg as value
            if not string match -q -- '*=*' $arg
                # Extract flag name (remove leading dashes)
                set -l flag_name (string replace -r -- '^-+' '' $arg)
                if not contains $flag_name $bool_flags
                    # Skip the next argument as flag value
                    set i (math $i + 1)
                end
            end
        else
            # First non-flag argument is the subcommand
            printf "%s" $arg
            return
        end
        set i (math $i + 1)
    end
end

function __get_current_context --description "Get current context name"
    if set -q KUBECTL_CONTEXT
        echo $KUBECTL_CONTEXT
    else
        command kubectl config view -o jsonpath='{.current-context}' 2>/dev/null
    end
end

function __switch_ns --description "Switch namespace"
    if set -q KUBIE_ACTIVE
        kubie ns $argv
        return
    end
    set -l ns "$argv[1]"
    if test -z "$ns"
        set ns (kubectl get namespaces -o json | jq -r '.items[].metadata.name' | fzf --prompt="Select namespace: " --height=40% --reverse)
        if test -z "$ns"
            echo "Please select a namespace"
            return 1
        end
    end
    # Get current context
    set -l current_context (__get_current_context)
    if test -z "$current_context"
        echo "Error: unable to get current context"
        return 1
    end
    # Set namespace
    command kubectl config set-context "$current_context" --namespace=$ns 2>&1 >/dev/null
    echo "Namespace switched to $ns"
end

function __clear_kube_env --description "Clear env"
    if set -q KUBIE_ACTIVE
        echo "In kubie shell, cannot clear KUBECONFIG environment variable"
        return 1
    end
    if set -q KUBECONFIG
        set -e KUBECONFIG
        echo "KUBECONFIG has been unset"
    end
    if set -q KUBECTL_CONTEXT
        set -e KUBECTL_CONTEXT
        echo "KUBECTL_CONTEXT has been unset"
    end
end

function __toggle_color --description "Toggle color"
    if not command -sq kubecolor
        echo "kubecolor is not installed"
        return
    end
    if set -q __kubectl_disable_color
        set -e __kubectl_disable_color
        echo "Color output enabled"
    else
        set -g __kubectl_disable_color 1
        echo "Color output disabled"
    end
end

function __login_node --description "Login to node"
    set -l common_args (__get_common_args $argv)
    set -l node $argv[1]
    if test -z "$node" # No argument after subcommand, list all nodes and select with fzf (excluding virtual nodes that cannot be logged into)
        # Use node-shell to login to node
        set node (command kubectl get node $common_args -o json | jq -r '.items[].metadata.name' | grep -v eklet- | fzf -0)
        if test -z "$node"
            echo "No node selected"
        end
        command kubectl node-shell $node $common_args
    else
        command kubectl node-shell $node $common_args $argv[2..-1]
    end
end

function __login_pod --description "Login to pod"
    set -l common_args (__get_common_args $argv)
    set -l pod_list (command kubectl get pod $common_args -o json)
    set -l pod $argv[1]
    if test -z "$pod"
        # Select pod with fzf
        set pod (printf "%s" "$pod_list" | jq -r '.items[].metadata.name' | fzf --prompt "select pod: " -0)
        if test -z "$pod"
            echo "No pod selected"
            return
        end
    end
    set -l container (printf "%s" "$pod_list" | jq -r ".items[] | select(.metadata.name == \"$pod\") | .status.containerStatuses[]?.name" | fzf --prompt "select container: " -0 -1)
    if test -z "$container"
        echo "No container selected"
        return
    end
    set -l shell (printf "/bin/bash\n/bin/sh\nfish\nzsh" | fzf --prompt "select shell: ")
    if test -z "$shell"
        read --prompt-str "input shell manually: " shell
        if test -z "$shell"
            echo "No shell specified"
            return
        end
    end
    echo "login container $container in pod $pod with shell $shell"
    kubectl exec $common_args -it $pod -c $container -- $shell
end

function __kubectl_get --description "Override kubectl get"
    set -l common_args (__get_common_args $argv)
    set original_args $argv
    # Parse global arguments and remove them from argv to determine subcommand and its arguments
    argparse --ignore-unknown --strict-longopts \
        "o/output=" "v/v=" "kubeconfig=" \
        "s/server=" "cluster=" "user=" "username=" "token=" "password=" \
        "client-certificate=" "client-key=" "tls-server-name=" "certificate-authority=" insecure-skip-tls-verify \
        "as=" "as-group=" "as-uid=" \
        -- $original_args 2>/dev/null # Ignore parsing errors from argparse

    set -l resource_type $argv[2]
    set -l resource_name $argv[3]
    # If resource type and name are not specified, skip the following parsing
    if test -n "$resource_type" -a -n "$resource_name"
        # Parse custom arguments -e -E -j -p -P -c -C -W to extend get command functionality
        argparse --ignore-unknown e E j p P c C W -- $original_args
        set -l args $common_args $argv # Remove custom flags, add common flags(-n/--context)

        if set -q _flag_c; or set -q _flag_C # -c/-C flag set, view certificate info, supports certificate and secret resource types
            if string match -rq '^cert' -- "$resource_type" # Certificate resource type
                set cmd cmctl status certificate $common_args $resource_name
            else if string match -rq '^secrets?$' -- "$resource_type" # Secret resource type
                set cmd cmctl inspect secret $common_args $resource_name
            end
            if set -q cmd
                if set -q _flag_C
                    command $cmd | nvim
                else
                    command $cmd | less
                end
            else
                echo "'-c' and '-C' flags only support certificate and secret resource types"
            end
            return
        else if set -q _flag_p; or set -q _flag_P # -p/-P flag set, select filename from configmap/secret to open. -p prints content to terminal; -P opens content in neovim.
            set -l filename (command kubectl $args -o json | jq -r '.data | keys | .[]' | fzf -1 -0)
            if test -z "$filename" # Empty configmap/secret, return directly
                echo "empty configmap or secret"
                return
            end
            set -l escaped_filename (string replace -a -- '.' '\\.' $filename)
            set -a args -o jsonpath="{.data.$escaped_filename}"
            set -l result (command kubectl $args | string collect)
            if not test $status -eq 0
                return
            end
            if string match -rq '^secrets?$' -- "$resource_type" # Secret resource needs base64 decoding
                set result (printf "%s" "$result" | base64 -d | string collect)
                if not test $status -eq 0
                    return
                end
            end
            if set -q _flag_P # -P specified, open with nvim
                set filename /tmp/$filename
                printf "%s" "$result" >$filename && nvim $filename && rm $filename
                return
            end
            # If color is not disabled, print with bat
            if not test "$__kubectl_disable_color" = 1
                printf "%s" "$result" | bat --file-name "$filename"
                return
            end
            # Color disabled, print directly
            printf "%s" "$result"
            return
        else if set -q _flag_j # -j flag set, output in json format and open with fx
            command kubectl $args -o json | fx
            return
        else if set -q _flag_W # -W flag set, watch events
            command kubectl $args -o json 2>&1 | read -z output
            if not test $status -eq 0
                echo "Error fetching resource: $output"
                return
            end
            # Watch events for this resource (add -A flag based on whether the resource is cluster-scoped)
            if echo $output | jq -e '.metadata | has("namespace")' >/dev/null
                __kubecolor events $common_args --for="$resource_type/$resource_name" -w
                return
            else
                __kubecolor events $common_args --for="$resource_type/$resource_name" -w -A
                return
            end
        else if set -q _flag_e # -e flag set, save content to file and open with nvim (enables LSP for hints and completion)
            set -l output_format $_flag_o
            if test -z "$output_format"
                set -a args -o yaml
                set output_format yaml
            end
            set -l filename /tmp/$resource_type-$resource_name.$output_format
            command kubectl $args >$filename && nvim $filename && rm $filename
            return
        else if set -q _flag_E # -E flag set, clean content with kubectl neat, save to file and open with nvim (enables LSP for hints and completion)
            set -l output_format $_flag_o
            if test -z "$output_format"
                set -a args -o yaml
                set output_format yaml
            end
            set -l filename /tmp/$resource_type-$resource_name.$output_format
            command kubectl $args | command kubectl neat >$filename && nvim $filename && rm $filename
            return
        end
        # No custom arguments set for kubectl get, try to render content with bat based on "-o/--output" format
        if not test "$__kubectl_disable_color" = 1; and test -n "$_flag_o"
            switch $_flag_o
                case yaml json
                    command kubectl $args | bat --language "$_flag_o"
                    return
            end
        end
    end
    __kubecolor $common_args $original_args
end

function __get_common_args
    argparse --ignore-unknown --strict-longopts "context=" -- $argv 2>/dev/null

    # If KUBECTL_CONTEXT env var is set and --context is not explicitly specified, auto-append --context
    if test -z "$_flag_context"; and test -n "$KUBECTL_CONTEXT"
        printf '%s\n' --context "$KUBECTL_CONTEXT"
    end
end
