#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract values from JSON
user=$(whoami)
hostname=$(hostname -s)
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name')
session_name=$(echo "$input" | jq -r '.session_name // empty')
context_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Get short directory name
short_dir=$(basename "$cwd")

# Get git branch if in a git repo
git_branch=""
if git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
    git_branch=$(git -C "$cwd" --no-optional-locks branch --show-current 2>/dev/null)
    if [ -n "$git_branch" ]; then
        git_branch=" (${git_branch})"
    fi
fi

# Build status line
status="${user}@${hostname}:${short_dir}${git_branch}"

# Add session name if present
if [ -n "$session_name" ]; then
    status="${status} [${session_name}]"
fi

# Add context info if available
if [ -n "$context_remaining" ]; then
    status="${status} | ctx: ${context_remaining}%"
fi

echo "$status"
