#!/bin/bash

# SCRiPTeR Data
# ----------------------------------
PRINTIMIR="https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/scripts/printimir.sh"
SUDERO="https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/sudero.sh"

# Import libraries
source <(curl -sL "$SUDERO")
source <(curl -sL "$PRINTIMIR")
# ----------------------------------

clear
echo "------------------------"
echo " Installing Dev Mode... "
echo "------------------------"

# 1. System Essentials & Build Tools
run_step "Failed to update apt" "${SUDO_CMD}apt-get update -y"
run_step "Failed to install essentials" "${SUDO_CMD}apt-get install -y git curl wget unzip build-essential jq htop apt-transport-https ca-certificates"

# 2. RDP Fixer (Automatically selecting option 1)
run_step "Failed to run RDP Fixer" 'echo "1" | bash <(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/installers/Install-RDP-Fixer.sh")'

# 3. Python Environment
run_step "Failed to install Python tools" "${SUDO_CMD}apt-get install -y python3 python3-pip python3-venv"

# 4. Docker & Docker Compose
run_step "Failed to install Docker & Compose" "curl -fsSL https://get.docker.com | ${SUDO_CMD}sh"
run_step "Failed to add user to docker group" "${SUDO_CMD}usermod -aG docker $USER"

# 5. Install and activate NVM
run_step "Failed to download NVM" 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 6. Node.js LTS, npm, and PM2
run_step "Failed to install Node.js LTS" 'nvm install --lts && nvm alias default "lts/*" && nvm use default'
run_step "Failed to update npm" 'npm install -g npm@latest'
run_step "Failed to install PM2" 'npm install -g pm2'

# 7. Install Bun
run_step "Failed to install Bun" 'curl -fsSL https://bun.sh/install | bash'
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# 8. Cloudflare Wrangler (Installed globally)
run_step "Failed to install Wrangler" 'npm install -g wrangler@latest'

# 9. AI CLIs (Installed globally via NPM)
run_step "Failed to install AI CLIs" 'npm install -g opencode-cli gemini-cli openai-cli claude-cli'

# 10. Setup APT Keyrings for IDEs
run_step "Failed to create keyrings directory" "${SUDO_CMD}mkdir -p /etc/apt/keyrings"

# 11. Google Antigravity IDE (Official Debian Repository)
run_step "Failed to add Antigravity key" "curl -fsSL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | ${SUDO_CMD}gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg"
run_step "Failed to add Antigravity repo" "echo 'deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main' | ${SUDO_CMD}tee /etc/apt/sources.list.d/antigravity.list > /dev/null"
run_step "Failed to install Antigravity IDE" "${SUDO_CMD}apt-get update -y && ${SUDO_CMD}apt-get install -y antigravity"

# 12. Windsurf IDE (Official Debian Repository)
run_step "Failed to add Windsurf key" "wget -qO- 'https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/windsurf.gpg' | ${SUDO_CMD}gpg --dearmor --yes -o /etc/apt/keyrings/windsurf-stable.gpg"
run_step "Failed to add Windsurf repo" "echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/windsurf-stable.gpg] https://windsurf-stable.codeiumdata.com/wVxQEIWkwPUEAGf3/apt stable main' | ${SUDO_CMD}tee /etc/apt/sources.list.d/windsurf.list > /dev/null"
run_step "Failed to install Windsurf IDE" "${SUDO_CMD}apt-get update -y && ${SUDO_CMD}apt-get install -y windsurf"

echo "Mic drop... "
