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
echo -e "${green}[+]${gray} Actualizando repositorios...${end}"
sudo apt update &>/dev/null
sudo apt full-upgrade -qq -y &>/dev/null

echo -e "${green}[INFO]${gray} Instalando paquetes necesarios...${end}"
paquetes=(zsh lsd bat curl wget acpi open-vm-tools open-vm-tools-desktop build-essential \
feh rofi xclip xsel bspwm sxhkd polybar picom kitty unzip xsel locate acpi \
ffmpeg 7zip jq poppler-utils fd-find ripgrep fzf zoxide imagemagick \
xorg fastfetch wmname fonts-font-awesome font-hack fonts-firacode)

instalar_paquete() { 
    paquete=$1 
    consulta=$(dpkg -l | grep -q -w "$paquete")
    if [ "$consulta" ]; then
        echo -e "${green}[+] ${gray}$paquete ya esta instalado en tu sistema.${end}"
    else
        sudo apt-get install -qq -y "$paquete" &>/dev/null
        if [ "$(echo $?)" != 0 ]; then
            echo -e "${red}[!]${gray} La instalacion de ${paquete} ha fallado.${end}"
        else
            echo -e "${blue}[*] ${gray}$paquete se ha instalado correctamente.${end}"
        fi
    fi
    sleep 0.5
}

for paquete in "${paquetes[@]}"; do
    instalar_paquete "$paquete"
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

# Instalando fuentes
echo -e "${green}[+]${gray} Instalando fuentes.${end}"
mkdir -p /tmp/fonts
wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip -O /tmp/fonts/Hack.zip &>/dev/null
unzip -q /tmp/fonts/Hack.zip -d /tmp/fonts
wget -q --show-progress https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip -O /tmp/fonts/JetBrainsMono.zip &>/dev/null
unzip -q /tmp/fonts/JetBrainsMono.zip -d /tmp/fonts
mkdir -p ~/.local/share/fonts
mv -f /tmp/fonts/*.ttf ~/.local/share/fonts/
rm -rf /tmp/fonts
fc-cache -fv &>/dev/null

# Instalando yazi 
echo -e "${green}[+]${gray} Instalando Yazi.${end}"
arquitectura=$(uname -m)
wget https://github.com/sxyazi/yazi/releases/download/nightly/yazi-$arquitectura-unknown-linux-gnu.deb &>/dev/null
sudo dpkg -i yazi-$arquitectura-unknown-linux-gnu.deb &>/dev/null
rm -rf yazi-$arquitectura-unknown-linux-gnu.deb

# Instalando npm y neovim
echo -e "${green}[+]${gray} Instalando Neovim.${end}"
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
