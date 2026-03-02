#!/bin/bash

# Import Header
eval "$(curl -sL "https://raw.githubusercontent.com/djcrawleravp/scripter/refs/heads/main/scripts/header.sh")"
# -------------------------------------------------------------------------------------------------------------

# Script Init
script_name "DISK AUTO-EXPANDER"

title "System Essentials & Build Tools"
run_step "Failed to install cloud-guest-utils" "${SUDO_CMD}apt-get update -y && ${SUDO_CMD}apt-get install -y cloud-guest-utils"

title "Create Auto-Expander Script"
# We use sudo tee to create the file in a protected directory
run_step "Error while creating expand-disk script" "${SUDO_CMD} tee /usr/local/bin/expand-disk.sh > /dev/null << 'EOF'
#!/bin/bash
# Automatically expands partition 1 on disk sda and resizes the filesystem
/usr/bin/growpart /dev/sda 1
/sbin/resize2fs /dev/sda1
EOF
${SUDO_CMD} chmod +x /usr/local/bin/expand-disk.sh"

title "Schedule Root Cronjob"
# This adds the task specifically to root's crontab to bypass password prompts at boot
run_step "Setting the root cronjob failed" "( ${SUDO_CMD} crontab -l 2>/dev/null; echo '@reboot /usr/local/bin/expand-disk.sh' ) | ${SUDO_CMD} crontab -"

# Success Message
echo -e "${GREEN}$(print_done | tr -d '\n' | sed 's/\x1b\[0m//g') /dev/sda1 is now set to auto-expand on every boot.${RESET}"
