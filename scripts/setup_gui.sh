#!/bin/bash

# Script para configurar interfaz gráfica de módem WWAN
# Configura el módem para ser usado con NetworkManager GUI

set -e

echo "=== Configuración de interfaz gráfica para Fibocom L850-GL ==="
echo ""

# Verificar si ejecutamos como usuario normal
if [[ $EUID -eq 0 ]]; then
    echo "❌ ERROR: No ejecutes este script como root"
    echo "Ejecuta como usuario normal, se pedirá sudo cuando sea necesario"
    exit 1
fi

echo "1. 🔧 Configurando permisos para el usuario..."

# Agregar usuario al grupo dialout para acceder a dispositivos módem
if ! groups | grep -q dialout; then
    echo "   Agregando usuario al grupo 'dialout'..."
    sudo usermod -a -G dialout $USER
    echo "   ⚠️  IMPORTANTE: Necesitarás cerrar sesión y volver a entrar para que tome efecto"
    NEED_LOGOUT=true
else
    echo "   ✅ Usuario ya está en el grupo 'dialout'"
    NEED_LOGOUT=false
fi

echo ""
echo "2. 🎛️  Verificando herramientas gráficas instaladas..."

# Verificar nm-connection-editor
if command -v nm-connection-editor &> /dev/null; then
    echo "   ✅ NetworkManager Connection Editor disponible"
else
    echo "   ❌ nm-connection-editor no encontrado"
fi

# Verificar modem-manager-gui
if command -v modem-manager-gui &> /dev/null; then
    echo "   ✅ Modem Manager GUI disponible"
else
    echo "   ❌ modem-manager-gui no encontrado"
fi

# Verificar gnome-control-center
if command -v gnome-control-center &> /dev/null; then
    echo "   ✅ GNOME Control Center disponible"
else
    echo "   ❌ gnome-control-center no encontrado"
fi

echo ""
echo "3. 📱 Creando conexión módem básica para interfaz gráfica..."

# Crear una conexión básica que aparezca en la interfaz gráfica
CONNECTION_NAME="Fibocom-L850GL-WWAN"

# Verificar si la conexión ya existe
if nmcli con show "$CONNECTION_NAME" &>/dev/null; then
    echo "   ⚠️  La conexión '$CONNECTION_NAME' ya existe. Eliminando..."
    nmcli con delete "$CONNECTION_NAME"
fi

# Crear conexión GSM básica
echo "   Creando conexión GSM básica..."
nmcli con add type gsm \
    ifname '*' \
    con-name "$CONNECTION_NAME" \
    gsm.apn "internet" \
    autoconnect false

echo "   ✅ Conexión '$CONNECTION_NAME' creada"

echo ""
echo "4. 🔄 Reiniciando NetworkManager..."
sudo systemctl restart NetworkManager
sleep 3

echo ""
echo "5. 📋 Estado actual del sistema..."

echo "   Conexiones disponibles:"
nmcli con show | grep -E "(NAME|$CONNECTION_NAME)" || echo "   No se encontró la conexión"

echo ""
echo "   Dispositivos disponibles:"
nmcli device status

echo ""
echo "=== CONFIGURACIÓN COMPLETADA ==="
echo ""
echo "🎉 ¡YA PUEDES USAR LA INTERFAZ GRÁFICA!"
echo ""
echo "📱 HERRAMIENTAS GRÁFICAS DISPONIBLES:"
echo ""
echo "1. 🎛️  GNOME Settings (Configuración del Sistema):"
echo "   - Abre: 'Configuración' → 'Red' → 'Mobile Broadband'"
echo "   - O ejecuta: gnome-control-center network"
echo ""
echo "2. 🔧 NetworkManager Connection Editor:"
echo "   - Ejecuta: nm-connection-editor"
echo "   - Permite configuración detallada de conexiones"
echo ""
echo "3. 📊 Modem Manager GUI:"
echo "   - Ejecuta: modem-manager-gui"
echo "   - Herramienta especializada para módems"
echo "   - Muestra información detallada y estadísticas"
echo ""
echo "4. 🖱️  Applet de NetworkManager (barra superior):"
echo "   - Clic en el icono de red en la barra superior"
echo "   - Busca opciones de 'Mobile Broadband' o 'WWAN'"
echo ""
echo "⚙️  CONFIGURACIÓN DE APN:"
echo "Para configurar tu operadora:"
echo "1. Abre cualquiera de las herramientas gráficas"
echo "2. Busca la conexión '$CONNECTION_NAME'"
echo "3. Edita el APN según tu operadora:"
echo "   - Movistar MX: internet.movistar.mx"
echo "   - Telcel: internet.itelcel.com"
echo "   - AT&T: broadband"
echo "   - Verizon: vzwinternet"
echo ""
if [ "$NEED_LOGOUT" = true ]; then
    echo "⚠️  IMPORTANTE: CIERRA SESIÓN Y VUELVE A ENTRAR"
    echo "Es necesario para que los permisos del grupo 'dialout' tomen efecto"
    echo ""
fi
echo "🚀 PRÓXIMOS PASOS:"
echo "1. Inserta tu tarjeta SIM si no lo has hecho"
echo "2. Abre 'Configuración' → 'Red'"
echo "3. Configura el APN de tu operadora"
echo "4. ¡Conecta!"
echo ""
echo "📚 Si tienes problemas, consulta docs/troubleshooting.md"