#!/bin/bash

APP_NAME="Vibe-Kanban"
NPX_PACKAGE_NAME="vibe-kanban"

BASE_DIR="$HOME/Scripts/$APP_NAME"
RESOURCE_DIR="$BASE_DIR/Resources"
RUNNER="$BASE_DIR/run.sh"
ICON="$RESOURCE_DIR/icon.png"
DESKTOP_FILE="$APP_NAME.desktop"
DESKTOP_PATH="$HOME/.local/share/applications/$DESKTOP_FILE"

ICON_URL="https://raw.githubusercontent.com/BloopAI/vibe-kanban/main/packages/public/apple-touch-icon.png"

echo "----------------"
echo " $APP_NAME"
echo "----------------"
echo ""
echo "Hold my guarapo......"

# Limpieza inicial (Solo procesos de node/npx para no matarnos a nosotros mismos)
pkill -f "$NPX_PACKAGE_NAME" 2>/dev/null
rm -f "$DESKTOP_PATH"

mkdir -p "$RESOURCE_DIR" "$HOME/.local/share/applications"
[ -f "$ICON" ] || curl -sL "$ICON_URL" -o "$ICON"

# --- GENERAR EL RUNNER (run.sh) ---
cat <<'EOF' > "$RUNNER"
#!/bin/bash

APP="vibe-kanban"

# 1. Obtener el puerto EXACTO cruzando los PIDs de la app con los puertos abiertos
PIDS=$(pgrep -f "$APP")
if [ -n "$PIDS" ]; then
    # Convertimos los PIDs en un formato que grep entienda (ej: 123|456|789)
    PID_REGEX=$(echo $PIDS | tr ' ' '|')
    # Buscamos esos PIDs específicos en ss y extraemos solo el número del puerto
    PORT=$(ss -ltnp 2>/dev/null | grep -E "pid=($PID_REGEX)," | awk '{print $4}' | rev | cut -d: -f1 | rev | grep -E '^[0-9]+$' | head -n 1)
fi

# Si todo lo demás falla, asumimos el puerto 3000 por defecto
URL="http://127.0.0.1:${PORT:-3000}"

# 2. ¿La URL responde (da OK)?
if curl -s -I "$URL" --max-time 1 > /dev/null; then
    # SI DA OK: Abrimos navegador y terminamos
    xdg-open "$URL"
    exit 0
fi

# 3. SI NO DA OK: Limpieza brutal (exactamente como pediste) y arranque nuevo
notify-send "Vibe-Kanban" "Warming up..." -t 2000

pkill -f "$APP" 2>/dev/null
sleep 1

# Arrancamos limpio
nohup npx -y "$APP" >/dev/null 2>&1 &
EOF

chmod +x "$RUNNER"

# --- CREAR ACCESO DIRECTO ---
cat <<EOF > "$DESKTOP_PATH"
[Desktop Entry]
Name=$APP_NAME
Exec="$RUNNER"
Icon=$ICON
Terminal=false
Type=Application
Categories=Development;
StartupNotify=true
EOF

chmod +x "$DESKTOP_PATH"

# Gestionar Favoritos de GNOME
FAVS=$(gsettings get org.gnome.shell favorite-apps)
if [[ $FAVS != *"$DESKTOP_FILE"* ]]; then
    NEW_FAVS=$(echo "$FAVS" | sed "s/]/, '$DESKTOP_FILE']/")
    gsettings set org.gnome.shell favorite-apps "$NEW_FAVS"
fi

echo ""
echo "Mic drop..."
