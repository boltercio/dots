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
echo -e "${gray}Instalando paquetes necesarios...${end}"
paquetes=(kitty neovim npm python3 python3-pip pyton3-venv \
            zsh zsh-autosuggestions zsh-syntax-highlighting \
            steam lsd bat git curl wget\
         )

function is_installed() {
    dpkg -l "$1" &>/dev/null
    return $?
}

for paquete in "${paquetes[@]}"; do
    if ! is_installed "$paquete"; then
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
echo -e "${green}[+]${gray} Instalando plugins para zsh"
if [ ! -f /usr/share/zsh/plugins ]; then 
    mkdir -p /usr/share/zsh/plugins
fi

git clone https://github.com/zsh-users/zsh-history-substring-search.git
sudo mv zsh-* /usr/share/zsh/plugins/
sudo mv /usr/share/zsh-* /usr/share/zsh/plugins/

# copiar directorios de configuracion
echo -e "${green}[+]${gray} Copiando configuraciones"
cp dots/home/.zshrc $HOME/
if [ ! -f $HOME/.config ]; then 
    mkdir -p $HOME/.config
fi

cp -r dots/home/.config/kitty $HOME/.config/
cp -r dots/home/.config/nvim $HOME/.config/
cp -r dots/home/.config/zsh $HOME/.config/

echo -e "${green}[+]${gray} Eliminando repositorio descargado"
# instalar paquetes descargados
# clonar e instalar msi_ec y MControlCenter
