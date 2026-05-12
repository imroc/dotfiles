function docker --wraps=docker --description "docker wrapper with DOCKER_MODE switcher"
    if test "$argv[1]" = mode
        set -l modes colima remote podman
        set -l current (test -n "$DOCKER_MODE" && echo $DOCKER_MODE || echo colima)
        set -l choice (printf '%s\n' $modes | fzf --prompt="DOCKER_MODE ($current) > " --height=~10)
        or return
        if test "$choice" = colima
            set -e DOCKER_MODE
            echo "DOCKER_MODE unset (default: colima)"
        else
            set -gx DOCKER_MODE $choice
            echo "DOCKER_MODE=$DOCKER_MODE"
        end
    else
        command docker $argv
    end
end
