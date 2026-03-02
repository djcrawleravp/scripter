#!/bin/bash

# Detect Sudo
[ "$EUID" -eq 0 ] && SUDO="" || SUDO="sudo "

# 1. Setup Repo
$SUDO mkdir -p /etc/apt/keyrings
wget -qO- 'https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg' | $SUDO gpg --dearmor --yes -o /etc/apt/keyrings/windsurf-stable.gpg
echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/windsurf-stable.gpg] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main' | $SUDO tee /etc/apt/sources.list.d/windsurf.list > /dev/null

# 2. Install
$SUDO apt-get update -y -qq
$SUDO apt-get install -y windsurf -qq

# 3. Pin to Dock
APP_ID="windsurf.desktop"
FAVS=$(gsettings get org.gnome.shell favorite-apps)
if [[ $FAVS != *"$APP_ID"* ]]; then
    NEW_FAVS=$(echo "$FAVS" | sed "s/]/, '$APP_ID']/")
    gsettings set org.gnome.shell favorite-apps "$NEW_FAVS"
fi
