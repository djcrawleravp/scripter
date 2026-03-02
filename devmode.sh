#!/bin/bash

# SCRiPTeR Data
# -------------------------------------------------------------------------------------------------------
PRINTIMIR="https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/printimir.sh"
SUDERO="https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/sudero.sh"

# Import libraries
eval "$(curl -sL "$SUDERO")"
eval "$(curl -sL "$PRINTIMIR")"

# Estilos de Texto
BOLD_WHITE="\e[1;97m"
RESET="\e[0m"

# Función para imprimir títulos uniformes
title() {
    echo -e "\n${BOLD_WHITE}>>> $1${RESET}"
}
# -------------------------------------------------------------------------------------------------------

clear
echo -e "${BOLD_WHITE}----------------------------------------"
echo "        INSTALLING DEV MODE             "
echo -e "----------------------------------------${RESET}"

# 1. Usando la función title para cada sección:
title "System Essentials & Build Tools"
run_step "Failed to update apt" "${SUDO_CMD}apt-get update -y"
run_step "Failed to install essentials" "${SUDO_CMD}apt-get install -y git curl wget unzip build-essential jq htop apt-transport-https ca-certificates"

title "RDP Fixer"
run_step "Failed to run RDP Fixer" 'echo "1" | bash <(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/installers/Install-RDP-Fixer.sh")'

title "Python Environment"
run_step "Failed to install Python tools" "${SUDO_CMD}apt-get install -y python3 python3-pip python3-venv"

title "Docker & Docker Compose"
run_step "Failed to install Docker & Compose" "curl -fsSL https://get.docker.com | ${SUDO_CMD}sh"
run_step "Failed to add user to docker group" "${SUDO_CMD}usermod -aG docker $USER"

# ... y así sucesivamente con el resto
