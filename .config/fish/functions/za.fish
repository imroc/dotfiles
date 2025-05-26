function za --description "zellij attach main"
    set session (command zellij list-sessions 2>/dev/null | sed -e 's/\x1b\[[0-9;]*m//g' | grep -i created | awk '{print $1}' | fzf -0 -1)
    if test -n "$session"
        command zellij attach $session
    else
        command zellij -s main -n compact
    end
end
