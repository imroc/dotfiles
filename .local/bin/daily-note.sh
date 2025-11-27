#!/usr/bin/env bash

# Filename: ~/github/dotfiles-latest/scripts/macos/mac/misc/300-dailyNote.sh
# ~/github/dotfiles-latest/scripts/macos/mac/misc/300-dailyNote.sh

# # I tried replacing BetterTouchTool with this, never worked, so fuck it
# # Bring the app to the foreground if it is already open. If not open, launch it
# osascript -e 'tell application "kitty" to activate'
# sleep 0.3
# # Then when I'm in kitty, I need to press ctrl+b and then the number 1 by itself
# # That will execute the tmux command that I need
# osascript -e 'tell application "System Events" to keystroke "b" using {control down}'
# sleep 0.3
# osascript -e 'tell application "System Events" to keystroke "1"'
# sleep 0.3

# Specify below the directory in which you want to create your daily note
main_note_dir=~/dev/note/daily

# Get current date components
current_year=$(date +"%Y")
current_month_num=$(date +"%m")
current_day=$(date +"%d")
current_weekday=$(date +"%A")

# Construct the directory structure and filename
note_dir=${main_note_dir}/${current_year}/${current_month_num}
note_name=${current_year}-${current_month_num}-${current_day}-${current_weekday}
full_path=${note_dir}/${note_name}.md

# Check if the directory exists, if not, create it
if [ ! -d "$note_dir" ]; then
  mkdir -p "$note_dir"
fi

# Create the daily note if it does not already exist
if [ ! -f "$full_path" ]; then
  cat <<EOF >"$full_path"
## 待办列表
EOF
fi

exec nvim --cmd "let g:neovim_mode = \"skitty\"" $full_path
