#!/bin/bash

# Script de verificación final después de instalar SIM y antenas
# Para usar después de la instalación física completa

echo "=== Verificación final Fibocom L850-GL ==="
echo "📅 $(date)"
echo ""

echo "🔍 Verificando instalación física..."
echo ""

# 1. Hardware básico
echo "1. ✅ Hardware base:"
if lspci | grep -q "XMM7360"; then
    echo "   📡 Módulo WWAN: Detectado"
else
    echo "   ❌ Módulo WWAN: No detectado"
    exit 1
fi

# 2. Driver
echo ""
echo "2. ✅ Driver del sistema:"
if lsmod | grep -q "iosm"; then
    echo "   🔧 Driver iosm: Cargado"
else
    echo "   ❌ Driver iosm: No cargado"
    exit 1
fi

# 3. Dispositivos
echo ""
echo "3. ✅ Dispositivos de comunicación:"
if ls /dev/wwan0* &>/dev/null; then
    echo "   📱 Puertos WWAN: Disponibles"
    ls /dev/wwan0* | sed 's/^/      /'
else
    echo "   ❌ Puertos WWAN: No encontrados"
    exit 1
fi

# 4. Verificar comunicación con SIM
echo ""
echo "4. 🔍 Verificación de SIM y comunicación AT..."

# Función mejorada para probar AT
test_modem_with_sim() {
    local device="/dev/wwan0at0"
    
    if [ ! -c "$device" ]; then
        echo "   ❌ $device no disponible"
        return 1
    fi
    
    echo "   📞 Probando comunicación AT en $device..."
    
    # Test básico AT
    local at_response=$(echo "AT" | sudo timeout 3 socat - $device,raw,echo=0 2>/dev/null | tr -d '\r\n' | head -1)
    if [[ "$at_response" != *"OK"* ]]; then
        echo "   ❌ Módem no responde a comandos AT"
        return 1
    fi
    
    echo "   ✅ Módem responde: $at_response"
    
    # Verificar SIM
    echo "   🔍 Verificando estado de SIM..."
    local sim_status=$(echo "AT+CPIN?" | sudo timeout 3 socat - $device,raw,echo=0 2>/dev/null | grep "+CPIN:" | tr -d '\r\n')
    
    if [[ "$sim_status" == *"READY"* ]]; then
        echo "   ✅ SIM detectada y lista: $sim_status"
        SIM_READY=true
    elif [[ "$sim_status" == *"SIM PIN"* ]]; then
        echo "   ⚠️  SIM requiere PIN: $sim_status"
        echo "      💡 Desactiva el PIN desde tu teléfono antes de usar"
        SIM_READY=false
    elif [[ "$sim_status" == *"SIM PUK"* ]]; then
        echo "   ❌ SIM bloqueada (PUK requerido): $sim_status"
        SIM_READY=false
    else
        echo "   ❌ SIM no detectada o problema: $sim_status"
        SIM_READY=false
    fi
    
    # Información adicional si SIM está lista
    if [ "$SIM_READY" = true ]; then
        echo ""
        echo "   📋 Información de SIM y red:"
        
        # IMEI
        local imei=$(echo "AT+CGSN" | sudo timeout 3 socat - $device,raw,echo=0 2>/dev/null | grep -oE '[0-9]{15}' | head -1)
        if [ -n "$imei" ]; then
            echo "      📱 IMEI: $imei"
        fi
        
        # Operadora
        local operator=$(echo "AT+COPS?" | sudo timeout 3 socat - $device,raw,echo=0 2>/dev/null | grep "+COPS:" | cut -d'"' -f2)
        if [ -n "$operator" ]; then
            echo "      📡 Operadora: $operator"
        fi
        
        # Calidad de señal
        local signal=$(echo "AT+CSQ" | sudo timeout 3 socat - $device,raw,echo=0 2>/dev/null | grep "+CSQ:" | cut -d' ' -f2 | cut -d',' -f1)
        if [ -n "$signal" ] && [ "$signal" != "99" ]; then
            local signal_percent=$(( signal * 100 / 31 ))
            echo "      📶 Señal: $signal/31 (${signal_percent}%)"
        else
            echo "      📶 Señal: No disponible o muy débil"
        fi
    fi
    
    return 0
}

# Ejecutar verificación de módem
if test_modem_with_sim; then
    MODEM_OK=true
else
    MODEM_OK=false
fi

# 5. Estado de antenas (verificación física)
echo ""
echo "5. 📡 Verificación de antenas:"
echo "   ⚠️  VERIFICACIÓN MANUAL REQUERIDA:"
echo "   📋 Checklist de instalación física:"
echo "      □ Antena principal conectada (conector MAIN)"
echo "      □ Antena auxiliar conectada (conector AUX/DIV)"
echo "      □ Conectores apretados firmemente"
echo "      □ Cables no doblados o pellizcados"
echo "      □ Antenas alejadas de metal"
echo ""

# 6. NetworkManager y GUI
echo "6. 🖥️  Interfaz gráfica:"
if nmcli con show | grep -q "Fibocom-L850GL-WWAN"; then
    echo "   ✅ Conexión GUI configurada"
    echo "   🚀 Abrir con: gnome-control-center network"
else
    echo "   ⚠️  Ejecutar: ./scripts/setup_gui.sh"
fi

# Resumen final
echo ""
echo "=== RESUMEN FINAL ==="

if [ "$MODEM_OK" = true ]; then
    echo "🎉 ¡EXCELENTE! Todo está funcionando correctamente"
    echo ""
    echo "✅ Hardware: OK"
    echo "✅ Driver: OK" 
    echo "✅ Comunicación: OK"
    
    if [ "$SIM_READY" = true ]; then
        echo "✅ SIM: Lista"
        echo ""
        echo "🚀 LISTO PARA CONECTAR:"
        echo "1. Abre: Configuración → Red → Mobile Broadband"
        echo "2. Edita la conexión 'Fibocom-L850GL-WWAN'"
        echo "3. Configura el APN de tu operadora"
        echo "4. ¡Conecta!"
        echo ""
        echo "📋 APNs comunes:"
        echo "   • Telcel: internet.itelcel.com"
        echo "   • Movistar: internet.movistar.mx"
        echo "   • AT&T: broadband"
    else
        echo "⚠️  SIM: Requiere atención"
        echo ""
        echo "🔧 SIGUIENTE PASO:"
        echo "1. Verifica que la SIM esté insertada correctamente"
        echo "2. Desactiva el PIN de la SIM (usando un teléfono)"
        echo "3. Reinicia el sistema"
        echo "4. Ejecuta este script nuevamente"
    fi
    
else
    echo "❌ PROBLEMA: El módem no responde"
    echo ""
    echo "🔧 POSIBLES CAUSAS:"
    echo "• SIM no insertada"
    echo "• Conectores de antena sueltos"
    echo "• Módulo no asentado correctamente"
    echo "• Problema de alimentación"
    echo ""
    echo "📚 Consulta: docs/troubleshooting.md"
fi

echo ""
echo "=== Fin de verificación ==="