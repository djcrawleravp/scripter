#!/bin/bash

# Import Header for optimized functions
eval "$(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/header.sh")"

# Detect Sudo
[ "$EUID" -eq 0 ] && SUDO="" || SUDO="sudo "

# Script Init
script_name "ANTIGRAVITY IDE"

title "Setup Antigravity Repository"
run_step "Failed to setup repository" "
$SUDO mkdir -p /etc/apt/keyrings && \
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | $SUDO gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg && \
echo 'deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main' | $SUDO tee /etc/apt/sources.list.d/antigravity.list > /dev/null
"

title "Install Antigravity"
run_step "Failed to install Antigravity" "$SUDO apt-get update -y -qq && $SUDO apt-get install -y antigravity -qq"

title "Pin to Dock"
run_step "Failed to pin to dock" "
APP_ID=\"antigravity.desktop\" && \
FAVS=\$(gsettings get org.gnome.shell favorite-apps) && \
if [[ \$FAVS != *\"\$APP_ID\"* ]]; then \
    NEW_FAVS=\$(echo \"\$FAVS\" | sed \"s/]/, '\$APP_ID']/\") && \
    gsettings set org.gnome.shell favorite-apps \"\$NEW_FAVS\"; \
fi
"

# Success Message
echo -e "${GREEN}$(print_done | tr -d '\n' | sed 's/\x1b\[0m//g') Antigravity IDE installed successfully.${RESET}"