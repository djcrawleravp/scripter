#!/bin/bash

# Import Header
eval "$(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/header.sh")"
# -------------------------------------------------------------------------------------------------------------

# Script Init
script_name "RDP FIXER"

title "Installing XRDP & Xorg"
run_step "Failed to install XRDP packages" "${SUDO_CMD}apt-get update && ${SUDO_CMD}apt-get install -y xrdp xorg xserver-xorg-core"

title "Fixing SSL Permissions"
# This fixes the black screen/immediate logout issue on Debian/Proxmox
run_step "Failed to add user to ssl-cert" "${SUDO_CMD}adduser xrdp ssl-cert"

title "Configuring Desktop Session"
run_step "Failed to setup .xsession" "echo 'exec startxfce4' > ~/.xsession && chmod +x ~/.xsession"

title "Restarting Service"
run_step "Failed to restart XRDP" "${SUDO_CMD}systemctl restart xrdp"

# End
echo -e "${GREEN}$(print_done | tr -d '\n' | sed 's/\x1b\[0m//g') RDP is now fixed and ready!${RESET}"
