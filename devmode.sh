#!/bin/bash

# SCRiPTeR Data
# ----------------------------------
PRINTIMIR="https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/printimir.sh"
SUDERO="https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/sudero.sh"

# Import libraries
eval "$(curl -sL "$SUDERO")"
eval "$(curl -sL "$PRINTIMIR")"
# ----------------------------------

clear
echo "------------------------"
echo " Installing Dev Mode... "
echo "------------------------"
echo ""
echo ""

echo "System Essentials & Build Tools"
run_step "Failed to install essentials" "${SUDO_CMD}apt-get update -y && ${SUDO_CMD}apt-get install -y git curl wget unzip build-essential jq htop apt-transport-https ca-certificates"

echo "RDP Fixer (Automatically selecting option 1)"
run_step "Failed to run RDP Fixer" 'echo "1" | bash <(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/installers/Install-RDP-Fixer.sh")'

echo "Python Environment"
run_step "Failed to install Python tools" "${SUDO_CMD}apt-get install -y python3 python3-pip python3-venv"

echo "Docker & Docker Compose"
run_step "Failed to install Docker & Compose" "curl -fsSL https://get.docker.com | ${SUDO_CMD}sh && ${SUDO_CMD}usermod -aG docker $USER"

echo "Install NVM"
run_step "Failed to download NVM" 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'

echo "Node.js LTS, npm, and PM2 (Loading NVM explicitly per command)"
run_step "Failed to setup Node.js environment" 'rm -f $HOME/.npmrc && . $HOME/.nvm/nvm.sh && nvm install --lts && nvm alias default "lts/*" && nvm use default && npm install -g npm@latest pm2'

echo "Install Bun"
run_step "Failed to install Bun" 'curl -fsSL https://bun.sh/install | bash'
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

echo "Cloudflare Wrangler (Installed globally)"
run_step "Failed to install Wrangler" '. $HOME/.nvm/nvm.sh && npm install -g wrangler@latest'

echo "Claude Code CLI"
run_step "Failed to install Claude Code" 'curl -fsSL https://claude.ai/install.sh | bash'

echo "Claude Gemini CLI"
run_step "Failed to Gemini CLI" 'npm install -g @google/gemini-cli'

echo "Claude OpenAI Codex"
run_step "Failed to OpenAI Codex" 'npm i -g @openai/codex'

echo "Setup APT Keyrings for IDEs"
run_step "Failed to create keyrings directory" "${SUDO_CMD}mkdir -p /etc/apt/keyrings"

echo "Google Antigravity IDE"
run_step "Failed to install Antigravity" 'bash <(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/installers/Install-Antigravity.sh")'

echo "Windsurf IDE"
run_step "Failed to install Windsurf" 'bash <(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/installers/Install-WindSurf.sh")'

echo "Mic drop... "
