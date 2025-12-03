#!/usr/bin/env bash

set -ex

session_name=$1

if [ -z "$session_name" ]; then
  echo "Usage: goto-kitty-session.sh <session-name>"
  exit 1
fi

sock="$(ls /tmp/kitty-* 2>/dev/null | head -n1)"
if [ -z "$sock" ]; then
  echo "No kitty process found"
  exit 1
fi

session_file="$HOME/.config/kitty/sessions/${session_name}.kitty-session"
if [ ! -f "$session_file" ]; then
  echo "Session file not found: $session_file"
  exit 1
fi

kitten @ --to "unix:${sock}" action goto_session $session_file
