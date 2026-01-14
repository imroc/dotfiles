function dr --description "docker run image"
    set -l img $argv[1]
    set -l cmd $argv[2]
    if test -z "$img"
        echo "Usage: dr <image> [<cmd>]"
        return 1
    end
    if test -z "$cmd"
        set cmd bash
    end
    docker run --rm -it --entrypoint="" $img $cmd
end
