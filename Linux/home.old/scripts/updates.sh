#!/bin/bash

# Author: Enríquez González https://github.com/AlvinPix
# instagram: @alvinpx_271
# facebook: @alvin.gonzalez.13139

# COLORS THE SCRIPT
Black='\033[1;30m'
Red='\033[1;31m'
Green='\033[1;32m'
Yellow='\033[1;33m'
Blue='\033[1;34m'
Purple='\033[1;35m'
Cyan='\033[1;36m'
White='\033[1;37m'
NC='\033[0m'
blue='\033[0;34m'
white='\033[0;37m'
lred='\033[0;31m'

# PRESENT THE SCRIPT
banner () {
echo -e "${White}        \****__              ____					"
echo -e "${White}          |    *****\_      --/ *\-__					"
echo -e "${White}          /_          (_    ./ ,/----'					"
echo -e "${Blue} Kali Linux${White} \__         (_./  /					"
echo -e "${Blue}  By AlvinPix${White}  \__           \___----^__        		"
echo -e "${White}                _/   _                  \     ${Blue} ⇅${White} DPKG	"
echo -e "${White}         |    _/  __/ )\"\ _____         *\				"
echo -e "${White}         |\__/   /    ^ ^       \____      )				"
echo -e "${White}          \___--/                    \______)				"
echo ""
echo -e "${Blue} ██╗   ██╗██████╗ ██████╗  █████╗ ████████╗███████╗	"
echo -e "${Blue} ██║   ██║██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔════╝	"
echo -e "${Blue} ██║   ██║██████╔╝██║  ██║███████║   ██║   █████╗	"
echo -e "${Blue} ██║   ██║██╔═══╝ ██║  ██║██╔══██║   ██║   ██╔══╝	"
echo -e "${Blue} ╚██████╔╝██║     ██████╔╝██║  ██║   ██║   ███████╗	"
echo -e "${Blue}  ╚═════╝ ╚═╝     ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝	"
}

# PRINT BANNER AND UPDATE KALI
update () {
echo ""
banner
echo ""
echo -e "${Blue} [${Yellow}⇅${Blue}]${White} comprobando si nala esta instalado..."
if which nala >/dev/null; then
	sleep 1
	echo ""
	echo -e "${Blue} [${Cyan}i${Blue}]${White} Nala esta instalado, procediendo a actualizar el sistema..."
	echo ""
	sudo nala update>/dev/null
	sudo nala list --upgradable
	sleep 3
	sudo nala upgrade -y
else
	echo ""
	sleep 1
	echo -e "${Blue}[${Cyan}i${Blue}]${White} Instalando nala desde apt"
	sudo apt install nala -y
	echo ""
	echo -e "${Blue} [${Cyan}i${Blue}]${White} Nala ya esta instalado, ejecuta el script de nuevo!"
	sleep 1
	exit 0
fi
}


# CALL UPDATE AND RESET
reset
update
