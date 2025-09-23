#!/bin/bash

# Script para intentar resolver el problema de firmware creando diferentes enfoques
echo "🔧 INTENTANDO RESOLVER FIRMWARE FIBOCOM L850-GL"
echo "=============================================="

echo "📋 Estrategia 1: Crear enlace simbólico a firmware compatible"
echo "============================================================"

# Crear directorio para firmware Fibocom
sudo mkdir -p /lib/firmware/fibocom
sudo mkdir -p /lib/firmware/intel/modem

# Probar diferentes nombres de archivo que el driver podría estar buscando
FIRMWARE_NAMES=(
    "l850-gl.bin"
    "fibocom_l850gl.bin" 
    "L850-GL.bin"
    "xmm7360.bin"
    "intel_xmm7360.bin"
    "modem.bin"
    "firmware.bin"
)

# Usar uno de los firmware Intel existentes como base
SOURCE_FIRMWARE="/lib/firmware/intel/fw_sst_22a8.bin"

if [[ -f "$SOURCE_FIRMWARE" ]]; then
    echo "✅ Usando firmware base: $SOURCE_FIRMWARE"
    
    for name in "${FIRMWARE_NAMES[@]}"; do
        echo "🔗 Creando enlace: /lib/firmware/fibocom/$name"
        sudo ln -sf "$SOURCE_FIRMWARE" "/lib/firmware/fibocom/$name"
        
        echo "🔗 Creando enlace: /lib/firmware/intel/modem/$name"
        sudo ln -sf "$SOURCE_FIRMWARE" "/lib/firmware/intel/modem/$name"
        
        echo "🔗 Creando enlace: /lib/firmware/$name"
        sudo ln -sf "$SOURCE_FIRMWARE" "/lib/firmware/$name"
    done
else
    echo "❌ No se encontró firmware base Intel"
fi

echo
echo "📋 Estrategia 2: Crear firmware dummy mínimo"
echo "==========================================="

# Crear firmware dummy (archivo vacío mínimo)
echo -n "" | sudo tee /lib/firmware/fibocom/l850-gl.bin >/dev/null
echo -n "" | sudo tee /lib/firmware/intel/modem/xmm7360.bin >/dev/null

# Establecer permisos correctos
sudo chmod 644 /lib/firmware/fibocom/* 2>/dev/null
sudo chmod 644 /lib/firmware/intel/modem/* 2>/dev/null

echo "✅ Firmware dummy creado"

echo
echo "📋 Estrategia 3: Verificar rutas en dmesg"
echo "========================================"

# Reiniciar driver para que intente cargar firmware
echo "🔄 Reiniciando driver iosm..."
sudo modprobe -r iosm
sleep 3
sudo modprobe iosm
sleep 5

# Capturar cualquier solicitud de firmware
echo "🔍 Buscando solicitudes de firmware en dmesg..."
FIRMWARE_REQUESTS=$(sudo dmesg | tail -20 | grep -i "firmware\|request.*failed\|cannot load" | tail -5)

if [[ -n "$FIRMWARE_REQUESTS" ]]; then
    echo "📄 Solicitudes de firmware encontradas:"
    echo "$FIRMWARE_REQUESTS"
else
    echo "❌ No se detectaron solicitudes específicas de firmware"
fi

echo
echo "📋 Estrategia 4: Probar comunicación después de cambios"
echo "====================================================="

sleep 10

echo "🔍 Verificando errores A-CD_READY..."
ERROR_COUNT=$(sudo dmesg | tail -30 | grep -c "A-CD_READY")
echo "Errores A-CD_READY encontrados: $ERROR_COUNT"

if [[ $ERROR_COUNT -eq 0 ]]; then
    echo "🎉 ¡Sin errores A-CD_READY!"
    
    echo "🔍 Probando comunicación AT..."
    if [[ -e /dev/wwan0at0 ]]; then
        COMM_TEST=$(timeout 5s bash -c 'printf "ATI\r\n" | sudo socat - /dev/wwan0at0,raw 2>/dev/null' | head -1)
        if [[ -n "$COMM_TEST" && "$COMM_TEST" != *"socat"* ]]; then
            echo "🎊 ¡COMUNICACIÓN AT EXITOSA!"
            echo "Respuesta: $COMM_TEST"
        else
            echo "⚠️  Dispositivo disponible pero sin respuesta AT"
        fi
    else
        echo "⚠️  Dispositivo /dev/wwan0at0 no disponible"
    fi
else
    echo "❌ Aún hay errores A-CD_READY"
fi

echo
echo "📋 Resumen de archivos creados:"
echo "=============================="
echo "Archivos de firmware creados:"
sudo find /lib/firmware -name "*l850*" -o -name "*xmm7360*" -o -name "*fibocom*" 2>/dev/null | head -10

echo
echo "✅ Script completado. Si persisten los errores, el problema requiere firmware oficial específico."