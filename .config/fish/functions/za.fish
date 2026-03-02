function za --description "zellij attach"
    set -l session $argv[1]
    if test -n "$session"
        printf "\x1b]1337;SetUserVar=in_zellij=MQo\007"
        command zellij -s $session -n default
        printf "\x1b]1337;SetUserVar=in_zellij\007"
    else
        set session (command zellij list-sessions 2>/dev/null | sed -e 's/\x1b\[[0-9;]*m//g' | grep -i created | awk '{print $1}' | fzf -0 -1)
        if test -z "$session"
            echo "No session selected"
            return 1
        end
        printf "\x1b]1337;SetUserVar=in_zellij=MQo\007"
        command zellij attach $session
        printf "\x1b]1337;SetUserVar=in_zellij\007"
    end
end
