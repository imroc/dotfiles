function sc --description "skopeo copy --all"
    if test -z "$argv[1]"; or test -z "$argv[2]"
        echo "Usage: sc <source-image> <dst-image>"
        return
    end
    skopeo copy --all docker://$argv[1] docker://$argv[2]
end
