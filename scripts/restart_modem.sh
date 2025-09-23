#!/bin/bash

# Script de reinicio completo para Fibocom L850-GL
# Soluciona problemas de inicialización del módem

echo "🔄 REINICIO COMPLETO DEL MÓDEM FIBOCOM L850-GL"
echo "============================================="
echo

# Función para mostrar estado
show_status() {
    echo "📊 Estado actual:"
    echo "   Driver iosm: $(lsmod | grep iosm >/dev/null && echo '✅ Cargado' || echo '❌ No cargado')"
    echo "   Dispositivos: $(ls /dev/wwan* 2>/dev/null | wc -l) dispositivos"
    echo "   Comunicación: $(timeout 3s bash -c 'printf "ATI\r\n" | sudo socat - /dev/wwan0at0,raw' 2>/dev/null | grep -q "Built" && echo '✅ OK' || echo '❌ Falla')"
    echo
}

echo "1. Estado inicial"
echo "----------------"
show_status

echo "2. Deteniendo servicios relacionados"
echo "-----------------------------------"
echo "🛑 Deteniendo ModemManager..."
sudo systemctl stop ModemManager

echo "🛑 Deteniendo NetworkManager..."
sudo systemctl stop NetworkManager

echo "✅ Servicios detenidos"
echo

echo "3. Reiniciando driver iosm"
echo "-------------------------"
echo "🔄 Descargando driver iosm..."
sudo modprobe -r iosm

echo "⏳ Esperando 3 segundos..."
sleep 3

echo "🔄 Cargando driver iosm..."
sudo modprobe iosm

echo "⏳ Esperando estabilización (5 segundos)..."
sleep 5

echo "✅ Driver reiniciado"
echo

echo "4. Verificando dispositivos"
echo "-------------------------"
echo "📁 Dispositivos WWAN:"
ls -la /dev/wwan* 2>/dev/null || echo "❌ No se encontraron dispositivos"
echo

echo "5. Reiniciando servicios"
echo "-----------------------"
echo "🔄 Iniciando NetworkManager..."
sudo systemctl start NetworkManager

echo "🔄 Iniciando ModemManager..."
sudo systemctl start ModemManager

echo "⏳ Esperando inicialización (10 segundos)..."
sleep 10

echo "✅ Servicios reiniciados"
echo

echo "6. Estado final"
echo "--------------"
show_status

echo "7. Prueba de comunicación"
echo "-----------------------"
echo "📞 Probando comando ATI..."
timeout 5s bash -c 'printf "ATI\r\n" | sudo socat - /dev/wwan0at0,raw' 2>/dev/null | head -3

echo
echo "📞 Probando estado del SIM..."
timeout 5s bash -c 'printf "AT+CPIN?\r\n" | sudo socat - /dev/wwan0at0,raw' 2>/dev/null | head -3

echo
echo "✅ Reinicio completo terminado"
echo
echo "💡 Si el SIM sigue sin detectarse:"
echo "   1. Verificar inserción física del SIM"
echo "   2. Probar con otro SIM compatible"
echo "   3. Contactar soporte de BAIT/Altan"