if true
    return
end
if not status is-interactive
    return
end

# ssh 到开发容器内, 自动进入 zellij
if command -sq zellij; and set -q SSH_TTY; and not set -q ZELLIJ
    set output (cat /proc/1/cgroup 2>/dev/null | grep kubepods)
    if not test -z "$output"
        zellij attach -c main
    end
end
