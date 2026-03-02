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

title() {
    echo -e "\n${BOLD_WHITE}>>> $1$ <<<{RESET}"
}
# -------------------------------------------------------------------------------------------------------

clear
echo -e "${BOLD_WHITE}----------------------------------------"
echo "        INSTALLING DEV MODE             "
echo -e "----------------------------------------${RESET}"

title "System Essentials & Build Tools"
run_step "Failed to update and install essentials" "${SUDO_CMD}apt-get update -y && ${SUDO_CMD}apt-get install -y git curl wget unzip build-essential jq htop apt-transport-https ca-certificates"

title "RDP Fixer"
run_step "Failed to run RDP Fixer" 'echo "1" | bash <(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/installers/Install-RDP-Fixer.sh")'

title "Python Environment"
run_step "Failed to install Python tools" "${SUDO_CMD}apt-get install -y python3 python3-pip python3-venv"

title "Docker & Docker Compose"
run_step "Failed to install Docker" "curl -fsSL https://get.docker.com | ${SUDO_CMD}sh && ${SUDO_CMD}usermod -aG docker $USER"

title "NVM"
run_step "Failed to download NVM" 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'

title "Node.js Environment (LTS, npm, PM2)"
run_step "Failed to setup Node.js" 'rm -f $HOME/.npmrc && . $HOME/.nvm/nvm.sh && nvm install --lts && nvm alias default "lts/*" && nvm use default && npm install -g npm@latest pm2'

title "Bun"
run_step "Failed to install Bun" 'curl -fsSL https://bun.sh/install | bash && export BUN_INSTALL="$HOME/.bun" && export PATH="$BUN_INSTALL/bin:$PATH"'

title "Cloudflare Wrangler"
run_step "Failed to install Wrangler" '. $HOME/.nvm/nvm.sh && npm install -g wrangler@latest'

title "AI Dedicated CLIs (Claude, Gemini, Codex)"
run_step "Failed to install AI CLIs" 'bash <(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/installers/Install-Claude-CLI.sh") && bash <(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/installers/Install-Gemini-CLI.sh") && bash <(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/installers/Install-Codex-CLI.sh")'

title "Google Antigravity IDE"
run_step "Failed to install Antigravity" 'bash <(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/installers/Install-Antigravity.sh")'

title "Windsurf IDE"
run_step "Failed to install Windsurf" 'bash <(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/installers/Install-WindSurf.sh")'

echo -e "\n${BOLD_WHITE}Mic drop...${RESET}"
