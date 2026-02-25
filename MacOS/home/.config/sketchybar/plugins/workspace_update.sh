#!/bin/bash

# This script is executed when the workspace_change event is triggered
# It updates all workspace colors based on the currently focused workspace

source "$HOME/.config/sketchybar/colors.sh"

# Get the currently focused workspace
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)

if [ -z "$FOCUSED_WORKSPACE" ]; then
  exit 1
fi

# Get all workspaces
WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null)

if [ -z "$WORKSPACES" ]; then
  exit 1
fi

args=()
while read -r workspace
do
  if [ -z "$workspace" ]; then
    continue
  fi
  
  if [ "$workspace" = "$FOCUSED_WORKSPACE" ]; then
    # Active workspace: red color
    args+=(--set space.$workspace icon.color=$RED)
  else
    # Inactive workspace: default icon color
    args+=(--set space.$workspace icon.color=$ICON_COLOR)
  fi
done <<< "$WORKSPACES"

# Only update if we have args
if [ ${#args[@]} -gt 0 ]; then
  sketchybar -m "${args[@]}"
fi
