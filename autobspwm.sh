#!/bin/bash

# ┌─┐┬ ┬┌┬┐┌─┐┌─┐┌─┐┌┬┐┬ ┬┌─┐ #     Writen by: boltercio
# ├─┤│ │ │ │ │└─┐├┤  │ │ │├─┘ #     Url: https://github.com/boltercio
# ┴ ┴└─┘ ┴ └─┘└─┘└─┘ ┴ └─┘┴   #     

### ---------- Colors ---------- ###
green="\e[0;32m\033[1m"           # Correct message
red="\e[0;31m\033[1m"             # Failed message
blue="\e[0;34m\033[1m"            # Normal message
yellow="\e[0;33m\033[1m"          # Warning message
purple="\e[0;35m\033[1m"          # Resalto de variable
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"            # Color normal
end="\033[0m\e[0m"                # Final de color

### ---------- Basic functions ---------- ###
trap ctrl_c INT

function ctrl_c(){
    echo -e "${Red}[!]${gray} Saliendo...${end}\n"
    tput cnorm
    exit 0
}

function logo() {
# Letra "Calvin S" de https://www.freetool.dev/es/generador-de-letras-ascii
clear
echo -e "
${gray}┌─┐┬ ┬┌┬┐┌─┐┌─┐┌─┐┌┬┐┬ ┬┌─┐
${gray}├─┤│ │ │ │ │└─┐├┤  │ │ │├─┘
${gray}┴ ┴└─┘ ┴ └─┘└─┘└─┘ ┴ └─┘┴  
                        ${turquoise}By Boltercio${end}

"
}

### ---------- Instalando paquetes ---------- ###
logo
echo -e "${green}[+]${gray} Actualizando repositorios...${end}"
sudo apt update &>/dev/null
sudo apt full-upgrade -qq -y &>/dev/null

function package_install() { 
    paquete=$1 
    if dpkg -s $paquete &>/dev/null; then
        echo -e "${green}[+] ${gray}El paquete ${purple}$paquete${gray} ya esta instalado.${end}"
    else
        sudo apt-get install -qq -y "$paquete" &>/dev/null
        if [ $? == 0 ]; then
            echo -e "${green}[+]${gray} Paqute ${purple}$paquete${gray} instalado correctamente.${end}"
        else
            echo -e "${red}[!] ${gray}Error al instalar el paquete ${purple}$paquete${end}"
        fi
    fi
    sleep 0.5
}

logo
echo -e "${green}[+]${gray} Instalando paquetes necesarios... ${end}"
paquetes=(zsh lsd bat curl wget acpi open-vm-tools open-vm-tools-desktop build-essential \
feh rofi xclip xsel bspwm sxhkd polybar picom kitty ranger unzip locate acpi nala \
ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick xdotool \
xorg fastfetch wmname fonts-font-awesome fonts-firacode)

for paquete in "${paquetes[@]}"; do
    package_install "$paquete"
done
sleep 2

# mover plugins zsh / clonar zsh-history-substring-search
echo -e "${green}[+]${gray} Instalando zsh y sus plugins.${end}"
if [ ! -f /usr/share/zsh/plugins ]; then 
    sudo mkdir -p /usr/share/zsh/plugins
fi
sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting -qq -y &>/dev/null
git clone https://github.com/zsh-users/zsh-history-substring-search.git &>/dev/null
sudo mv zsh-* /usr/share/zsh/plugins/
sudo mv /usr/share/zsh-* /usr/share/zsh/plugins/

# copiar directorios de configuracion
echo -e "${green}[+]${gray} Copiando configuraciones.${end}"
cp -r home/* $HOME/
cp -r home/.* $HOME/

# Instalando fuentes
echo -e "${green}[+]${gray} Instalando fuentes.${end}"
fc-cache -fv &>/dev/null

# Instalando npm y neovim
echo -e "${green}[+]${gray} Instalando Neovim...${end}"
sudo apt install --no-install-recommends npm -y &>/dev/null
cp -r home/.config/nvim $HOME/.config/
wget https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-arm64.tar.gz &>/dev/null
tar -zxf nvim-linux-arm64.tar.gz
sudo mv nvim-linux-arm64 /opt/nvim
sudo ln -s /opt/nvim/bin/nvim /usr/bin/nvim
rm -rf nvim-linux-arm64.tar.gz

# Instalando sddm y tema personalizado
echo -e "${green}[+]${gray} Instalando y configurando SDDM.${end}"
sddm=( libqt6svg6 qt6-declarative-dev qt6-svg-dev qt6-virtualkeyboard-plugin libqt6multimedia6 qml6-module-qtquick-controls qml6-module-qtquick-effects )
for PKG1 in "${sddm[@]}" ; do
  sudo apt install --no-install-recommends -y "$PKG1" &>/dev/null
done
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
fi

# Clone the repository
function install_sddm_theme() {
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

    echo "${OK} - ${MAGENTA}Additional ${YELLOW}$theme_name SDDM Theme${RESET} successfully installed." 

    else

    echo "${ERROR} - Failed to clone the sddm theme repository. Please check your internet connection." 
    fi
}

install_sddm_theme
sudo systemctl enable sddm &>/dev/null

# Configurando tema de grub
if [ -d /boot/grub/themes/kali ]; then
    sudo rm -rf /boot/grub/themes/kali
fi
if [ -f  /usr/share/images/desktop-base/desktop-grub.png  ]; then
    sudo rm -f /usr/share/images/desktop-base/desktop-grub.png
fi

echo -e "${green}[+]${gray} Configurando tema de GRUB.${end}"
wget -P /tmp https://github.com/shvchk/fallout-grub-theme/raw/master/install.sh &>/dev/null
sudo bash /tmp/install.sh --lang Spanish

# Cambiando shell por defecto
echo -e "${green}[+]${gray} Cambiando shell por defecto.${end}" 
chsh -s $(which zsh)
