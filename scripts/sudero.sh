#!/bin/bash

export SUDO_CMD=""

setup_sudo() {
    # 1. If root, do nothing silently
    if [ "$EUID" -eq 0 ]; then
        return 0
    fi

    local ROOT_PROMPT="\n📦 I feel better when I 'sudo'. What's your ROOT password?:"

    # 2. If sudo is missing, ask for root pass and install silently
    if ! command -v sudo >/dev/null 2>&1; then
        echo -e "$ROOT_PROMPT"
        su -c "apt-get update -qq && apt-get install -yqq sudo && usermod -aG sudo $USER" >/dev/null 2>&1
        echo "🔄 Done. Restart your terminal and run again."
        exit 1
    fi

    # 3. If user is not in the sudo group, ask for root pass and add them silently
    if ! groups "$USER" | grep -q "\bsudo\b"; then
        echo -e "$ROOT_PROMPT"
        su -c "usermod -aG sudo $USER" >/dev/null 2>&1
        echo "🔄 Done. Restart your terminal and run again."
        exit 1
    fi

    # 4. Check if we already have a cached token silently. If not, prompt exactly once for user password.
    if ! sudo -n true >/dev/null 2>&1; then
        echo ""
        sudo -p "🔑 I feel better when I 'sudo'. What's your USER password?: " -v
    fi

    # Keep the sudo token alive in the background
    (while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null) &

    SUDO_CMD="sudo "
}

setup_sudo
