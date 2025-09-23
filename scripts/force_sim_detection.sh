#!/bin/bash

# Script para forzar detección de SIM en Fibocom L850-GL
# Para casos donde SIM funciona en teléfono pero no en módem

echo "🔄 FORZAR DETECCIÓN DE SIM - Fibocom L850-GL"
echo "==========================================="
echo "💡 Caso: SIM funciona en teléfono, no detectado en módem"
echo

# Función para ejecutar comando AT con timeout y retry
execute_at_retry() {
    local cmd="$1"
    local desc="$2"
    local retries=3
    
    echo "📋 $desc"
    for i in $(seq 1 $retries); do
        echo "   Intento $i/$retries: $cmd"
        local result=$(timeout 5s bash -c "printf \"$cmd\\r\\n\" | sudo socat - /dev/wwan0at0,raw 2>/dev/null" | head -2)
        if [[ -n "$result" && "$result" != *"ERROR"* ]]; then
            echo "   ✅ $result"
            return 0
        else
            echo "   ❌ Fallo"
            sleep 2
        fi
    done
    echo "   ⚠️  Comando falló después de $retries intentos"
    return 1
}

# 1. Verificación inicial
echo "1. Verificación inicial del módem"
echo "--------------------------------"
if ! execute_at_retry "ATI" "Verificar comunicación básica"; then
    echo "❌ El módem no responde. Reiniciando driver..."
    sudo modprobe -r iosm
    sleep 3
    sudo modprobe iosm
    sleep 5
    echo "🔄 Reintentando comunicación..."
    execute_at_retry "ATI" "Verificar comunicación post-reinicio"
fi
echo

# 2. Configuración de funcionalidad mínima
echo "2. Configuración de funcionalidad"
echo "--------------------------------"
execute_at_retry "AT+CFUN=0" "Apagar radio (modo offline)"
sleep 3
execute_at_retry "AT+CFUN=1" "Encender radio completo"
sleep 5
echo

# 3. Forzar inicialización de SIM
echo "3. Inicialización forzada de SIM"
echo "-------------------------------"
execute_at_retry "AT+CFUN=4" "Modo de vuelo (disable SIM)"
sleep 3
execute_at_retry "AT+CFUN=1" "Reactivar SIM"
sleep 5

# Intentar diferentes comandos de SIM
echo "🔍 Probando diferentes comandos de SIM..."
execute_at_retry "AT+CPIN?" "Estado PIN (estándar)"
execute_at_retry "AT+QSIMSTAT?" "Estado SIM (Qualcomm)"
execute_at_retry "AT+CCID" "ICCID (estándar)"
execute_at_retry "AT+QCCID" "ICCID (Qualcomm)"
execute_at_retry "AT+CIMI" "IMSI"
echo

# 4. Configuración específica para BAIT
echo "4. Configuración específica BAIT/Altan"
echo "------------------------------------"
execute_at_retry "AT+COPS=0" "Selección automática de red"
sleep 5
execute_at_retry "AT+CGDCONT=1,\"IP\",\"altan.mx\"" "Configurar APN BAIT"
execute_at_retry "AT+COPS?" "Verificar operador"
execute_at_retry "AT+CREG?" "Estado de registro"
echo

# 5. Comandos alternativos de diagnóstico
echo "5. Diagnóstico alternativo"
echo "------------------------"
execute_at_retry "AT+CSQ" "Calidad de señal"
execute_at_retry "AT+CPAS" "Estado de actividad del módem"
execute_at_retry "AT+CLCC" "Lista de llamadas (detecta SIM indirectamente)"
echo

# 6. Reset completo del módem
echo "6. Reset de fábrica del módem"
echo "----------------------------"
echo "⚠️  Aplicando reset de fábrica..."
execute_at_retry "AT&F" "Reset a configuración de fábrica"
sleep 5
execute_at_retry "AT+CFUN=1,1" "Reinicio completo del módem"
echo "⏳ Esperando reinicio del módem (30 segundos)..."
sleep 30

# 7. Verificación final
echo "7. Verificación post-reset"
echo "-------------------------"
execute_at_retry "ATI" "Comunicación post-reset"
execute_at_retry "AT+CPIN?" "Estado SIM post-reset"
execute_at_retry "AT+COPS?" "Operador post-reset"
echo

echo "✅ Proceso completado"
echo
echo "💡 Siguientes pasos si SIM sigue sin detectarse:"
echo "  1. Apagar laptop, retirar SIM, limpiar contactos, reinsertar"
echo "  2. Verificar en BIOS si WWAN está habilitado"
echo "  3. Probar con SIM de otro operador (Telcel, Movistar)"
echo "  4. Contactar BAIT para verificar activación de datos"
echo "  5. Verificar bandas LTE compatibles con región"