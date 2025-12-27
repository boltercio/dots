#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SDDM themes #

source_theme="https://github.com/JaKooLit/simple-sddm-2.git"
theme_name="simple_sddm_2"

# Check if /usr/share/sddm/themes/$theme_name exists and remove if it does
if [ -d "/usr/share/sddm/themes/$theme_name" ]; then
  sudo rm -rf "/usr/share/sddm/themes/$theme_name"
  echo -e "\e[1A\e[K${OK} - Removed existing $theme_name directory." 
fi

# Check if $theme_name directory exists in the current directory and remove if it does
if [ -d "$theme_name" ]; then
  rm -rf "$theme_name"
  echo -e "\e[1A\e[K${OK} - Removed existing $theme_name directory from the current location." 

# Clone the repository
if git clone --depth=1 "$source_theme" "$theme_name"; then
  if [ ! -d "$theme_name" ]; then
    echo "${ERROR} Failed to clone the repository." 
  fi

  # Create themes directory if it doesn't exist
  if [ ! -d "/usr/share/sddm/themes" ]; then
    sudo mkdir -p /usr/share/sddm/themes
    echo "${OK} - Directory '/usr/share/sddm/themes' created." 
  fi

  # Move cloned theme to the themes directory
  sudo mv "$theme_name" "/usr/share/sddm/themes/$theme_name" 

  # setting up SDDM theme
  sddm_conf="/etc/sddm.conf"
  BACKUP_SUFFIX=".bak"

  echo -e "${NOTE} Setting up the login screen." 

  # Backup the sddm.conf file if it exists
  if [ -f "$sddm_conf" ]; then
    echo "Backing up $sddm_conf" 
    sudo cp "$sddm_conf" "$sddm_conf$BACKUP_SUFFIX" 
  else
    echo "$sddm_conf does not exist, creating a new one." 
    sudo touch "$sddm_conf" 
  fi

  # Check if the [Theme] section exists
  if grep -q '^\[Theme\]' "$sddm_conf"; then
    # Update the Current= line under [Theme]
    sudo sed -i "/^\[Theme\]/,/^\[/{s/^\s*Current=.*/Current=$theme_name/}" "$sddm_conf" 
    
    # If no Current= line was found and replaced, append it after the [Theme] section
    if ! grep -q '^\s*Current=' "$sddm_conf"; then
      sudo sed -i "/^\[Theme\]/a Current=$theme_name" "$sddm_conf" 
      echo "Appended Current=$theme_name under [Theme] in $sddm_conf" 
    else
      echo "Updated Current=$theme_name in $sddm_conf" 
    fi
  else
    # Append the [Theme] section at the end if it doesn't exist
    echo -e "\n[Theme]\nCurrent=$theme_name" | sudo tee -a "$sddm_conf" > /dev/null
    echo "Added [Theme] section with Current=$theme_name in $sddm_conf" 
  fi

  # Add [General] section with InputMethod=qtvirtualkeyboard if it doesn't exist
  if ! grep -q '^\[General\]' "$sddm_conf"; then
    echo -e "\n[General]\nInputMethod=qtvirtualkeyboard" | sudo tee -a "$sddm_conf" > /dev/null
    echo "Added [General] section with InputMethod=qtvirtualkeyboard in $sddm_conf" 
  else
    # Update InputMethod line if section exists
    if grep -q '^\s*InputMethod=' "$sddm_conf"; then
      sudo sed -i '/^\[General\]/,/^\[/{s/^\s*InputMethod=.*/InputMethod=qtvirtualkeyboard/}' "$sddm_conf" 
      echo "Updated InputMethod to qtvirtualkeyboard in $sddm_conf" 
    else
      sudo sed -i '/^\[General\]/a InputMethod=qtvirtualkeyboard' "$sddm_conf" 
      echo "Appended InputMethod=qtvirtualkeyboard under [General] in $sddm_conf" 
    fi
  fi

  # Replace current background from assets
  sudo cp -r assets/sddm.png "/usr/share/sddm/themes/$theme_name/Backgrounds/default" 
  sudo sed -i 's|^wallpaper=".*"|wallpaper="Backgrounds/default"|' "/usr/share/sddm/themes/$theme_name/theme.conf" 
  
  printf "\n%.0s" {1..1}
  printf "${NOTE} copying ${YELLOW}JetBrains Mono Nerd Font${RESET} to ${YELLOW}/usr/local/share/fonts${RESET} .......\n"
  printf "${NOTE} necessary for the new SDDM theme to work properly........\n"

  sudo mkdir -p /usr/local/share/fonts/JetBrainsMonoNerd && \
  sudo cp -r "$HOME/.local/share/fonts/JetBrainsMonoNerd" /usr/local/share/fonts/JetBrainsMonoNerd

  if [ $? -eq 0 ]; then
    echo "Fonts copied successfully."
  else
    echo "Failed to copy fonts."
  fi

  # Update font cache and log the output
  fc-cache -v -f 

  printf "\n%.0s" {1..1}

  echo "${OK} - ${MAGENTA}Additional ${YELLOW}$theme_name SDDM Theme${RESET} successfully installed." 

else

  echo "${ERROR} - Failed to clone the sddm theme repository. Please check your internet connection." 
fi

printf "\n%.0s" {1..2}