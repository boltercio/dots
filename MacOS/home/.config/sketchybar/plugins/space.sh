#!/bin/bash

source "$HOME/.config/sketchybar/colors.sh"

# Log for debugging
echo "$(date '+%Y-%m-%d %H:%M:%S') - SENDER: $SENDER, BUTTON: $BUTTON, NAME: $NAME" >> /tmp/space_script.log

# Extract workspace name from the item name (space.WORKSPACE_NAME)
WORKSPACE="${NAME#space.}"

# Get the currently focused workspace
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)

update() {
  WIDTH="dynamic"
  if [ "$SELECTED" = "true" ]; then
    WIDTH="0"
  fi

  sketchybar --animate tanh 20 --set $NAME icon.highlight=$SELECTED label.width=$WIDTH
  
  # Update color based on focus state
  if [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME icon.color=$RED
  else
    sketchybar --set $NAME icon.color=$ICON_COLOR
  fi
}

mouse_clicked() {
  if [ "$BUTTON" = "right" ]; then
    # Aerospace no tiene comando para cerrar workspaces
    # Por ahora solo ignoramos el click derecho
    return
  else
    # Focus the workspace
    aerospace workspace "$WORKSPACE" 2>/dev/null
  fi
  
  # Force update after a short delay
  sleep 0.2
  FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused 2>/dev/null)
  
  # Update this item
  if [ "$WORKSPACE" = "$FOCUSED_WORKSPACE" ]; then
    sketchybar --set $NAME icon.color=$RED
  else
    sketchybar --set $NAME icon.color=$ICON_COLOR
  fi
  
  # Update all workspace colors
  WORKSPACES=$(aerospace list-workspaces --all 2>/dev/null)
  while read -r ws
  do
    [ -z "$ws" ] && continue
    if [ "$ws" = "$FOCUSED_WORKSPACE" ]; then
      sketchybar --set space.$ws icon.color=$RED
    else
      sketchybar --set space.$ws icon.color=$ICON_COLOR
    fi
  done <<< "$WORKSPACES"
}

case "$SENDER" in
  "mouse.clicked") mouse_clicked
  ;;
  "space_change") update
  ;;
  *) update
  ;;
esac
