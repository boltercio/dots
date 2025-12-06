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

### ---------- Comprobando directorio de trabajo ---------- ###
local_dir=$(pwd)
if [ "$local_dir" != "$HOME/dots" ]; then
    echo -e "${red}[!]${gray} Debes ejecutar este script desde el directorio $local_dir${end}"
    exit 1
fi

### ---------- Instalando paquetes ---------- ###
logo
echo -e "${gray}Instalando paquetes necesarios...${end}"
paquetes=(zsh lsd bat curl wget acpi open-vm-tools open-vm-tools-desktop \
feh rofi xclip xsel bspwm sxhkd polybar picom kitty yazi \
unzip fzf xsel imagenmagick acpi locate build-essential)

for paquete in "${paquetes[@]}"; do
    consulta=$(dpkg-query -s $paquete &>/dev/null)
    if [ "$consulta" ]; then
        sudo apt-get install -qq -y "$paquete" &>/dev/null
        if [ "$(echo $?)" != 0 ]; then
            echo -e "${red}[!]${gray} La instalacion de ${paquete} ha fallado.${end}"
        else
            echo -e "${blue}[*] ${gray}$paquete se ha instalado correctamente.${end}"
        fi
    else
        echo -e "${green}[+] ${gray}$paquete ya esta instalado en tu sistema.${end}"
        sleep 0.5
    fi
done
sleep 2

# mover plugins zsh / clonar zsh-history-substring-search
echo -e "${green}[+]${gray} Instalando zsh y sus plugins.${end}"
if [ ! -f /usr/share/zsh/plugins ]; then 
    sudo mkdir -p /usr/share/zsh/plugins
fi
sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting -qq -y &>/dev/null
git clone https://github.com/zsh-users/zsh-history-substring-search.git &>/dev/null
sudo mv zsh-history-substring-search /usr/share/zsh/plugins/zsh-history-substring-search
sudo mv /usr/share/zsh-* /usr/share/zsh/plugins/

# copiar directorios de configuracion
echo -e "${green}[+]${gray} Copiando configuraciones.${end}"
cp home/.zshrc $HOME/
if [ ! -d $HOME/.config ]; then 
    mkdir -p $HOME/.config
fi
cp -r home/.config/* $HOME/.config/

if [ ! -d $HOME/.local/share/fonts ]; then
    mkdir -p $HOME/.local/share/fonts
fi
cp -r home/.local/share/fonts/* $HOME/.local/share/fonts/
fc-cache -fv &>/dev/null

sudo apt install --no-install-recommends npm -y &>/dev/null
cp -r home/.config/nvim $HOME/.config/
wget https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-arm64.tar.gz &>/dev/null
tar -zxf nvim-linux-arm64.tar.gz
sudo mv nvim-linux-arm64 /opt/nvim
sudo ln -s /opt/nvim/bin/nvim /usr/bin/nvim
rm -rf nvim-linux-arm64.tar.gz

# Instalando display manager lightdm
echo -e "${green}[+]${gray} Instalando y configurando lightDM."
sudo apt install --no-install-recommends lightdm -qq -y &>/dev/null
sudo sed -i s/#autologin-user=/autologin-user=$USER/g /etc/lightdm/lightdm.conf
sudo systemctl enable lightdm

# Configurando tema de grub
wget -P /tmp https://github.com/shvchk/fallout-grub-theme/raw/master/install.sh &>/dev/null
bash /tmp/install.sh --lang Spanish

# Cambiando shell por defecto
echo -e "${green}[+]${gray} Cambiando shell por defecto.${end}" 
chsh -s $(which zsh)
