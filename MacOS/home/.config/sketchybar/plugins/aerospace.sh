#!/bin/bash

window_state() {
  source "$HOME/.config/sketchybar/colors.sh"
  source "$HOME/.config/sketchybar/icons.sh"

  # Get focused window information using aerospace
  WINDOW_ID=$(aerospace list-windows --focused --format '%{window-id}' 2>/dev/null)
  
  if [ -z "$WINDOW_ID" ]; then
    return
  fi

  # Get window info
  WINDOW_INFO=$(aerospace list-windows --window-id "$WINDOW_ID" --format '%{window-title}%{tab-index}' 2>/dev/null)

  args=()
  
  # Check if window is floating (aerospace doesn't have floating windows like yabai,
  # but we can show tiling mode)
  # For now, we'll show a simple grid icon to indicate the window is tiled
  args+=(--set $NAME icon=$AEROSPACE_GRID icon.color=$ORANGE label.drawing=off)

  sketchybar -m "${args[@]}"
}

windows_on_spaces () {
  source "$HOME/.config/sketchybar/colors.sh"
  
  # Extract the workspace number from the item name (space.X.apps)
  WORKSPACE=$(echo "$NAME" | sed 's/space\.//' | sed 's/\.apps//')
  
  # Get windows on this specific workspace
  icon_strip=" "
  windows=$(aerospace list-windows --workspace "$WORKSPACE" --format '%{app-name}' 2>/dev/null)
  
  if [ ! -z "$windows" ]; then
    while IFS= read -r app; do
      if [ ! -z "$app" ]; then
        icon_strip+=" $($HOME/.config/sketchybar/plugins/icon_map.sh "$app")"
      fi
    done <<< "$windows"
    sketchybar --set $NAME label="$icon_strip" label.drawing=on width=dynamic padding_left=-5 padding_right=12
  else
    sketchybar --set $NAME label.drawing=off width=0 padding_left=0 padding_right=0
  fi
}

case "$SENDER" in
  "space_change") windows_on_spaces
  ;;
  "window_focus") window_state 
  ;;
  "windows_on_spaces") windows_on_spaces
  ;;
  *) windows_on_spaces
  ;;
esac
