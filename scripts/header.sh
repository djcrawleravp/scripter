#!/bin/bash

RAW_BASE="https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main"
SCRIPTS="$RAW_BASE/scripts"
INSTALLERS="$RAW_BASE/installers"

# Import Libraries
eval "$(curl -sL "$SCRIPTS/sudero.sh")"
eval "$(curl -sL "$SCRIPTS/printimir.sh")"

# Text Styles
BOLD_WHITE="\e[1;97m"
BOLD_YELLOW="\e[1;33m"
RESET="\e[0m"

# Title Counter
TITLE_COUNT=0

# Script Name
script_name() {
    clear
    local name="$1"
    echo -e "${BOLD_WHITE}----------------------------------------"
    echo "        INSTALLING $name             "
    echo -e "----------------------------------------${RESET}"
}

# Titles
title() {
    ((TITLE_COUNT++))
    local texto="${TITLE_COUNT}. $1"
    local largo=${#texto}
    local linea=$(printf '%*s' "$largo" | tr ' ' '-')
    echo -e "\n${BOLD_YELLOW}${texto}"
    echo -e "${linea}-${RESET}"
}

# NVM Bridge
npm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    command npm "$@"
}
