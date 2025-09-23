#!/bin/bash

# Script de configuración de red para BAIT/Altan México
# Para cuando el SIM se detecta pero no se conecta a la red

echo "🌐 CONFIGURACIÓN DE RED BAIT/ALTAN - Fibocom L850-GL"
echo "=================================================="
echo

# Función para ejecutar comando AT con timeout
execute_at() {
    local cmd="$1"
    local desc="$2"
    echo "📋 $desc"
    echo "   Comando: $cmd"
    
    local result=$(timeout 10s bash -c "printf \"$cmd\\r\\n\" | sudo socat - /dev/wwan0at0,raw 2>/dev/null" | head -5 | tr -d '\r\n' | sed 's/^[[:space:]]*//')
    
    if [[ -n "$result" ]]; then
        echo "   Respuesta: $result"
        if [[ "$result" == *"ERROR"* ]]; then
            echo "   ❌ Error en comando"
            return 1
        else
            echo "   ✅ OK"
            return 0
        fi
    else
        echo "   ❌ Sin respuesta"
        return 1
    fi
    echo
}

# 1. Verificación inicial
echo "1. Verificación del módem y SIM"
echo "------------------------------"
execute_at "ATI" "Información del módem"
execute_at "AT+CGSN" "IMEI"
execute_at "AT+CPIN?" "Estado del SIM"
execute_at "AT+CIMI" "IMSI del SIM (identidad del suscriptor)"
echo

# 2. Configuración específica de BAIT/Altan
echo "2. Configuración BAIT/Altan México"
echo "--------------------------------"

# Configurar APN principal
execute_at "AT+CGDCONT=1,\"IP\",\"altan.mx\"" "Configurar APN BAIT (altan.mx)"

# Configurar parámetros de autenticación (generalmente no necesarios para BAIT)
execute_at "AT+CGAUTH=1,0" "Sin autenticación para APN"

# Activar contexto PDP
execute_at "AT+CGACT=1,1" "Activar contexto de datos"

echo

# 3. Configuración de red específica para México
echo "3. Configuración de red México"
echo "-----------------------------"

# Buscar redes disponibles (esto puede tomar tiempo)
echo "🔍 Buscando redes disponibles (puede tomar 30-60 segundos)..."
execute_at "AT+COPS=?" "Buscar operadores disponibles"

# Configurar modo de selección de red
execute_at "AT+COPS=0" "Selección automática de red"

# Verificar registro en red
execute_at "AT+CREG?" "Estado de registro en red 2G/3G"
execute_at "AT+CGREG?" "Estado de registro en red GPRS"
execute_at "AT+CEREG?" "Estado de registro en red LTE"

echo

# 4. Configuración de bandas LTE para México
echo "4. Configuración de bandas LTE México"
echo "-----------------------------------"

# BAIT/Altan opera principalmente en:
# - Banda 28 (700 MHz) - Principal
# - Banda 4 (1700/2100 MHz AWS)
# - Banda 2 (1900 MHz)

echo "📡 Configurando bandas LTE para México..."

# Verificar bandas soportadas
execute_at "AT+QBAND?" "Verificar bandas configuradas"

# Configurar bandas específicas para México (depende del módem)
execute_at "AT+QCFG=\"band\"" "Verificar configuración de banda actual"

echo

# 5. Verificación de conectividad
echo "5. Verificación de conectividad"
echo "------------------------------"

execute_at "AT+CSQ" "Calidad de señal"
execute_at "AT+COPS?" "Operador actual"
execute_at "AT+CGPADDR=1" "Dirección IP asignada"

# Verificar estado de la conexión
execute_at "AT+CGACT?" "Estado de contextos PDP"

echo

# 6. Test de conectividad básica
echo "6. Test de conectividad"
echo "---------------------"

# Activar modo de datos
execute_at "AT+CGDATA=\"PPP\",1" "Activar conexión de datos"

echo

# 7. Configuración en NetworkManager
echo "7. Configuración en NetworkManager"
echo "--------------------------------"

echo "📝 Configurando conexión en NetworkManager..."

# Crear conexión WWAN en NetworkManager
sudo nmcli connection add \
    type gsm \
    con-name "BAIT-Altan-WWAN" \
    ifname wwan0 \
    gsm.apn "altan.mx" \
    gsm.auto-config yes \
    connection.autoconnect yes

echo "✅ Conexión NetworkManager creada"

# Activar la conexión
echo "🔗 Activando conexión..."
sudo nmcli connection up "BAIT-Altan-WWAN"

echo

# 8. Verificación final
echo "8. Verificación final"
echo "-------------------"

echo "📊 Estado de conexiones NetworkManager:"
nmcli connection show --active | grep -E "(wwan|gsm|BAIT)"

echo
echo "📊 Estado de interfaces de red:"
ip addr show | grep -A5 wwan

echo
echo "🌐 Test de conectividad a internet:"
if ping -c 3 -I wwan0 8.8.8.8 >/dev/null 2>&1; then
    echo "✅ Conectividad a internet OK"
else
    echo "❌ Sin conectividad a internet"
fi

echo
echo "✅ Configuración completada"
echo
echo "💡 Si la conexión falla:"
echo "  1. Verificar cobertura BAIT/Altan en tu área"
echo "  2. Contactar BAIT (800-123-2248) para activar datos"
echo "  3. Verificar saldo/plan de datos activo"
echo "  4. Reintentar con: nmcli connection up BAIT-Altan-WWAN"