function zrp --description "Rename zellij pane and save name for claude zjstatus"
    if test (count $argv) -eq 0
        echo "Usage: zrp <name>"
        return 1
    end

    set -l name "$argv[1]"
    set -l state_dir /tmp/claude-zellij-status
    set -l names_file "$state_dir/pane-names.json"

    # Rename zellij pane
    zellij action rename-pane "$name"

    # Save name mapping: ZELLIJ_SESSION_NAME:ZELLIJ_PANE_ID -> name
    if test -n "$ZELLIJ_SESSION_NAME" -a -n "$ZELLIJ_PANE_ID"
        mkdir -p $state_dir
        set -l key "$ZELLIJ_SESSION_NAME:$ZELLIJ_PANE_ID"

        if test -f "$names_file"
            jq --arg k "$key" --arg v "$name" '.[$k] = $v' "$names_file" >"$names_file.tmp" 2>/dev/null
            and mv "$names_file.tmp" "$names_file"
        else
            jq -n --arg k "$key" --arg v "$name" '{($k): $v}' >"$names_file"
        end
    end
end
