#!/bin/bash

# 1. Ensure the required tool is installed
apt-get update && apt-get install -y cloud-guest-utils

# 2. Create the expansion script in a secure path
cat << 'EOF' > /usr/local/bin/expand-disk.sh
#!/bin/bash
# Attempt to expand partition 1 on disk sda, then resize the filesystem
/usr/bin/growpart /dev/sda 1
/sbin/resize2fs /dev/sda1
EOF

# 3. Grant execution permissions
chmod +x /usr/local/bin/expand-disk.sh

# 4. Schedule automatic execution at startup via root's Crontab
(crontab -l 2>/dev/null; echo "@reboot /usr/local/bin/expand-disk.sh") | crontab -

echo "Setup complete. /dev/sda1 will automatically expand on every boot."
