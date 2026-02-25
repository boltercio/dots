#!/bin/bash

### ---------- Colores ---------- ### 

green="\e[0;32m\033[1m"           # Correct message
red="\e[0;31m\033[1m"             # Failed message
blue="\e[0;34m\033[1m"            # Normal message
yellow="\e[0;33m\033[1m"          # Warning message
purple="\e[0;35m\033[1m"          # Resalto de variable
turquoise="\e[0;36m\033[1m"
gray="\e[0;37m\033[1m"            # Color normal
end="\033[0m\e[0m"                # Final de color

trap ctrl_c INT

function ctrl_c(){
	echo -e "${red}[!]${gray} Saliendo...${end}\n"
	tput cnorm
	exit 0
}

function logo () {
# Letra "Calvin S" de https://www.freetool.dev/es/generador-de-letras-ascii
clear
echo -e "
╔╗ ┌─┐┬ ┌┬┐┌─┐┬─┐╔═╗┌─┐┬─┐┬┌─┐┌┬┐┌─┐
╠╩╗│ ││  │ ├┤ ├┬┘╚═╗│  ├┬┘│├─┘ │ └─┐
╚═╝└─┘┴─┘┴ └─┘┴└─╚═╝└─┘┴└─┴┴   ┴ └─┘
                        ${turquoise}By Boltercio${end}
"
}

# Instalacion de sistema de gestion de paquetes brew
echo -e "Instalando administrador de paquetes BREW..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Instalacion de paquetes necesarios
casks=(aerospace font-hack-nerd-font font-sf-mono font-sf-mono)
packages=(atool bat borders btop docker fd ffmpeg ffmpegthumbnailer fzf \
ghostscript git highlight imagemagick jq lsd lua neovim node nowplaying-cli \
poppler python@3.14 resvg ripgrep sevenzip sketchybar switchaudio-osx thefuck \
w3m wget yazi zip zoxide)

function package_install() {
    option="$2"
    package="$1"
    if [ ! -z $option ];then
        echo -e "Instalando $package"
        brew install --cask $package
    else
        echo -e "instalando $package"
        brew install $package
    fi
}

echo -e "Instanlando paquetes necesarios..."
for package in ${casks[@]}; do
    package_install $package cask
done

for package in ${packages[@]}; do
    package_install $package
done

# Copiando archivos de configuracion necesarios
cp home/.zshrc $HOME/.zshrc
for directory in $(dir home/.config); do
    if [ ! -d $HOME/.config/$directory ]
        mkdir -p $HOME/.config/$directory
    else
        echo -e ""
        mv $HOME/.config/$directory $HOME/.config/$directory.old
    fi
    echo -e "Copiando la configuracion para $directory"
    cp home/.config/$directory $HOME/.config/
done

# Añadiendo aplicaciones a inicio automatico
defaults write NSGlobalDomain _HIHideMenuBar -bool true
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/AeroSpace.app", hidden:false}'
brew services start sketchybar

echo -e "Instalacion terminada, por favor reinicia para ver los cambios."
