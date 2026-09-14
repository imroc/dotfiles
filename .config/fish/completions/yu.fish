# yu 的补全：复用 yadm 官方补全的通用逻辑（判断子命令、包装 git 补全），
# 只是把命令名从 yadm 换成 yu。yadm-dir / yadm-data 已写死在脚本里，无需再补全。

function __fish_yu_universial_optspecs
    string join \n 'a-yadm-dir=' 'b-yadm-repo=' 'c-yadm-config=' \
                    'd-yadm-encrypt=' 'e-yadm-archive=' 'f-yadm-bootstrap='
end

function __fish_yu_needs_command
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s (__fish_yu_universial_optspecs) -- $cmd 2>/dev/null
    or return 0
    if set -q argv[1]
        echo $argv[1]
        return 1
    end
    return 0
end

function __fish_yu_using_command
    set -l cmd (__fish_yu_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd $argv
    and return 0
end

# 子命令
complete -x -c yu -n '__fish_yu_needs_command' -a 'clone'      -d 'Clone an existing repository'
complete -x -c yu -n '__fish_yu_needs_command' -a 'alt'        -d 'Create links for alternates'
complete -x -c yu -n '__fish_yu_needs_command' -a 'bootstrap'  -d 'Execute the bootstrap program'
complete -x -c yu -n '__fish_yu_needs_command' -a 'perms'      -d 'Fix perms for private files'
complete -x -c yu -n '__fish_yu_needs_command' -a 'enter'      -d 'Run sub-shell with GIT variables set'
complete    -c yu -n '__fish_yu_needs_command' -a 'git-crypt'  -d 'Run git-crypt commands for the yadm repo'
complete -x -c yu -n '__fish_yu_needs_command' -a 'help'       -d 'Print a summary of yadm commands'
complete -x -c yu -n '__fish_yu_needs_command' -a 'upgrade'    -d 'Upgrade to version 2 of yadm directory structure'
complete -x -c yu -n '__fish_yu_needs_command' -a 'version'    -d 'Print the version of yadm'
complete -x -c yu -n '__fish_yu_needs_command' -a 'init'       -d 'Initialize an empty repository'
complete -x -c yu -n '__fish_yu_needs_command' -a 'list'       -d 'List tracked files (受 cwd 影响)'
complete -x -c yu -n '__fish_yu_needs_command' -a 'encrypt'    -d 'Encrypt files'
complete -x -c yu -n '__fish_yu_needs_command' -a 'decrypt'    -d 'Decrypt files'
complete -x -c yu -n '__fish_yu_needs_command' -a 'introspect' -d 'Report internal yadm data'
complete -x -c yu -n '__fish_yu_needs_command' -a 'gitconfig'  -d 'Pass options to the git config command'
complete -x -c yu -n '__fish_yu_needs_command' -a 'config'     -d 'Configure a setting'

# 包装 git 补全：yu 即"指定了 git-dir 的 git"
complete -c yu -w "git --git-dir=$HOME/.local/share/yadm-public/repo.git"
