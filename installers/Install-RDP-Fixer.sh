#!/bin/bash

# Variables de ruta y nombre
SERVICE_NAME="RDP-Fixer"
SCRIPT_DIR="$HOME/Scripts"
FIX_SCRIPT_DIR="$SCRIPT_DIR/$SERVICE_NAME"
FIX_SCRIPT="$FIX_SCRIPT_DIR/fix.sh"
LOOP_SCRIPT="$FIX_SCRIPT_DIR/daemon.sh"
USER_SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$USER_SERVICE_DIR/$SERVICE_NAME.service"

clear
echo "----------------"
echo " $SERVICE_NAME"
echo "----------------"
echo "  1) Install    "
echo "  2) Uninstall  "
echo "----------------"
echo ""
read -p "Pick your poison [1-2]: " OPCION
echo ""

case $OPCION in
    1)
        read -p "¿Run every? X seconds (Default: 10): " INTERVALO
        [[ "$INTERVALO" =~ ^[0-9]+$ ]] || INTERVALO=10

        # Solicitar sudo antes para el espacio de línea solicitado
        sudo -v
        echo ""

        echo "Hold my guarapo..."
        echo ""
        sudo apt update >/dev/null 2>&1 && sudo apt install xdotool iproute2 libnotify-bin -y >/dev/null 2>&1
        mkdir -p "$FIX_SCRIPT_DIR"
        mkdir -p "$USER_SERVICE_DIR"

        # GENERAR SCRIPT DE ACCIÓN (fix.sh)
        cat <<EOF > "$FIX_SCRIPT"
#!/bin/bash
SERVICE_NAME="$SERVICE_NAME"

D_DETECTOR=\$(ps -u \$USER e | grep -Po 'DISPLAY=[:\d.]+' | head -n 1 | cut -d= -f2)
export DISPLAY=\${D_DETECTOR:-:0}
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/\$(id -u)/bus

if [ "\$1" == "notify" ]; then

    MESSAGES=(
        "RDP secured. Try breaking it, I dare you."
        "Connection locked down. You're welcome."
        "No stuck keys. No drama. Just power."
        "Session stabilized. Drops mic."
        "Your RDP just got babysat."
        "Fortress mode: ON."
        "Bullshit-proof mode: ON."
        "Glitches? Not on my watch."
        "Keyboard ghosts exorcised."
        "RDP behaving like a good boy."
        "System under control. As always."
        "Chaos detected and eliminated."
        "Zero drama. Maximum dominance."
        "Clean session. Sharp response."
        "Your remote kingdom is safe."
        "Another connection saved. Again."
    )

    RANDOM_MSG=\${MESSAGES[\$RANDOM % \${#MESSAGES[@]}]}

    notify-send "\$SERVICE_NAME" "\$RANDOM_MSG" -t 2000
else
    xdotool keyup Control_L Control_R Shift_L Shift_R Alt_L Alt_R Meta_L Meta_R
fi
EOF

        chmod +x "$FIX_SCRIPT"

        # GENERAR SCRIPT DE BUCLE (daemon.sh)
        cat <<EOF > "$LOOP_SCRIPT"
#!/bin/bash
PREV_CONN=""
while true; do
    CURRENT_CONN=\$(ss -nt state established | grep ":3389" | awk '{print \$NF}' | head -n 1)
    if [ -n "\$CURRENT_CONN" ]; then
        if [ "\$CURRENT_CONN" != "\$PREV_CONN" ]; then
            "$FIX_SCRIPT" notify
            PREV_CONN="\$CURRENT_CONN"
        else
            "$FIX_SCRIPT"
        fi
    else
        PREV_CONN=""
    fi
    sleep $INTERVALO
done
EOF
        chmod +x "$LOOP_SCRIPT"

        # GENERAR ARCHIVO DE SERVICIO
        cat <<EOF > "$SERVICE_FILE"
[Unit]
Description=Servicio Fix-RDP Dinámico
After=network.target

[Service]
ExecStart="$LOOP_SCRIPT"
Restart=always

[Install]
WantedBy=default.target
EOF

        # Instalación silenciosa
        systemctl --user daemon-reload >/dev/null 2>&1
        systemctl --user enable "$SERVICE_NAME.service" >/dev/null 2>&1
        systemctl --user restart "$SERVICE_NAME.service" >/dev/null 2>&1
        loginctl enable-linger "$USER" >/dev/null 2>&1
        
        if systemctl --user is-active --quiet "$SERVICE_NAME.service"; then
            echo "**Drops mic**"
        else
            echo "Error initialising service."
        fi
        ;;

    2)
        echo ""
        echo "Wiping out..."
        echo ""
        systemctl --user stop "$SERVICE_NAME.service" >/dev/null 2>&1
        systemctl --user disable "$SERVICE_NAME.service" >/dev/null 2>&1
        rm -f "$SERVICE_FILE" "$FIX_SCRIPT" "$LOOP_SCRIPT"
        rmdir "$FIX_SCRIPT_DIR" 2>/dev/null
        systemctl --user daemon-reload >/dev/null 2>&1
        echo "Nothing to see here!"
        ;;

    *)
        echo "WTF was that?."
        exit 1
        ;;
esac
