function za --description "zellij attach"
    set -l session $argv[1]
    if test -n "$session"
        __za_set_zellij_user_var enter
        if command zellij list-sessions 2>/dev/null | sed -e 's/\x1b\[[0-9;]*m//g' | awk '{print $1}' | grep -qx "$session"
            command zellij attach $session
        else
            command zellij -s $session
        end
        __za_set_zellij_user_var leave
    else
        set session (command zellij list-sessions 2>/dev/null | sed -e 's/\x1b\[[0-9;]*m//g' | grep -i created | awk '{print $1}' | fzf -0 -1)
        if test -z "$session"
            echo "No session selected"
            return 1
        end
        __za_set_zellij_user_var enter
        command zellij attach $session
        __za_set_zellij_user_var leave
    end
end

function __za_set_zellij_user_var
    test -n "$KITTY_PID"; or return
    if test "$argv[1]" = enter
        printf "\x1b]1337;SetUserVar=in_zellij=MQo\007"
    else
        printf "\x1b]1337;SetUserVar=in_zellij\007"
    end
end
