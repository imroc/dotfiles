function rmimg --description "delete cos image from url"
    set -l url $argv[1]
    set -l parts (string split "/" $url)
    set -l domain $parts[3]
    set -l bucket (string split "." $domain)[1]
    set -l path (string join "/" $parts[4..])
    set -l decoded_path (string unescape --style=url $path)
    set -l cos_path "cos://$bucket/$decoded_path"
    echo "delete $cos_path"
    coscli rm $cos_path
end
