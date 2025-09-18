#!/bin/bash

# Script de conexión rápida para Fibocom L850-GL
# Prueba la funcionalidad básica del módem y prepara la conexión

set -e

echo "=== Conexión rápida Fibocom L850-GL ==="
echo "Fecha: $(date)"
echo ""

# Verificar permisos de root para algunos comandos
if [[ $EUID -ne 0 ]]; then
    echo "⚠️  Nota: Algunos comandos requieren sudo. Se solicitará cuando sea necesario."
    echo ""
fi

# 1. Verificar que el hardware esté presente
echo "1. ✅ Verificando hardware..."
if lspci | grep -q "XMM7360"; then
    echo "   Hardware detectado: $(lspci | grep XMM7360)"
else
    echo "   ❌ ERROR: Hardware XMM7360 no encontrado"
    exit 1
fi

# 2. Verificar driver
echo ""
echo "2. ✅ Verificando driver..."
if lsmod | grep -q "iosm"; then
    echo "   Driver iosm cargado correctamente"
else
    echo "   ❌ ERROR: Driver iosm no está cargado"
    exit 1
fi

# 3. Verificar dispositivos
echo ""
echo "3. ✅ Verificando dispositivos..."
if ls /dev/wwan0* &>/dev/null; then
    echo "   Dispositivos WWAN disponibles:"
    ls -la /dev/wwan0*
else
    echo "   ❌ ERROR: No se encontraron dispositivos WWAN"
    exit 1
fi

# 4. Probar comunicación AT
echo ""
echo "4. 🔍 Probando comunicación AT..."

# Función para probar AT
test_at_communication() {
    local device=$1
    echo "   Probando $device..."
    
    # Instalar socat si no está disponible
    if ! command -v socat &> /dev/null; then
        echo "   Instalando socat..."
        sudo apt update && sudo apt install -y socat
    fi
    
    # Probar comando AT básico
    local response=$(echo "AT" | sudo timeout 3 socat - $device,raw,echo=0 2>/dev/null | tr -d '\r\n' || echo "NO_RESPONSE")
    
    if [[ "$response" == *"OK"* ]]; then
        echo "   ✅ $device responde: $response"
        
        # Obtener información del dispositivo
        echo "   📱 Obteniendo información del módem..."
        
        # IMEI
        local imei=$(echo "AT+CGSN" | sudo timeout 3 socat - $device,raw,echo=0 2>/dev/null | grep -oE '[0-9]{15}' || echo "No disponible")
        echo "      IMEI: $imei"
        
        # Información del fabricante
        local info=$(echo "ATI" | sudo timeout 3 socat - $device,raw,echo=0 2>/dev/null | head -2 | tail -1 | tr -d '\r\n' || echo "No disponible")
        echo "      Info: $info"
        
        # Estado de la señal
        local signal=$(echo "AT+CSQ" | sudo timeout 3 socat - $device,raw,echo=0 2>/dev/null | grep "+CSQ:" | tr -d '\r\n' || echo "No disponible")
        echo "      Señal: $signal"
        
        return 0
    else
        echo "   ❌ $device no responde o error: $response"
        return 1
    fi
}

# Probar en ambos puertos AT
AT_WORKING=false
for device in /dev/wwan0at0 /dev/wwan0at1; do
    if test_at_communication "$device"; then
        AT_WORKING=true
        WORKING_AT_DEVICE="$device"
        break
    fi
done

# 5. Verificar ModemManager
echo ""
echo "5. 🔍 Verificando ModemManager..."
if mmcli -L | grep -q "No modems"; then
    echo "   ⚠️  ModemManager no detecta el módem (esperado con modo RPC)"
    echo "   Versión: $(mmcli --version | head -1)"
else
    echo "   ✅ ModemManager detecta módems:"
    mmcli -L
fi

# 6. Resumen y próximos pasos
echo ""
echo "=== RESUMEN ==="

if [ "$AT_WORKING" = true ]; then
    echo "✅ ÉXITO: El módem funciona correctamente"
    echo "   - Hardware: Detectado"
    echo "   - Driver: Funcionando" 
    echo "   - Comunicación AT: OK en $WORKING_AT_DEVICE"
    echo ""
    echo "🚀 PRÓXIMOS PASOS:"
    echo "1. El módem está listo para configurar"
    echo "2. Configurar conexión con NetworkManager:"
    echo "   nmcli con add type gsm ifname '*' con-name 'Modem-WWAN' \\"
    echo "     gsm.apn 'TU-APN-AQUI'"
    echo ""
    echo "3. O probar el script de configuración avanzada:"
    echo "   sudo ./scripts/configure_modemmanager.sh"
    echo ""
    echo "📋 INFORMACIÓN NECESARIA:"
    echo "   - APN de tu operadora (ej: internet.movistar.mx)"
    echo "   - Usuario/contraseña (si es requerido)"
    echo ""
    echo "📚 Consulta docs/setup_guide.md para más detalles"
    
else
    echo "❌ PROBLEMA: El módem no responde a comandos AT"
    echo "   Posibles causas:"
    echo "   - SIM no insertada o defectuosa"
    echo "   - Módem en modo de bajo consumo"
    echo "   - Problema de firmware"
    echo ""
    echo "🔧 INTENTAR:"
    echo "1. Verificar que la SIM esté insertada correctamente"
    echo "2. Reiniciar el sistema"
    echo "3. Ejecutar: sudo ./scripts/configure_modemmanager.sh"
    echo "4. Consultar docs/troubleshooting.md"
fi

echo ""
echo "=== Fin de la verificación ==="