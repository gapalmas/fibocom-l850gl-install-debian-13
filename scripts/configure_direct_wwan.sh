#!/bin/bash

# Script alternativo para configurar WWAN usando herramientas de bajo nivel
# Cuando ModemManager no puede manejar el dispositivo en modo RPC

set -e

echo "=== Configuración directa de WWAN Fibocom L850-GL ==="

# Verificar dispositivos disponibles
echo "1. Verificando dispositivos WWAN disponibles..."
ls -la /dev/wwan* || {
    echo "ERROR: No se encontraron dispositivos WWAN"
    echo "Verifique que el driver iosm esté cargado: lsmod | grep iosm"
    exit 1
}

echo ""
echo "2. Verificando herramientas disponibles..."

# Verificar si qmi-network está disponible
if ! command -v qmi-network &> /dev/null; then
    echo "Instalando libqmi-utils..."
    sudo apt update
    sudo apt install -y libqmi-utils
fi

# Verificar si mbimcli está disponible
if ! command -v mbimcli &> /dev/null; then
    echo "Instalando libmbim-utils..."
    sudo apt install -y libmbim-utils
fi

echo ""
echo "3. Intentando comunicación AT con el módem..."

# Función para enviar comandos AT
send_at_command() {
    local device=$1
    local command=$2
    local timeout=${3:-3}
    
    echo "Enviando '$command' a $device..."
    
    # Usar minicom o socat para enviar comando AT
    if command -v socat &> /dev/null; then
        echo -e "$command\r" | sudo timeout $timeout socat - $device,raw,echo=0 2>/dev/null || true
    else
        echo "Instalando socat..."
        sudo apt install -y socat
        echo -e "$command\r" | sudo timeout $timeout socat - $device,raw,echo=0 2>/dev/null || true
    fi
}

# Probar comunicación AT en diferentes puertos
for device in /dev/wwan0at0 /dev/wwan0at1; do
    if [ -c "$device" ]; then
        echo "Probando $device..."
        send_at_command "$device" "AT"
        send_at_command "$device" "ATI"  # Información del dispositivo
        send_at_command "$device" "AT+CGSN"  # IMEI
        echo ""
    fi
done

echo "4. Verificando información del módulo con comandos AT..."

# Comando AT para obtener información básica
AT_DEVICE="/dev/wwan0at0"
if [ -c "$AT_DEVICE" ]; then
    echo "Obteniendo información del módem desde $AT_DEVICE..."
    
    # Crear script temporal para comandos AT
    cat > /tmp/at_commands.sh << 'EOF'
#!/bin/bash
exec 3< /dev/wwan0at0
exec 4> /dev/wwan0at0
echo "AT" >&4
read -t 2 response <&3
echo "Respuesta AT: $response"

echo "ATI" >&4
read -t 2 response <&3
echo "Info: $response"

echo "AT+CGSN" >&4
read -t 2 response <&3
echo "IMEI: $response"

exec 3<&-
exec 4>&-
EOF
    
    chmod +x /tmp/at_commands.sh
    sudo /tmp/at_commands.sh 2>/dev/null || echo "No se pudo comunicar por AT"
    rm -f /tmp/at_commands.sh
fi

echo ""
echo "5. Información del driver y kernel..."
echo "Driver iosm info:"
modinfo iosm 2>/dev/null || echo "No se pudo obtener info del módulo iosm"

echo ""
echo "Kernel modules cargados:"
lsmod | grep -E "(iosm|wwan)"

echo ""
echo "=== Configuración directa completada ==="
echo ""
echo "PRÓXIMOS PASOS:"
echo "1. Si el dispositivo responde a comandos AT, el hardware funciona"
echo "2. Para conectividad, configure NetworkManager manualmente:"
echo "   nmcli con add type gsm ifname '*' con-name 'Modem-WWAN'"
echo "3. O use wvdial para configuración PPP tradicional"
echo "4. Considere actualizar a ModemManager >= 1.26 para mejor soporte"