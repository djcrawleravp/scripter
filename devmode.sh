#!/bin/bash

# Import Header
eval "$(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/header.sh")"
# -------------------------------------------------------------------------------------------------------------

# Script Init
script_name "DEV MODE"

title "System Essentials & Build Tools"
run_step "Failed essentials" "${SUDO_CMD}apt-get update -y && ${SUDO_CMD}apt-get install -y git curl wget unzip build-essential jq htop apt-transport-https ca-certificates"

title "RDP Fixer"
run_step "Failed RDP Fixer" "echo '1' | bash <(curl -sL '$INSTALLERS/Install-RDP-Fixer.sh')"

title "Python Environment"
run_step "Failed Python" "${SUDO_CMD}apt-get install -y python3 python3-pip python3-venv"

title "Docker & Docker Compose"
run_step "Failed Docker" "curl -fsSL https://get.docker.com | ${SUDO_CMD}sh && ${SUDO_CMD}usermod -aG docker \$USER"

title "NVM"
run_step "Failed NVM" 'curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash'

title "Node.js Environment (LTS, npm, PM2)"
run_step "Failed Node setup" 'rm -f $HOME/.npmrc && export NVM_DIR="$HOME/.nvm" && [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && nvm install --lts && nvm alias default "lts/*" && nvm use default && npm install -g npm@latest pm2'

title "Bun"
run_step "Failed Bun" 'curl -fsSL https://bun.sh/install | bash && export BUN_INSTALL="$HOME/.bun" && export PATH="$BUN_INSTALL/bin:$PATH"'

title "Cloudflare Wrangler"
run_step "Failed Wrangler" "npm install -g wrangler@latest"

title "Claude Code"
run_step "Failed Claude" "npm install -g @anthropic-ai/claude-code"

title "Gemini CLI"
run_step "Failed Gemini" "npm install -g @google/generative-ai"

title "OpenAI CLI"
run_step "Failed OpenAI" "npm i -g @openai/codex"

title "Google Antigravity IDE"
run_step "Failed Antigravity" "bash <(curl -sL '$INSTALLERS/Install-Antigravity.sh')"

title "Windsurf IDE"
run_step "Failed Windsurf" "bash <(curl -sL '$INSTALLERS/Install-WindSurf.sh')"

# End
print_done; echo -e "${GREEN} All processes were successfully installed.${RESET}"
