#!/bin/bash

# Script para crear un launcher en el escritorio para la conexión WWAN
# Esto permitirá activar/desactivar la conexión móvil fácilmente

DESKTOP_FILE="$HOME/Desktop/BAIT-Mobile-Connection.desktop"
SCRIPT_PATH="/home/develop/Downloads/Fibocom/scripts/setup_wwan_connection.sh"

echo "📱 Creando acceso directo para conexión móvil BAIT..."

cat > "$DESKTOP_FILE" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=BAIT Mobile Connection
Comment=Activar conexión móvil Fibocom L850-GL
Exec=gnome-terminal --title="BAIT Mobile" -- /home/develop/Downloads/Fibocom/scripts/setup_wwan_connection.sh
Icon=network-cellular-4g
Terminal=false
Categories=Network;
StartupNotify=true
EOF

chmod +x "$DESKTOP_FILE"
chmod +x "$SCRIPT_PATH"

echo "✅ Acceso directo creado en el escritorio"
echo "💡 También puedes ejecutar directamente: $SCRIPT_PATH"