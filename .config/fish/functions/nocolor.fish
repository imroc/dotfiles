function nocolor --description "toggle no color"
    if test -q NO_COLOR
        set -e NO_COLOR
    else
        set -g NO_COLOR 1
    end
end
