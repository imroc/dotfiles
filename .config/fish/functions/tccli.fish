function tccli --wraps=tccli --description "wrap tccli with extra advanced feature"
    set subcommand "$argv[1]"
    switch $subcommand
        case region
            set -l selected (cat $HOME/.config/tencentcloud/region.json | jq -r '.[] | "\\(.Region) \\(.RegionName)"' | fzf --prompt="select region: ")
            if test -z "$selected"
                echo "no region selected"
                return
            end
            set -l region (string split " " "$selected")[1]
            echo "set region to $region"
            set -gx TENCENTCLOUD_REGION "$region"
            return
    end
    command tccli $argv
end
