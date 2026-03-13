abbr --add gi gemini-internal
abbr --add ci hapi claude-internal
abbr --add cis hapi claude-internal --permission-mode bypassPermissions
abbr --add cir hapi claude-internal --permission-mode bypassPermissions --resume
abbr --add cbs hapi codebuddy -y
abbr --add cbr hapi codebuddy -y --resume
abbr --add crs ccr code --permission-mode bypassPermissions
abbr --add cr ccr code
abbr --add oc opencode
abbr --add ow openclaw
abbr --add ot openclaw tui
abbr --add ol openclaw logs --follow
abbr --add og openclaw gateway
abbr --add ogr openclaw gateway restart

set -gx CLAUDE_INTERNAL_ALLOW_ROOT 1
