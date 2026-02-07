#!/bin/bash

# Read JSON input
input=$(cat)

# Extract values
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')
model=$(echo "$input" | jq -r '.model.display_name')
output_style=$(echo "$input" | jq -r '.output_style.name')

# Format directory (show relative to home)
dir_display="${cwd/#$HOME/~}"

# Get git info (skip locks for safety)
git_info=""
if git -C "$cwd" rev-parse --git-dir &>/dev/null; then
    branch=$(git -C "$cwd" -c core.useBuiltinFSMonitor=false -c core.untrackedCache=false branch --show-current 2>/dev/null || git -C "$cwd" -c core.useBuiltinFSMonitor=false -c core.untrackedCache=false rev-parse --short HEAD 2>/dev/null)
    if [ -n "$branch" ]; then
        git_info=" $(printf '\033[35m')on$(printf '\033[0m') $(printf '\033[35m')${branch}$(printf '\033[0m')"
    fi
fi

# Add model info
model_info=" $(printf '\033[32m')${model}$(printf '\033[0m')"

# Calculate context usage if available
context_info=""
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
remaining_pct=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
if [ -n "$used_pct" ]; then
    # Round to integer
    used_int=$(printf "%.0f" "$used_pct")
    remaining_int=$(printf "%.0f" "$remaining_pct")
    context_info=" $(printf '\033[33m')[ctx:${used_int}%]$(printf '\033[0m')"
fi

# Build status line (Starship-style: dir + git + model + context)
printf "$(printf '\033[36m')%s$(printf '\033[0m')%s%s%s" "$dir_display" "$git_info" "$model_info" "$context_info"