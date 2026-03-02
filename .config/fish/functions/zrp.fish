function zrp --description "Rename zellij pane and save name for claude zjstatus"
    set -l names_file ~/.local/state/zellij-pane-names.json

    # -s: open state file in nvim
    if test (count $argv) -ge 1 -a "$argv[1]" = -s
        if test -f "$names_file"
            nvim "$names_file"
        else
            echo "State file not found: $names_file"
        end
        return
    end

    if test (count $argv) -eq 0
        echo "Usage: zrp <name>"
        echo "       zrp -s  # edit state file in nvim"
        return 1
    end

    set -l name "$argv[1]"

    # Rename zellij pane
    zellij action rename-pane "$name"

    # Save name mapping: ZELLIJ_SESSION_NAME:ZELLIJ_PANE_ID -> name
    if test -n "$ZELLIJ_SESSION_NAME" -a -n "$ZELLIJ_PANE_ID"
        set -l key "$ZELLIJ_SESSION_NAME:$ZELLIJ_PANE_ID"

        if test -f "$names_file"
            jq --arg k "$key" --arg v "$name" '.[$k] = $v' "$names_file" >"$names_file.tmp" 2>/dev/null
            and mv "$names_file.tmp" "$names_file"
        else
            mkdir -p (dirname "$names_file")
            jq -n --arg k "$key" --arg v "$name" '{($k): $v}' >"$names_file"
        end
    end
end
