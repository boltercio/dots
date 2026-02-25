#!/bin/bash

# Mapeo de workspaces a iconos
declare -A WORKSPACE_ICONS
WORKSPACE_ICONS[1]="" # Terminal
WORKSPACE_ICONS[2]="" # Navegador
WORKSPACE_ICONS[3]="" # Código
WORKSPACE_ICONS[4]="󰖺" # Misc

# Get all Aerospace workspaces
WORKSPACES=$(aerospace list-workspaces --all)

# Get the currently focused workspace to set initial colors
FOCUSED_WORKSPACE=$(aerospace list-workspaces --focused)

# Destroy space on right click, focus space on left click.
# New space by left clicking separator (>)

spaces=()
while read -r workspace
do
  # Use workspace name as the space identifier
  space_id="$workspace"
  
  # Get icon for this workspace
  workspace_icon="${WORKSPACE_ICONS[$workspace]:-$workspace}"
  
  # Determine initial color based on if it's focused
  if [ "$workspace" = "$FOCUSED_WORKSPACE" ]; then
    initial_icon_color=$RED
  else
    initial_icon_color=$ICON_COLOR
  fi
  
  space=(
    icon=$workspace_icon
    icon.color=$initial_icon_color
    icon.padding_left=10
    icon.padding_right=10
    padding_left=5
    padding_right=5
    label.padding_right=8
    icon.highlight_color=$RED
    label.font="sketchybar-app-font:Regular:16.0"
    label.background.height=26
    label.background.drawing=on
    label.background.color=$BACKGROUND_1
    label.background.corner_radius=6
    label.drawing=off
    background.color=$BACKGROUND_1
    background.drawing=on
    background.corner_radius=6
    background.height=26
    script="$PLUGIN_DIR/space.sh"
    click_script="aerospace workspace $workspace"
  )

  sketchybar --add item space.$space_id left    \
             --set space.$space_id "${space[@]}" \
             --subscribe space.$space_id mouse.clicked space_change
  
  # Add item for showing apps in this workspace
  sketchybar --add item space.$space_id.apps left \
             --set space.$space_id.apps label.drawing=off \
                                        label.color=$ICON_COLOR \
                                        label.font="sketchybar-app-font:Regular:13.0" \
                                        padding_left=-5 \
                                        padding_right=12 \
                                        label.padding_left=0 \
                                        label.padding_right=6 \
                                        width=dynamic \
                                        script="$PLUGIN_DIR/aerospace.sh" \
             --subscribe space.$space_id.apps space_change
done <<< "$WORKSPACES"

spaces=(
  background.color=$BACKGROUND_1
  background.border_color=$BACKGROUND_2
  background.border_width=2
  background.drawing=on
)

separator=(
  icon=􀆊
  icon.font="$FONT:Heavy:16.0"
  padding_left=5
  padding_right=5
  label.drawing=off
  associated_display=active
  click_script='aerospace workspace-create-empty && sketchybar --trigger space_change'
  icon.color=$WHITE
)

sketchybar --add bracket spaces '/space\..*/' \
           --set spaces "${spaces[@]}"        \
                                              \
           --add item separator left          \
           --set separator "${separator[@]}"