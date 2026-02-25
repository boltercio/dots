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
${gray}┌─┐┬  ┌─┐┌┬┐┌─┐┌─┐┌─┐┬─┐┌┬┐┌─┐┬─┐  ┌─┐┌┬┐${end}
${gray}├─┘│  ├─┤ │ ├─┤├┤ │ │├┬┘│││├─┤├┬┘  │   │ ${end}
${gray}┴  ┴─┘┴ ┴ ┴ ┴ ┴└  └─┘┴└─┴ ┴┴ ┴┴└─  └─┘ ┴ ${end}
                        ${turquoise}By Boltercio${end}

"
}

### ---------- Instalando paquetes ---------- ###

echo -e "${green}[+]${gray} Actualziando repositorios...${end}"
sudo apt update &>/dev/null
sudo apt full-upgrade -qq -y &>/dev/null

function package_install() {
    paquete=$1
    if dpkg -s $paquete &>/dev/null; then
        echo -e "${green}[+]${gray} El paquete ${purple}$paquete${gray} ya está instalado.${end}"
    else
        echo -e "${green}[+]${gray} Instalando paquete ${purple}$paquete${gray}...${end}"
        sudo apt install -qq $paquete -y &>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${green}[+]${gray} Paquete ${purple}$paquete${gray} instalado correctamente.${end}"
        else
            echo -e "${red}[!]${gray} Error al instalar el paquete ${purple}$paquete${end}"
        fi
    fi
    sleep 0.5
}

logo
echo -e "${green}[+]${gray} Instalando paquetes necesarios...${end}"
paquetes=(zsh lsd bat curl lsb-config wget qemu-guest-agent)

for paquete in "${paquetes[@]}"; do
    package_install $paquete
done
sleep 2

# mover plugins zsh / clonar zsh-history-substring-search
echo -e "${green}[+]${gray} Instalando zsh y sus plugins.${end}"
if [ ! -f /usr/share/zsh/plugins ]; then 
    sudo mkdir -p /usr/share/zsh/plugins
fi

sudo apt install zsh zsh-autosuggestions zsh-syntax-highlighting -y &>/dev/null
git clone https://github.com/zsh-users/zsh-history-substring-search.git &>/dev/null
sudo mv zsh-* /usr/share/zsh/plugins/
sudo mv /usr/share/zsh-* /usr/share/zsh/plugins/

# copiar directorios de configuracion
echo -e "${green}[+]${gray} Copiando configuraciones.${end}"
cp home/.zshrc $HOME/
if [ ! -f $HOME/.config ]; then 
    mkdir -p $HOME/.config
fi
cp -r home/.config/zsh $HOME/.config/
cp -r home/.config/nvim $HOME/.config/
cp -r home/.config/ranger $HOME/.config/

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

# Instalando npm y neovim
echo -e "${green}[+]${gray} Instalando Neovim...${end}"
sudo apt install npm -y &>/dev/null
cp -r home/.config/nvim $HOME/.config/
wget https://github.com/neovim/neovim/releases/download/nightly/nvim-linux-arm64.tar.gz &>/dev/null
tar -zxf nvim-linux-arm64.tar.gz
sudo mv nvim-linux-arm64 /opt/nvim
sudo ln -s /opt/nvim/bin/nvim /usr/bin/nvim
rm -rf nvim-linux-arm64.tar.gz

echo -e "${green}[+]${gray} Eliminando repositorio descargado.${end}"
cd $HOME
rm -rf dots

# deshabilitando configuracion automatica de red
echo -e "${green}[+]${gray} Parando configuracion automatica de red.${end}"
systemctl stop systemd-networkd &>/dev/null
systemctl disable systemd-networkd &>/dev/null
systemctl mask systemd-networkd &>/dev/null

# Instalando cliente wazuh
echo -e "${green}[+]${gray} Instalando agente de monitoreo wazuh.${end}"
wget https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.14.3-1_arm64.deb && sudo WAZUH_MANAGER='192.168.0.100' WAZUH_AGENT_NAME="$(hostname)" dpkg -i ./wazuh-agent_4.14.3-1_arm64.deb

# Cambiando shell por defecto
echo -e "${green}[+]${gray} Cambiando shell por defecto.${end}" 
chsh -s $(which zsh)
