#!/bin/bash

# Handle workspace changes in Aerospace
# This script monitors workspace changes and updates the sketchybar display

source "$HOME/.config/sketchybar/colors.sh"

update_spaces() {
  # Get all workspaces
  WORKSPACES=$(aerospace list-workspaces --all)
  
  # Get the currently focused workspace
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)
  
  args=()
  while read -r workspace
  do
    if [ "$workspace" = "$FOCUSED_WORKSPACE" ]; then
      # Active workspace: red color and highlight
      args+=(--set space.$workspace icon.color=$RED icon.highlight=on)
    else
      # Inactive workspace: default icon color
      args+=(--set space.$workspace icon.color=$ICON_COLOR icon.highlight=off)
    fi
  done <<< "$WORKSPACES"

  sketchybar -m "${args[@]}"
}

case "$SENDER" in
  "space_change") update_spaces
  ;;
  "workspace_change") update_spaces
  ;;
  *) update_spaces
  ;;
esac
