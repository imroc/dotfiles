#!/usr/bin/env bash
# Rename the Claude status display name for the currently focused pane.
# Designed to run inside a floating pane launched from zellij keybinding.
# Directly modifies the project field in STATE_FILE, then triggers hook to re-render.

set -euo pipefail

zellij action rename-pane "Rename Claude Title"

ZELLIJ_SESSION="${ZELLIJ_SESSION_NAME:-}"
[ -z "$ZELLIJ_SESSION" ] && {
  echo "Not in a Zellij session"
  exit 1
}

STATE_DIR="$HOME/.local/state/claude-zellij-status"
STATE_FILE="${STATE_DIR}/${ZELLIJ_SESSION}.json"
LOCK_FILE="${STATE_FILE}.lock"

# =============================================================================
# Step 1: Get the ORIGINAL focused pane ID (before this floating pane appeared)
# =============================================================================
zellij action toggle-floating-panes
sleep 0.05
ORIGINAL_PANE_RAW=$(zellij action list-clients | awk 'NR==2 {print $2}')
zellij action toggle-floating-panes

ORIGINAL_PANE="${ORIGINAL_PANE_RAW#terminal_}"
if [ -z "$ORIGINAL_PANE" ] || ! [[ "$ORIGINAL_PANE" =~ ^[0-9]+$ ]]; then
  echo "Failed to detect original pane ID"
  sleep 2
  exit 1
fi

# =============================================================================
# File locking (same as hook.sh)
# =============================================================================
acquire_lock() {
  local attempts=0
  while ! mkdir "$LOCK_FILE" 2>/dev/null; do
    attempts=$((attempts + 1))
    if [ $attempts -ge 20 ]; then
      if [ -d "$LOCK_FILE" ]; then
        local lock_age
        lock_age=$(($(date +%s) - $(stat -f %m "$LOCK_FILE" 2>/dev/null || echo 0)))
        if [ "$lock_age" -gt 10 ]; then
          rmdir "$LOCK_FILE" 2>/dev/null
          continue
        fi
      fi
      return 1
    fi
    sleep 0.1
  done
}

release_lock() {
  rmdir "$LOCK_FILE" 2>/dev/null || true
}

trap 'release_lock' EXIT

# =============================================================================
# Step 2: Show current name and prompt for new one
# =============================================================================
CURRENT_NAME=""
if [ -f "$STATE_FILE" ] && [ -s "$STATE_FILE" ]; then
  CURRENT_NAME=$(jq -r --arg pane "$ORIGINAL_PANE" '.[$pane].project // ""' "$STATE_FILE" 2>/dev/null || echo "")
fi

echo "Pane: ${ZELLIJ_SESSION}:${ORIGINAL_PANE}"
if [ -n "$CURRENT_NAME" ]; then
  echo "Current name: ${CURRENT_NAME}"
fi
echo "(empty to keep current name)"
echo ""
read -r -p "New name: " NEW_NAME

[ -z "$NEW_NAME" ] && {
  echo "No change."
  sleep 0.5
  exit 0
}

# =============================================================================
# Step 3: Update project field in STATE_FILE (with lock)
# =============================================================================
acquire_lock || {
  echo "Failed to acquire lock"
  sleep 1
  exit 1
}

mkdir -p "$STATE_DIR"
if [ ! -f "$STATE_FILE" ] || [ ! -s "$STATE_FILE" ]; then
  echo "{}" >"$STATE_FILE"
fi

TMP_FILE=$(mktemp)
jq --arg pane "$ORIGINAL_PANE" --arg name "$NEW_NAME" \
  '.[$pane] = ((.[$pane] // {}) | .project = $name)' \
  "$STATE_FILE" >"$TMP_FILE" 2>/dev/null

if [ -s "$TMP_FILE" ]; then
  mv "$TMP_FILE" "$STATE_FILE"
  echo "Renamed: pane ${ORIGINAL_PANE} -> ${NEW_NAME}"
else
  rm -f "$TMP_FILE"
  release_lock
  echo "Failed to update state (pane ${ORIGINAL_PANE} not found in state)"
  sleep 2
  exit 1
fi

release_lock

# =============================================================================
# Step 4: Trigger hook to re-render zjstatus
# =============================================================================
printf '{"hook_event_name":"PostToolUse","tool_name":"","session_id":"rename","cwd":""}' |
  ZELLIJ_SESSION_NAME="$ZELLIJ_SESSION" ZELLIJ_PANE_ID="$ORIGINAL_PANE" claude-zjstatus-hook.sh

sleep 0.5
