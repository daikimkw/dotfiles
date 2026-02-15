#!/bin/bash

NTFY_TOPIC="claude-code-daikimkw"

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
project=$(basename "$cwd")
notification_type=$(echo "$input" | jq -r '.notification_type')

case "$notification_type" in
  "permission_prompt")
    message="許可待ち"
    tags="warning"
    ;;
  "idle_prompt")
    message="入力待ち"
    tags="speech_balloon"
    ;;
  "stop")
    message="タスク完了"
    tags="white_check_mark"
    ;;
  *)
    message="通知"
    tags="bell"
    ;;
esac

# macOS通知
terminal-notifier -title "Claude Code" -subtitle "$project" -message "$message" -sound "Ping"

# ntfy通知（スマホ）
curl -s \
  -H "Title: Claude Code - $project" \
  -H "Tags: $tags" \
  "https://ntfy.sh/$NTFY_TOPIC" \
  -d "$message" > /dev/null 2>&1 &
