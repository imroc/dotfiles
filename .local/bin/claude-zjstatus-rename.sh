#!/bin/bash
# Rename the Claude status display name for the currently focused pane.
# Designed to run inside a floating pane launched from zellij keybinding.
# Updates ~/.local/state/zellij-pane-names.json and refreshes zjstatus.

set -euo pipefail

ZELLIJ_SESSION="${ZELLIJ_SESSION_NAME:-}"
[ -z "$ZELLIJ_SESSION" ] && { echo "Not in a Zellij session"; exit 1; }

PANE_NAMES_FILE="$HOME/.local/state/zellij-pane-names.json"
STATE_DIR="/tmp/claude-zellij-status"
STATE_FILE="${STATE_DIR}/${ZELLIJ_SESSION}.json"

# =============================================================================
# Step 1: Get the ORIGINAL focused pane ID (before this floating pane appeared)
# =============================================================================
# Hide floating panes -> focus returns to original pane -> query -> show again
zellij action toggle-floating-panes
sleep 0.05
ORIGINAL_PANE_RAW=$(zellij action list-clients | awk 'NR==2 {print $2}')
zellij action toggle-floating-panes

# Extract numeric ID from "terminal_N"
ORIGINAL_PANE="${ORIGINAL_PANE_RAW#terminal_}"
if [ -z "$ORIGINAL_PANE" ] || ! [[ "$ORIGINAL_PANE" =~ ^[0-9]+$ ]]; then
    echo "Failed to detect original pane ID"
    sleep 2
    exit 1
fi

PANE_KEY="${ZELLIJ_SESSION}:${ORIGINAL_PANE}"

# =============================================================================
# Step 2: Show current name and prompt for new one
# =============================================================================
# Ensure pane names file exists
mkdir -p "$(dirname "$PANE_NAMES_FILE")"
[ -f "$PANE_NAMES_FILE" ] || echo "{}" > "$PANE_NAMES_FILE"

CURRENT_NAME=$(jq -r --arg k "$PANE_KEY" '.[$k] // ""' "$PANE_NAMES_FILE" 2>/dev/null || echo "")

echo "Pane: ${PANE_KEY}"
if [ -n "$CURRENT_NAME" ]; then
    echo "Current name: ${CURRENT_NAME}"
fi
echo "(empty to remove custom name)"
echo ""
read -r -p "New name: " NEW_NAME

# =============================================================================
# Step 3: Update pane names JSON
# =============================================================================
TMP_FILE=$(mktemp)
if [ -z "$NEW_NAME" ]; then
    # Remove custom name
    jq --arg k "$PANE_KEY" 'del(.[$k])' "$PANE_NAMES_FILE" > "$TMP_FILE" 2>/dev/null
    echo "Removed custom name for ${PANE_KEY}"
else
    # Set custom name
    jq --arg k "$PANE_KEY" --arg v "$NEW_NAME" '.[$k] = $v' "$PANE_NAMES_FILE" > "$TMP_FILE" 2>/dev/null
    echo "Set name: ${PANE_KEY} -> ${NEW_NAME}"
fi

if [ -s "$TMP_FILE" ]; then
    mv "$TMP_FILE" "$PANE_NAMES_FILE"
else
    rm -f "$TMP_FILE"
    echo "Failed to update pane names"
    sleep 2
    exit 1
fi

# =============================================================================
# Step 4: Update Claude status state and refresh zjstatus
# =============================================================================
if [ -f "$STATE_FILE" ] && [ -s "$STATE_FILE" ]; then
    # Truncate display name (same logic as hook script)
    DISPLAY_NAME="$NEW_NAME"
    if [ -z "$DISPLAY_NAME" ]; then
        # Fallback: try to get project dir from state
        DISPLAY_NAME=$(jq -r --arg pane "$ORIGINAL_PANE" '.[$pane].project // "?"' "$STATE_FILE" 2>/dev/null || echo "?")
    fi
    if [ ${#DISPLAY_NAME} -gt 12 ]; then
        DISPLAY_NAME="${DISPLAY_NAME:0:6}..."
    fi

    # Update project name in state file
    TMP_FILE=$(mktemp)
    jq --arg pane "$ORIGINAL_PANE" --arg name "$DISPLAY_NAME" \
        'if .[$pane] then .[$pane].project = $name else . end' \
        "$STATE_FILE" > "$TMP_FILE" 2>/dev/null

    if [ -s "$TMP_FILE" ]; then
        mv "$TMP_FILE" "$STATE_FILE"
    else
        rm -f "$TMP_FILE"
    fi

    # Re-render zjstatus pill (same rendering logic as hook script)
    # Colors
    C_BG="${ZJSTATUS_BG:-#313244}"
    C_PILL_BG="${ZJSTATUS_PILL_BG:-#45475a}"
    C_PILL_FG="${ZJSTATUS_PILL_FG:-#b4befe}"
    C_ICON_BG="${ZJSTATUS_ICON_BG:-#b4befe}"
    C_ICON_FG="${ZJSTATUS_ICON_FG:-#11111b}"

    # Powerline characters (literal UTF-8)
    PL_LEFT=""
    PL_RIGHT=""
    ICON="󰚩"

    JQ_STYLE_DEF='def style($fg): "#[fg=\($fg),bg=\($pill_bg)]";'
    JQ_FORMAT='to_entries | sort_by(.key)[] |
        "\(style(.value.color))\(.value.symbol) \("#[fg=\($pill_fg),bg=\($pill_bg),bold]")\(.value.project)" +
        (if .value.context_pct then " \(style(.value.ctx_color // "#2ecc40"))\(.value.context_pct)%" else "" end)'

    SESSIONS=""
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        [ -n "$SESSIONS" ] && SESSIONS="${SESSIONS}  "
        SESSIONS="${SESSIONS}${line}"
    done < <(jq -r --arg bg "$C_BG" --arg pill_bg "$C_PILL_BG" --arg pill_fg "$C_PILL_FG" "${JQ_STYLE_DEF} ${JQ_FORMAT}" "$STATE_FILE" 2>/dev/null)

    if [ -n "$SESSIONS" ]; then
        PILL="#[bg=${C_BG},fg=${C_ICON_BG}]${PL_LEFT}#[bg=${C_ICON_BG},fg=${C_ICON_FG},bold]${ICON} #[bg=${C_PILL_BG},fg=${C_PILL_FG},bold] ${SESSIONS}#[bg=${C_BG},fg=${C_PILL_BG}]${PL_RIGHT}"
        zellij -s "$ZELLIJ_SESSION" pipe "zjstatus::pipe::pipe_status::${PILL}" 2>/dev/null || true
    fi
fi

sleep 0.5
