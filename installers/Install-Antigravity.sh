#!/bin/bash

# Detect Sudo
[ "$EUID" -eq 0 ] && SUDO="" || SUDO="sudo "

# 1. Setup Repo
$SUDO mkdir -p /etc/apt/keyrings
curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | $SUDO gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
echo 'deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main' | $SUDO tee /etc/apt/sources.list.d/antigravity.list > /dev/null

# 2. Install
$SUDO apt-get update -y -qq
$SUDO apt-get install -y antigravity -qq

# 3. Pin to Dock
APP_ID="antigravity.desktop"
FAVS=$(gsettings get org.gnome.shell favorite-apps)
if [[ $FAVS != *"$APP_ID"* ]]; then
    NEW_FAVS=$(echo "$FAVS" | sed "s/]/, '$APP_ID']/")
    gsettings set org.gnome.shell favorite-apps "$NEW_FAVS"
fi
