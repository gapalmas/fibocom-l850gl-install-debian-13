#!/bin/bash

# Diagnóstico avanzado de SIM para Fibocom L850-GL
# Script para identificar problemas de detección de SIM

echo "🔍 DIAGNÓSTICO AVANZADO DE SIM - Fibocom L850-GL"
echo "================================================"
echo

# Función para ejecutar comando AT con timeout
execute_at_command() {
    local cmd="$1"
    local desc="$2"
    echo "📋 $desc"
    echo "   Comando: $cmd"
    
    # Usar timeout para evitar comandos colgados
    timeout 10s bash -c "printf \"$cmd\\r\\n\" | sudo socat - /dev/wwan0at0,raw" 2>/dev/null | head -3
    echo
}

# Verificar que el módem responde
echo "1. Verificación básica del módem"
echo "--------------------------------"
execute_at_command "ATI" "Información del firmware"
execute_at_command "AT+CGSN" "IMEI del dispositivo"
echo

# Diagnóstico específico de SIM
echo "2. Diagnóstico de SIM"
echo "-------------------"
execute_at_command "AT+CPIN?" "Estado del PIN del SIM"
execute_at_command "AT+CCID" "ICCID del SIM (estándar)"
execute_at_command "AT+QCCID" "ICCID del SIM (Qualcomm)"
execute_at_command "AT+ICCID" "ICCID del SIM (alternativo)"
execute_at_command "AT+CIMI" "IMSI del SIM"
echo

# Estado de la red
echo "3. Estado de la red"
echo "------------------"
execute_at_command "AT+COPS?" "Operador actual"
execute_at_command "AT+CREG?" "Estado de registro en red"
execute_at_command "AT+CSQ" "Intensidad de señal"
echo

# Configuración del módem
echo "4. Configuración del módem"
echo "-------------------------"
execute_at_command "AT+CFUN?" "Estado funcional del módem"
execute_at_command "AT+CGMM" "Modelo del módem"
execute_at_command "AT+CGMR" "Revisión del firmware"
echo

# Diagnóstico de hardware
echo "5. Verificación de hardware"
echo "---------------------------"
echo "📋 Verificando dispositivos de control..."
ls -la /dev/wwan* 2>/dev/null || echo "❌ No se encontraron dispositivos wwan"
echo

echo "📋 Estado del driver iosm..."
lsmod | grep iosm || echo "❌ Driver iosm no cargado"
echo

echo "📋 Información del dispositivo USB..."
lsusb | grep -i fibocom || echo "❌ Dispositivo Fibocom no encontrado en USB"
echo

# Recomendaciones basadas en los resultados
echo "6. Recomendaciones"
echo "-----------------"
echo "Si los comandos de SIM fallan pero el módem responde:"
echo "  • Verificar que el SIM esté correctamente insertado"
echo "  • Probar con un SIM diferente"
echo "  • Verificar que el SIM no esté bloqueado por PIN"
echo "  • Reiniciar el módem: sudo sh -c 'echo 0 > /sys/class/net/wwan0/device/rf_kill'"
echo
echo "Si no hay señal de red:"
echo "  • Verificar que las antenas estén conectadas"
echo "  • Verificar cobertura BAIT/Altan en la zona"
echo "  • Probar en modo manual: AT+COPS=1,0,\"MEXICO\""
echo

echo "✅ Diagnóstico completado"