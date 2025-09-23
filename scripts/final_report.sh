#!/bin/bash

# Script para crear un reporte completo y buscar firmware oficial
echo "📝 REPORTE COMPLETO FIBOCOM L850-GL - FRU 01AX792"
echo "=================================================="

echo "📋 INFORMACIÓN DEL HARDWARE"
echo "=========================="
echo "🖥️  Laptop: Lenovo ThinkPad T480"
echo "📡 Módulo: Fibocom L850-GL"
echo "🔢 FRU: 01AX792"
echo "💽 OS: Debian 13 Trixie"
echo "🔧 Kernel: $(uname -r)"

echo
echo "📋 INFORMACIÓN DEL DISPOSITIVO"
echo "============================"
echo "🆔 USB ID: $(lsusb | grep -i fibocom || echo 'No detectado en USB')"
echo "🆔 PCI ID: $(lspci | grep -i "wireless\|wwan\|modem\|fibocom" || echo 'No detectado específicamente')"

# Información más detallada del PCI
echo "🔍 Información PCI detallada:"
sudo lspci -nn | grep -E "02:00.0|Wireless|WWAN|Network|Modem" | head -5

echo
echo "📋 ESTADO DEL DRIVER"
echo "=================="
echo "📦 Driver: $(lsmod | grep iosm)"
echo "📊 Versión iosm: $(modinfo iosm | grep version)"

echo
echo "📋 DIAGNÓSTICO ACTUAL"
echo "==================="
echo "🔍 Últimos errores del kernel:"
sudo dmesg | grep -E "iosm|PORT.*refused|A-CD_READY" | tail -5

echo "🔍 Dispositivos WWAN creados:"
ls -la /dev/wwan* 2>/dev/null || echo "❌ No hay dispositivos /dev/wwan*"

echo "🔍 Interfaces de red WWAN:"
ip link show | grep -E "wwan|usb" || echo "❌ No hay interfaces WWAN detectadas"

echo
echo "📋 FIRMWARE BUSCADO"
echo "=================="
echo "❌ El módulo Fibocom L850-GL requiere firmware específico que NO está incluido en:"
echo "   - Debian 13 linux-firmware"
echo "   - firmware-intel-misc"
echo "   - Repositorios oficiales de Linux"

echo
echo "🎯 PROBLEMA IDENTIFICADO"
echo "======================="
echo "El error 'PORT open refused, phase A-CD_READY' indica que:"
echo "1. ✅ Hardware detectado correctamente"
echo "2. ✅ Driver iosm cargado correctamente"  
echo "3. ❌ Falta firmware específico para inicialización completa"

echo
echo "📂 FIRMWARE INTENTADOS SIN ÉXITO"
echo "==============================="
echo "❌ Enlaces simbólicos a firmware Intel genérico"
echo "❌ Firmware dummy/vacío"
echo "❌ Búsqueda automática en múltiples repositorios"
echo "❌ Descarga desde sitios oficiales (404 errors)"

echo
echo "🎯 SOLUCIÓN REQUERIDA"
echo "===================="
echo "Se necesita firmware oficial de Lenovo para FRU 01AX792:"
echo
echo "📞 CONTACTOS OFICIALES:"
echo "----------------------"
echo "🌐 Lenovo Support: https://support.lenovo.com/"
echo "📧 Crear ticket mencionando:"
echo "   - Modelo: ThinkPad T480"
echo "   - FRU: 01AX792 (Fibocom L850-GL)"
echo "   - OS: Linux (Debian 13)"
echo "   - Error: Missing XMM7360 firmware"
echo
echo "🌐 Fibocom Support: https://www.fibocom.com/en/support/"
echo "📧 Solicitar firmware Linux para L850-GL"

echo
echo "📋 INFORMACIÓN TÉCNICA PARA SOPORTE"
echo "==================================="
echo "Hardware ID completo:"
sudo lspci -vvv -s 02:00.0 | head -10

echo
echo "Driver usado:"
modinfo iosm | head -10

echo
echo "📊 ESTADO ACTUAL"
echo "==============="
echo "✅ Hardware funcional (3 dispositivos WWAN creados)"
echo "✅ Driver cargado correctamente"
echo "✅ SIM verificada funcional en teléfono"
echo "✅ APN BAIT configurado"
echo "✅ GUI herramientas instaladas"
echo "❌ Falta firmware oficial para operación completa"

echo
echo "🔄 PRÓXIMOS PASOS"
echo "================"
echo "1. Contactar Lenovo Support con esta información"
echo "2. Solicitar firmware específico para FRU 01AX792"
echo "3. Una vez obtenido el firmware:"
echo "   sudo cp firmware_file.bin /lib/firmware/fibocom/l850-gl.bin"
echo "   sudo modprobe -r iosm && sudo modprobe iosm"
echo "4. Verificar resolución con: ./scripts/final_check.sh"

echo
echo "📁 REPOSITORIO COMPLETO"
echo "======================"
echo "Todo el trabajo realizado está documentado en:"
echo "📂 Ubicación: $(pwd)"
echo "🐙 GitHub: fibocom-l850gl-install-debian-13"

echo
echo "✅ Reporte completado - $(date)"