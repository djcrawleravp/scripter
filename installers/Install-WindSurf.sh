#!/bin/bash

# Import Header for optimized functions
eval "$(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/header.sh")"

# Detect Sudo
[ "$EUID" -eq 0 ] && SUDO="" || SUDO="sudo "

# Script Init
script_name "WINDSURF IDE"

title "Setup Windsurf Repository"
run_step "Failed to setup repository" "
$SUDO mkdir -p /etc/apt/keyrings && \
wget -qO- 'https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg' | $SUDO gpg --dearmor --yes -o /etc/apt/keyrings/windsurf-stable.gpg && \
echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/windsurf-stable.gpg] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main' | $SUDO tee /etc/apt/sources.list.d/windsurf.list > /dev/null
"

title "Install Windsurf"
run_step "Failed to install Windsurf" "$SUDO apt-get update -y -qq && $SUDO apt-get install -y windsurf -qq"

title "Pin to Dock"
run_step "Failed to pin to dock" "
APP_ID=\"windsurf.desktop\" && \
FAVS=\$(gsettings get org.gnome.shell favorite-apps) && \
if [[ \$FAVS != *\"\$APP_ID\"* ]]; then \
    NEW_FAVS=\$(echo \"\$FAVS\" | sed \"s/]/, '\$APP_ID']/\") && \
    gsettings set org.gnome.shell favorite-apps \"\$NEW_FAVS\"; \
fi
"

# Success Message
echo -e "${GREEN}$(print_done | tr -d '\n' | sed 's/\x1b\[0m//g') Windsurf IDE installed successfully.${RESET}"