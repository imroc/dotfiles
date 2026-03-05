#!/usr/bin/env bash
# Hook script to capture Claude Code current activity and update zjstatus
# Based on: https://github.com/thoo/claude-code-zellij-status
# Self-maintained version with zjstatus background color support

# Watchdog: kill self after 5s to prevent blocking Claude
(
  sleep 5
  kill $$ 2>/dev/null
) &
WATCHDOG_PID=$!

STATE_DIR="$HOME/.local/state/claude-zellij-status"
ZELLIJ_SESSION="${ZELLIJ_SESSION_NAME:-}"
ZELLIJ_PANE="${ZELLIJ_PANE_ID:-0}"

# Exit if not in Zellij
[ -z "$ZELLIJ_SESSION" ] && exit 0

STATE_FILE="${STATE_DIR}/${ZELLIJ_SESSION}.json"
LOCK_FILE="${STATE_FILE}.lock"
mkdir -p "$STATE_DIR"

# Read JSON from stdin (before acquiring lock to avoid holding lock during stdin read)
INPUT=$(cat)

# Parse hook event and related fields (with error handling)
HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // ""' 2>/dev/null || echo "")
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null || echo "")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
CWD=$(echo "$INPUT" | jq -r '.cwd // ""' 2>/dev/null || echo "")

# Exit if we couldn't parse the input
[ -z "$HOOK_EVENT" ] && exit 0

# Get short session ID (last 4 chars for compactness)
SHORT_SESSION="${SESSION_ID: -4}"

# Default project name from cwd (may be overridden by custom_name in state file later)
PROJECT_NAME=$(basename "$CWD" 2>/dev/null || echo "?")

# =============================================================================
# COLOR SCHEME (clrs.cc - bright but not vivid)
# =============================================================================
C_GREEN="#2ecc40"  # base0B - Done/Complete
C_YELLOW="#ffdc00" # base0A - Active/Working
C_BLUE="#0074d9"   # base0D - Reading/Searching
C_AQUA="#4166F5"   # base0C - Project name text
C_RED="#ff4136"    # base08 - Needs attention
C_ORANGE="#ff851b" # base09 - Bash
C_PURPLE="#b10dc9" # base0E - Agent/Skill
C_GRAY="#666666"   # base03 - Thinking/Idle
# zjstatus bar background color, override via ZJSTATUS_BG env var
C_BG="${ZJSTATUS_BG:-#313244}"
# zjstatus pill background color for pipe_status (matches $surface1 in Catppuccin Mocha)
C_PILL_BG="${ZJSTATUS_PILL_BG:-#45475a}"
# Pill foreground color for text (matches $lavender in Catppuccin Mocha)
C_PILL_FG="${ZJSTATUS_PILL_FG:-#b4befe}"
# Icon background color (matches $lavender in Catppuccin Mocha)
C_ICON_BG="${ZJSTATUS_ICON_BG:-#b4befe}"
# Icon foreground color (matches $crust in Catppuccin Mocha)
C_ICON_FG="${ZJSTATUS_ICON_FG:-#11111b}"

# =============================================================================
# Helper: wrap content in Powerline pill style (icon + content + closing)
# Usage: wrap_pill "$content"
# =============================================================================
# Powerline characters (literal UTF-8, not escape sequences for bash 3.2 compat)
PL_LEFT=""  # U+E0B6 left half-circle
PL_RIGHT="" # U+E0B4 right half-circle
ICON="󰚩"     # U+F06A9 robot face

wrap_pill() {
  local content="$1"
  echo "#[bg=${C_BG},fg=${C_ICON_BG}]${PL_LEFT}#[bg=${C_ICON_BG},fg=${C_ICON_FG},bold]${ICON} #[bg=${C_PILL_BG},fg=${C_PILL_FG},bold] ${content}#[bg=${C_BG},fg=${C_PILL_BG}]${PL_RIGHT}"
}

# =============================================================================
# jq helper: build style with bg color for zjstatus dynamic rendermode
# Appends attention icon (⏳/✅) after project name if present.
# =============================================================================
JQ_STYLE_DEF='def style($fg): "#[fg=\($fg),bg=\($pill_bg)]";'
JQ_FORMAT='to_entries | sort_by(.key)[] |
    "\(style(.value.color))\(.value.symbol) \("#[fg=\($pill_fg),bg=\($pill_bg),bold]")\(.value.project)" +
    (if .value.attention and .value.attention_ts and (now - .value.attention_ts < 60) then " \(.value.attention)" else "" end) +
    (if .value.context_pct then " \(style(.value.ctx_color // "#2ecc40"))\(.value.context_pct)%" else "" end)'

# =============================================================================
# File locking: use mkdir as atomic lock (portable, no flock on macOS)
# =============================================================================
acquire_lock() {
  local attempts=0
  while ! mkdir "$LOCK_FILE" 2>/dev/null; do
    attempts=$((attempts + 1))
    if [ $attempts -ge 20 ]; then
      # Stale lock? Check if lock is older than 10s and force-remove
      if [ -d "$LOCK_FILE" ]; then
        local lock_age
        lock_age=$(($(date +%s) - $(stat -f %m "$LOCK_FILE" 2>/dev/null || echo 0)))
        if [ "$lock_age" -gt 10 ]; then
          rmdir "$LOCK_FILE" 2>/dev/null
          continue
        fi
      fi
      return 1 # give up
    fi
    sleep 0.1
  done
}

release_lock() {
  rmdir "$LOCK_FILE" 2>/dev/null || true
}

# Ensure lock is released on exit (watchdog kill, errors, etc.)
cleanup() {
  release_lock
  kill "$WATCHDOG_PID" 2>/dev/null || true
}
trap cleanup EXIT

# =============================================================================
# SYMBOLS
# =============================================================================
# ATTENTION: persistent notification icon shown after project name in pipe_status.
# Set on Notification (⏳) and Stop (✅), cleared on UserPromptSubmit (user resumed).
# Other events preserve the existing attention value.
ATTENTION=""       # empty = inherit from existing state
CLEAR_ATTENTION=false

# Determine activity, color, and symbol based on hook event
case "$HOOK_EVENT" in
PreToolUse)
  case "$TOOL_NAME" in
  WebSearch)
    ACTIVITY="search"
    COLOR="$C_BLUE"
    SYMBOL="◍"
    ;;
  WebFetch)
    ACTIVITY="fetch"
    COLOR="$C_BLUE"
    SYMBOL="↓"
    ;;
  Task)
    ACTIVITY="agent"
    COLOR="$C_PURPLE"
    SYMBOL="▶"
    ;;
  Bash)
    ACTIVITY="bash"
    COLOR="$C_ORANGE"
    SYMBOL="⚡"
    ;;
  Read)
    ACTIVITY="read"
    COLOR="$C_BLUE"
    SYMBOL="◔"
    ;;
  Write)
    ACTIVITY="write"
    COLOR="$C_AQUA"
    SYMBOL="✎"
    ;;
  Edit)
    ACTIVITY="edit"
    COLOR="$C_AQUA"
    SYMBOL="✎"
    ;;
  Glob | Grep)
    ACTIVITY="find"
    COLOR="$C_BLUE"
    SYMBOL="◎"
    ;;
  Skill)
    ACTIVITY="skill"
    COLOR="$C_PURPLE"
    SYMBOL="★"
    ;;
  TodoWrite)
    ACTIVITY="plan"
    COLOR="$C_YELLOW"
    SYMBOL="◫"
    ;;
  AskUserQuestion)
    ACTIVITY="ask?"
    COLOR="$C_RED"
    SYMBOL="?"
    ;;
  mcp__*)
    ACTIVITY="mcp"
    COLOR="$C_PURPLE"
    SYMBOL="◈"
    ;;
  *)
    ACTIVITY="work"
    COLOR="$C_YELLOW"
    SYMBOL="●"
    ;;
  esac
  DONE=false
  ;;
PostToolUse)
  ACTIVITY="think"
  COLOR="$C_GRAY"
  SYMBOL="◐"
  DONE=false
  ;;
Notification)
  # Check if session is already done - don't overwrite completion status
  if [ -f "$STATE_FILE" ] && acquire_lock; then
    EXISTING_DONE=$(jq -r --arg pane "$ZELLIJ_PANE" '.[$pane].done // false' "$STATE_FILE" 2>/dev/null || echo "false")
    release_lock
    if [ "$EXISTING_DONE" = "true" ]; then
      PROJECT_NAME_NOTIFY=$(basename "$CWD" 2>/dev/null || echo "?")
      zellij -s "$ZELLIJ_SESSION" pipe "zjstatus::notify::${PROJECT_NAME_NOTIFY} ⏳" 2>/dev/null || true
      exit 0
    fi
  fi
  ACTIVITY="wait"
  COLOR="$C_RED"
  SYMBOL="⏳"
  ATTENTION="⏳"
  DONE=false
  ;;
UserPromptSubmit)
  ACTIVITY="start"
  COLOR="$C_YELLOW"
  SYMBOL="●"
  CLEAR_ATTENTION=true
  DONE=false
  ;;
PermissionRequest)
  ACTIVITY="perm?"
  COLOR="$C_RED"
  SYMBOL="⚠"
  ATTENTION="⚠"
  DONE=false
  ;;
Stop)
  ACTIVITY="done"
  COLOR="$C_GREEN"
  SYMBOL="✅"
  ATTENTION="✅"
  DONE=true
  ;;
SubagentStop)
  ACTIVITY="agent✓"
  COLOR="$C_GREEN"
  SYMBOL="▷"
  DONE=false
  ;;
SessionStart)
  ACTIVITY="init"
  COLOR="$C_BLUE"
  SYMBOL="◆"
  CLEAR_ATTENTION=true
  DONE=false
  ;;
SessionEnd)
  # Session ended - remove from state (with lock)
  if [ -f "$STATE_FILE" ] && acquire_lock; then
    TMP_FILE=$(mktemp)
    jq --arg pane "$ZELLIJ_PANE" 'del(.[$pane])' "$STATE_FILE" >"$TMP_FILE" 2>/dev/null && mv "$TMP_FILE" "$STATE_FILE"
    rm -f "$TMP_FILE"
    # Update zjstatus with remaining sessions
    if [ -s "$STATE_FILE" ]; then
      SESSIONS=""
      while IFS= read -r line; do
        [ -z "$line" ] && continue
        [ -n "$SESSIONS" ] && SESSIONS="${SESSIONS}  "
        SESSIONS="${SESSIONS}${line}"
      done < <(jq -r --arg bg "$C_BG" --arg pill_bg "$C_PILL_BG" --arg pill_fg "$C_PILL_FG" "${JQ_STYLE_DEF} ${JQ_FORMAT}" "$STATE_FILE" 2>/dev/null)
    fi
    release_lock

    if [ -z "${SESSIONS:-}" ]; then
      zellij -s "$ZELLIJ_SESSION" pipe "zjstatus::pipe::pipe_status::" 2>/dev/null || true
    else
      PILL=$(wrap_pill "$SESSIONS")
      zellij -s "$ZELLIJ_SESSION" pipe "zjstatus::pipe::pipe_status::${PILL}" 2>/dev/null || true
    fi
  fi
  exit 0
  ;;
*)
  ACTIVITY="..."
  COLOR="$C_GRAY"
  SYMBOL="○"
  DONE=false
  ;;
esac

# Current time
TIMESTAMP=$(date +%s)
TIME_FMT=$(date +%H:%M)

# Acquire lock for state file read-modify-write
acquire_lock || exit 0

# Initialize state file if it doesn't exist or is empty
if [ ! -f "$STATE_FILE" ] || [ ! -s "$STATE_FILE" ]; then
  echo "{}" >"$STATE_FILE"
fi

# Read existing state
CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "{}")

# Validate it's proper JSON
if ! echo "$CURRENT_STATE" | jq empty 2>/dev/null; then
  CURRENT_STATE="{}"
  echo "{}" >"$STATE_FILE"
fi

# Get existing values for this pane (preserve context data)
EXISTING=$(echo "$CURRENT_STATE" | jq -r --arg pane "$ZELLIJ_PANE" '.[$pane] // {}' 2>/dev/null)
EXISTING_CTX_PCT=$(echo "$EXISTING" | jq -r '.context_pct // null' 2>/dev/null)
EXISTING_CTX_COLOR=$(echo "$EXISTING" | jq -r '.ctx_color // null' 2>/dev/null)

# Preserve existing project name if set (may have been renamed)
EXISTING_PROJECT=$(echo "$EXISTING" | jq -r '.project // ""' 2>/dev/null)
if [ -n "$EXISTING_PROJECT" ]; then
  PROJECT_NAME="$EXISTING_PROJECT"
fi

# Resolve attention: explicit set > clear > inherit from existing
if [ -n "$ATTENTION" ]; then
  # Notification/Stop/PermissionRequest explicitly set attention
  RESOLVED_ATTENTION="$ATTENTION"
  RESOLVED_ATTENTION_TS="$TIMESTAMP"
elif [ "$CLEAR_ATTENTION" = "true" ]; then
  # UserPromptSubmit/SessionStart clear attention
  RESOLVED_ATTENTION=""
  RESOLVED_ATTENTION_TS=""
else
  # All other events: inherit existing attention
  RESOLVED_ATTENTION=$(echo "$EXISTING" | jq -r '.attention // null' 2>/dev/null)
  [ "$RESOLVED_ATTENTION" = "null" ] && RESOLVED_ATTENTION=""
  RESOLVED_ATTENTION_TS=$(echo "$EXISTING" | jq -r '.attention_ts // null' 2>/dev/null)
  [ "$RESOLVED_ATTENTION_TS" = "null" ] && RESOLVED_ATTENTION_TS=""
fi

# Update state with this pane's activity
TMP_FILE=$(mktemp)
echo "$CURRENT_STATE" | jq \
  --arg pane "$ZELLIJ_PANE" \
  --arg project "$PROJECT_NAME" \
  --arg activity "$ACTIVITY" \
  --arg color "$COLOR" \
  --arg symbol "$SYMBOL" \
  --arg time "$TIME_FMT" \
  --arg ts "$TIMESTAMP" \
  --arg short_session "$SHORT_SESSION" \
  --arg session "$SESSION_ID" \
  --arg ctx_pct "$EXISTING_CTX_PCT" \
  --arg ctx_color "$EXISTING_CTX_COLOR" \
  --arg attention "$RESOLVED_ATTENTION" \
  --arg attention_ts "$RESOLVED_ATTENTION_TS" \
  --argjson done "$DONE" \
  '.[$pane] = {
        project: $project,
        activity: $activity,
        color: $color,
        symbol: $symbol,
        time: $time,
        timestamp: ($ts | tonumber),
        short_session: $short_session,
        session_id: $session,
        context_pct: (if $ctx_pct == "null" then null else $ctx_pct end),
        ctx_color: (if $ctx_color == "null" then null else $ctx_color end),
        attention: (if $attention == "" then null else $attention end),
        attention_ts: (if $attention_ts == "" then null else ($attention_ts | tonumber) end),
        done: $done
    }' >"$TMP_FILE" 2>/dev/null

if [ -s "$TMP_FILE" ]; then
  mv "$TMP_FILE" "$STATE_FILE"
else
  rm -f "$TMP_FILE"
fi

# Build combined status string
SESSIONS=""
while IFS= read -r line; do
  [ -z "$line" ] && continue
  [ -n "$SESSIONS" ] && SESSIONS="${SESSIONS}  "
  SESSIONS="${SESSIONS}${line}"
done < <(jq -r --arg bg "$C_BG" --arg pill_bg "$C_PILL_BG" --arg pill_fg "$C_PILL_FG" "${JQ_STYLE_DEF} ${JQ_FORMAT}" "$STATE_FILE" 2>/dev/null)

# Release lock after all state file operations
release_lock

# Send to zjstatus
if [ -n "$SESSIONS" ]; then
  PILL=$(wrap_pill "$SESSIONS")
  zellij -s "$ZELLIJ_SESSION" pipe "zjstatus::pipe::pipe_status::${PILL}" 2>/dev/null || true
fi

# Send zjstatus notification for important events
case "$HOOK_EVENT" in
Notification | Stop | SubagentStop | AskUserQuestion | PermissionRequest)
  zellij -s "$ZELLIJ_SESSION" pipe "zjstatus::notify::${PROJECT_NAME} ${SYMBOL}" 2>/dev/null || true
  ;;
esac
