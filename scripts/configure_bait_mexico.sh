#!/bin/bash

# Configuración específica para BAIT (Banco Azteca) con red Altan México
# APN: altan.mx

echo "=== Configuración BAIT/Altan Networks México ==="
echo "Fecha: $(date)"
echo ""

echo "📱 Información de BAIT:"
echo "   Operador: BAIT (Banco Azteca Internet Technologies)"
echo "   Red: Altan Networks México"
echo "   APN: altan.mx"
echo "   Usuario: No requerido"
echo "   Contraseña: No requerida"
echo ""

echo "1. 🔧 Configurando APN para BAIT..."
nmcli con modify "Fibocom-L850GL-WWAN" gsm.apn "altan.mx"
nmcli con modify "Fibocom-L850GL-WWAN" gsm.username ""
nmcli con modify "Fibocom-L850GL-WWAN" gsm.password ""
echo "   ✅ APN configurado: altan.mx"

echo ""
echo "2. 📋 Verificando configuración..."
echo "   Conexión: $(nmcli con show "Fibocom-L850GL-WWAN" | grep 'connection.id' | awk '{print $2}')"
echo "   APN: $(nmcli con show "Fibocom-L850GL-WWAN" | grep 'gsm.apn' | awk '{print $2}' | tr -d '"')"

echo ""
echo "3. 🔍 Estado de la SIM..."
echo "   Probando comunicación con SIM BAIT..."

# Verificar estado de SIM
sim_status=$(echo "AT+CPIN?" | sudo timeout 5 socat - /dev/wwan0at0,raw,echo=0 2>/dev/null | grep "+CPIN:" | tr -d '\r\n')
if [[ "$sim_status" == *"READY"* ]]; then
    echo "   ✅ SIM BAIT detectada y lista"
    
    # Obtener información de red
    echo ""
    echo "4. 📡 Información de red Altan..."
    
    # Información del operador
    operator=$(echo "AT+COPS?" | sudo timeout 5 socat - /dev/wwan0at0,raw,echo=0 2>/dev/null | grep "+COPS:" | cut -d'"' -f2)
    if [ -n "$operator" ]; then
        echo "   📡 Operador detectado: $operator"
    else
        echo "   ⚠️  Buscando red..."
        # Buscar redes disponibles
        echo "AT+COPS=?" | sudo timeout 15 socat - /dev/wwan0at0,raw,echo=0 2>/dev/null
    fi
    
    # Calidad de señal
    signal=$(echo "AT+CSQ" | sudo timeout 5 socat - /dev/wwan0at0,raw,echo=0 2>/dev/null | grep "+CSQ:" | cut -d' ' -f2 | cut -d',' -f1)
    if [ -n "$signal" ] && [ "$signal" != "99" ]; then
        signal_percent=$(( signal * 100 / 31 ))
        echo "   📶 Señal Altan: $signal/31 (${signal_percent}%)"
        
        if [ $signal_percent -gt 50 ]; then
            echo "   ✅ Señal buena para conexión"
        elif [ $signal_percent -gt 25 ]; then
            echo "   ⚠️  Señal regular, puede funcionar"
        else
            echo "   ❌ Señal débil, verificar ubicación/antenas"
        fi
    else
        echo "   ❌ No se detecta señal de red"
    fi
    
elif [[ "$sim_status" == *"SIM PIN"* ]]; then
    echo "   ⚠️  SIM BAIT requiere PIN: $sim_status"
    echo "      💡 Desactiva el PIN usando un teléfono antes de continuar"
elif [[ "$sim_status" == *"SIM PUK"* ]]; then
    echo "   ❌ SIM BAIT bloqueada (PUK): $sim_status"
    echo "      🚨 Contacta a BAIT para desbloquear"
else
    echo "   ❌ SIM no detectada: $sim_status"
    echo "      🔧 Verifica que la SIM esté insertada correctamente"
fi

echo ""
echo "=== CONFIGURACIÓN BAIT COMPLETADA ==="
echo ""
echo "🖥️  USAR INTERFAZ GRÁFICA:"
echo "1. Abre: Configuración → Red → Mobile Broadband"
echo "2. La conexión 'Fibocom-L850GL-WWAN' ya tiene APN: altan.mx"
echo "3. Activa la conexión desde la interfaz gráfica"
echo ""
echo "🛜 CONFIGURACIÓN MANUAL (alternativa):"
echo "   Nombre: BAIT"
echo "   APN: altan.mx"
echo "   Usuario: (dejar vacío)"
echo "   Contraseña: (dejar vacío)"
echo ""
echo "📞 SOPORTE BAIT:"
echo "   Teléfono: *6234 (desde BAIT) o 800-40-BAIT"
echo "   Web: www.bait.com.mx"
echo ""
echo "💡 NOTAS IMPORTANTES:"
echo "   • Red Altan usa tecnología Red Compartida"
echo "   • Cobertura principalmente en ciudades grandes"
echo "   • Velocidades hasta 50 Mbps en 4G+"