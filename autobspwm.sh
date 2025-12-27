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
feh rofi xclip xsel bspwm sxhkd plybar picom kitty ranger unzip locate acpi \
ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick xdotool \
xorg fastfech wmname fonts-font-awesome fonts-firacode)

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
cp home/* $HOME/

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
/install_scripts/sddm.sh
/install_scripts/sddm_theme.sh

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
