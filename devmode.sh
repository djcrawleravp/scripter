#!/bin/bash

# ==========================================================
# CONFIGURACIÓN DINÁMICA
# ==========================================================
RAW_BASE="https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main"
SCRIPTS="$RAW_BASE/scripts"
INSTALLERS="$RAW_BASE/installers"

# Importar librerías
eval "$(curl -sL "$SCRIPTS/sudero.sh")"
eval "$(curl -sL "$SCRIPTS/printimir.sh")"

# Estilos de Texto
BOLD_WHITE="\e[1;97m"
BOLD_YELLOW="\e[1;33m"
RESET="\e[0m"

title() {
    local texto="$1"
    local largo=${#texto}
    local linea=$(printf '%*s' "$largo" | tr ' ' '-')
    echo -e "\n${BOLD_YELLOW}${texto}"
    echo -e "${linea}${RESET}"
}

# --- PUENTE NVM (Para que npm funcione "así nomás") ---
npm() {
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    command npm "$@"
}
# ------------------------------------------------------

# ==========================================================

clear
echo -e "${BOLD_WHITE}----------------------------------------"
echo "        INSTALLING DEV MODE             "
echo -e "----------------------------------------${RESET}"

title "System Essentials & Build Tools"
run_step "Failed to update and install essentials" "${SUDO_CMD}apt-get update -y && ${SUDO_CMD}apt-get install -y git curl wget unzip build-essential jq htop apt-transport-https ca-certificates"

title "RDP Fixer"
run_step "Failed to run RDP Fixer" "echo '1' | bash <(curl -sL '$INSTALLERS/Install-RDP-Fixer.sh')"

title "Python Environment"
run_step "Failed to install Python tools" "${SUDO_CMD}apt-get install -y python3 python3-pip python3-venv"

title "Docker & Docker Compose"
run_step "Failed to install Docker" "curl -fsSL https://get.docker.com | ${SUDO_CMD}sh && ${SUDO_CMD}usermod -aG docker \$USER"

title "NVM"
run_step "Failed to download NVM" 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'

title "Node.js Environment (LTS, npm, PM2)"
run_step "Failed to setup Node.js" 'rm -f $HOME/.npmrc && export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install --lts && nvm alias default "lts/*" && nvm use default && npm install -g npm@latest pm2'

title "Bun"
run_step "Failed to install Bun" 'curl -fsSL https://bun.sh/install | bash && export BUN_INSTALL="$HOME/.bun" && export PATH="$BUN_INSTALL/bin:$PATH"'

title "Cloudflare Wrangler"
run_step "Failed to install Wrangler" "npm install -g wrangler@latest"

title "Claude Code"
run_step "Failed to install Claude Code" "npm install -g @anthropic-ai/claude-code"

title "Gemini CLI"
run_step "Failed to install Gemini CLI" "npm install -g @google/generative-ai"

title "OpenAI CLI"
run_step "Failed to install OpenAI CLI" "npm i -g @openai/codex"

title "Google Antigravity IDE"
run_step "Failed to install Antigravity" "bash <(curl -sL '$INSTALLERS/Install-Antigravity.sh')"

title "Windsurf IDE"
run_step "Failed to install Windsurf" "bash <(curl -sL '$INSTALLERS/Install-WindSurf.sh')"

echo -e "\n${BOLD_WHITE}Mic drop...${RESET}"
