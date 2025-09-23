#!/bin/bash

# Script para descargar e instalar firmware oficial Fibocom L850-GL
# Soluciona el problema "PORT open refused, phase A-CD_READY"

echo "🔧 INSTALACIÓN FIRMWARE FIBOCOM L850-GL"
echo "======================================"
echo

# Verificar problema actual
echo "1. Verificando problema actual"
echo "-----------------------------"
PHASE_ERROR=$(sudo dmesg | grep "A-CD_READY" | tail -1)
if [[ -n "$PHASE_ERROR" ]]; then
    echo "✅ Problema confirmado: $PHASE_ERROR"
    echo "💡 Esto indica falta de firmware específico"
else
    echo "⚠️  No se detecta el error A-CD_READY"
fi
echo

# Crear directorio para firmware
echo "2. Preparando directorios"
echo "------------------------"
FIRMWARE_DIR="/lib/firmware/fibocom"
echo "📁 Creando $FIRMWARE_DIR..."
sudo mkdir -p "$FIRMWARE_DIR"

# Descargar firmware (enlaces típicos - pueden cambiar)
echo "3. Descargando firmware oficial"
echo "------------------------------"

# Lista de URLs conocidas para firmware L850-GL
FIRMWARE_URLS=(
    "https://www.fibocom.com/upload/file/l850-gl-firmware.bin"
    "https://downloads.fibocom.com/l850gl/firmware/latest.bin"
    "https://support.lenovo.com/downloads/DS548439/l850gl-firmware.bin"
)

echo "🔍 Buscando firmware en sitios oficiales..."
for url in "${FIRMWARE_URLS[@]}"; do
    echo "   Intentando: $url"
    if wget --timeout=10 --tries=1 "$url" -O /tmp/l850_firmware.bin 2>/dev/null; then
        echo "   ✅ Descarga exitosa"
        sudo mv /tmp/l850_firmware.bin "$FIRMWARE_DIR/l850-gl.bin"
        break
    else
        echo "   ❌ No disponible"
    fi
done

# Verificar si se descargó firmware
if [[ -f "$FIRMWARE_DIR/l850-gl.bin" ]]; then
    echo "✅ Firmware instalado en $FIRMWARE_DIR/l850-gl.bin"
else
    echo "❌ No se pudo descargar firmware automáticamente"
    echo
    echo "📋 DESCARGA MANUAL REQUERIDA:"
    echo "   1. Visitar: https://www.fibocom.com/en/support/downloads"
    echo "   2. Buscar: L850-GL Firmware"
    echo "   3. Descargar archivo .bin"
    echo "   4. Copiar a: $FIRMWARE_DIR/"
    echo "   5. Ejecutar: sudo modprobe -r iosm && sudo modprobe iosm"
    echo
fi

# Información adicional de firmware
echo "4. Información de firmware"
echo "-------------------------"
echo "📋 Ubicaciones típicas de firmware:"
echo "   • Fibocom oficial: https://www.fibocom.com/en/support/downloads"
echo "   • Lenovo support: https://support.lenovo.com/ (buscar FRU 01AX792)"
echo "   • Linux firmware repo: https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git"
echo

echo "📋 Archivos de firmware típicos para L850-GL:"
echo "   • l850-gl.bin (firmware principal)"
echo "   • xmm7360.bin (firmware genérico Intel)"
echo "   • fibocom_l850gl_*.bin (variantes específicas)"
echo

# Script de verificación post-instalación
echo "5. Creando script de verificación"
echo "--------------------------------"
cat > /tmp/verify_firmware.sh << 'EOF'
#!/bin/bash
echo "🔍 Verificando firmware Fibocom L850-GL..."

# Reiniciar driver
echo "🔄 Reiniciando driver..."
sudo modprobe -r iosm
sleep 3
sudo modprobe iosm
sleep 10

# Verificar mensajes de error
echo "📋 Verificando errores..."
ERROR_COUNT=$(sudo dmesg | grep -c "A-CD_READY")
if [[ $ERROR_COUNT -eq 0 ]]; then
    echo "✅ ¡Sin errores A-CD_READY!"
    echo "🔍 Probando comunicación..."
    printf "ATI\r\n" | sudo socat - /dev/wwan0at0,raw | head -3
else
    echo "❌ Aún hay errores A-CD_READY ($ERROR_COUNT)"
    echo "💡 Firmware puede estar incorrecto o faltante"
fi
EOF

chmod +x /tmp/verify_firmware.sh
echo "✅ Script de verificación creado: /tmp/verify_firmware.sh"
echo

echo "✅ Proceso completado"
echo
echo "💡 Próximos pasos:"
echo "   1. Si se descargó firmware: ejecutar /tmp/verify_firmware.sh"
echo "   2. Si no: descargar manualmente desde sitio oficial"
echo "   3. Después de instalar firmware: reiniciar driver"
echo "   4. Verificar que desaparezcan los errores A-CD_READY"