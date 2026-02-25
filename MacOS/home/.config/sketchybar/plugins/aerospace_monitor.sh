#!/bin/bash

# Aerospace Workspace Monitor for Sketchybar
# This daemon monitors workspace changes and window changes, updating sketchybar accordingly

source "$HOME/.config/sketchybar/colors.sh"

LAST_FOCUSED_WORKSPACE=""
LAST_WINDOWS=""

monitor_aerospace() {
  while true; do
    # Get the currently focused workspace
    CURRENT_FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null)
    
    # Check if focused workspace changed
    if [ "$CURRENT_FOCUSED" != "$LAST_FOCUSED_WORKSPACE" ] && [ ! -z "$CURRENT_FOCUSED" ]; then
      LAST_FOCUSED_WORKSPACE="$CURRENT_FOCUSED"
      echo "$(date '+%Y-%m-%d %H:%M:%S') - Workspace changed to: $CURRENT_FOCUSED" >> /tmp/aerospace_monitor.log
      
      # Directly update workspace colors
      WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null)
      while read -r workspace
      do
        [ -z "$workspace" ] && continue
        if [ "$workspace" = "$CURRENT_FOCUSED" ]; then
          sketchybar --set space.$workspace icon.color=$RED 2>/dev/null
        else
          sketchybar --set space.$workspace icon.color=$ICON_COLOR 2>/dev/null
        fi
      done <<< "$WORKSPACES"
      
      # Reset window list for the new workspace
      LAST_WINDOWS=""
    fi
    
    # Check if windows changed in current workspace
    CURRENT_WINDOWS=$(aerospace list-windows --workspace "$CURRENT_FOCUSED" --format '%{app-name}' 2>/dev/null | sort)
    
    if [ "$CURRENT_WINDOWS" != "$LAST_WINDOWS" ] && [ ! -z "$CURRENT_FOCUSED" ]; then
      LAST_WINDOWS="$CURRENT_WINDOWS"
      echo "$(date '+%Y-%m-%d %H:%M:%S') - Windows changed in workspace: $CURRENT_FOCUSED" >> /tmp/aerospace_monitor.log
      
      # Trigger update for the current workspace's apps
      sketchybar --trigger space_change
    fi
    
    sleep 0.2
  done
}

monitor_aerospace
