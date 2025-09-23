#!/bin/bash

# Script para buscar y descargar firmware Fibocom L850-GL FRU 01AX792
# Búsqueda sistemática en múltiples fuentes oficiales

echo "🔍 BÚSQUEDA FIRMWARE FIBOCOM L850-GL (FRU: 01AX792)"
echo "=================================================="
echo

# URLs conocidas para firmware de WWAN Lenovo
LENOVO_URLS=(
    "https://download.lenovo.com/pccbbs/mobiles_bios/01ax792_firmware.bin"
    "https://download.lenovo.com/pccbbs/mobiles/l850gl_firmware.bin"
    "https://download.lenovo.com/pccbbs/mobiles/fibocom_l850gl.bin"
    "https://download.lenovo.com/pccbbs/options/01ax792_linux.zip"
    "https://download.lenovo.com/consumer/options/01ax792_firmware.zip"
)

# URLs de repositorios de firmware Linux
LINUX_FIRMWARE_URLS=(
    "https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/plain/fibocom/l850-gl.bin"
    "https://github.com/RPi-Distro/firmware-nonfree/raw/bullseye/intel/xmm7360.bin"
    "https://anduin.linuxfromscratch.org/sources/linux-firmware/intel/xmm7360.bin"
)

# URLs de comunidad y drivers de terceros
COMMUNITY_URLS=(
    "https://github.com/xmm7360/xmm7360-pci/releases/download/latest/firmware.bin"
    "https://github.com/abakasam/fibocom-l850-linux/raw/main/firmware/l850-gl.bin"
)

echo "1. BÚSQUEDA EN SITIOS OFICIALES DE LENOVO"
echo "========================================"
for url in "${LENOVO_URLS[@]}"; do
    echo "🔍 Intentando: $url"
    if wget --timeout=15 --tries=2 --user-agent="Mozilla/5.0 (X11; Linux x86_64)" "$url" -O /tmp/firmware_test.bin 2>/dev/null; then
        # Verificar que no sea HTML
        if file /tmp/firmware_test.bin | grep -q "HTML\|ASCII text"; then
            echo "   ❌ Archivo HTML/texto (no es firmware)"
            rm /tmp/firmware_test.bin
        else
            echo "   ✅ ¡Firmware encontrado!"
            sudo mkdir -p /lib/firmware/fibocom
            sudo cp /tmp/firmware_test.bin /lib/firmware/fibocom/l850-gl.bin
            sudo chmod 644 /lib/firmware/fibocom/l850-gl.bin
            echo "   📁 Instalado en: /lib/firmware/fibocom/l850-gl.bin"
            echo "   📊 Tamaño: $(ls -lh /tmp/firmware_test.bin | awk '{print $5}')"
            rm /tmp/firmware_test.bin
            FIRMWARE_FOUND=true
            break
        fi
    else
        echo "   ❌ No disponible"
    fi
done

if [[ "$FIRMWARE_FOUND" != "true" ]]; then
    echo
    echo "2. BÚSQUEDA EN REPOSITORIOS LINUX FIRMWARE"
    echo "========================================="
    for url in "${LINUX_FIRMWARE_URLS[@]}"; do
        echo "🔍 Intentando: $url"
        if wget --timeout=15 --tries=2 "$url" -O /tmp/firmware_test.bin 2>/dev/null; then
            if file /tmp/firmware_test.bin | grep -q "HTML\|ASCII text"; then
                echo "   ❌ Archivo HTML/texto (no es firmware)"
                rm /tmp/firmware_test.bin
            else
                echo "   ✅ ¡Firmware encontrado!"
                sudo mkdir -p /lib/firmware/fibocom
                sudo cp /tmp/firmware_test.bin /lib/firmware/fibocom/l850-gl.bin
                sudo chmod 644 /lib/firmware/fibocom/l850-gl.bin
                echo "   📁 Instalado en: /lib/firmware/fibocom/l850-gl.bin"
                echo "   📊 Tamaño: $(ls -lh /tmp/firmware_test.bin | awk '{print $5}')"
                rm /tmp/firmware_test.bin
                FIRMWARE_FOUND=true
                break
            fi
        else
            echo "   ❌ No disponible"
        fi
    done
fi

if [[ "$FIRMWARE_FOUND" != "true" ]]; then
    echo
    echo "3. BÚSQUEDA EN REPOSITORIOS DE COMUNIDAD"
    echo "======================================="
    for url in "${COMMUNITY_URLS[@]}"; do
        echo "🔍 Intentando: $url"
        if wget --timeout=15 --tries=2 "$url" -O /tmp/firmware_test.bin 2>/dev/null; then
            if file /tmp/firmware_test.bin | grep -q "HTML\|ASCII text"; then
                echo "   ❌ Archivo HTML/texto (no es firmware)"
                rm /tmp/firmware_test.bin
            else
                echo "   ✅ ¡Firmware encontrado!"
                sudo mkdir -p /lib/firmware/fibocom
                sudo cp /tmp/firmware_test.bin /lib/firmware/fibocom/l850-gl.bin
                sudo chmod 644 /lib/firmware/fibocom/l850-gl.bin
                echo "   📁 Instalado en: /lib/firmware/fibocom/l850-gl.bin"
                echo "   📊 Tamaño: $(ls -lh /tmp/firmware_test.bin | awk '{print $5}')"
                rm /tmp/firmware_test.bin
                FIRMWARE_FOUND=true
                break
            fi
        else
            echo "   ❌ No disponible"
        fi
    done
fi

echo
echo "=========================================="
if [[ "$FIRMWARE_FOUND" == "true" ]]; then
    echo "🎉 ¡FIRMWARE ENCONTRADO E INSTALADO!"
    echo "===================================="
    echo "📁 Ubicación: /lib/firmware/fibocom/l850-gl.bin"
    echo "📊 Información del archivo:"
    sudo ls -la /lib/firmware/fibocom/l850-gl.bin
    sudo file /lib/firmware/fibocom/l850-gl.bin
    echo
    echo "🔄 PROBANDO FIRMWARE..."
    echo "====================="
    echo "1. Reiniciando driver..."
    sudo modprobe -r iosm
    sleep 3
    sudo modprobe iosm
    sleep 10
    
    echo "2. Verificando errores..."
    ERROR_COUNT=$(sudo dmesg | tail -20 | grep -c "A-CD_READY")
    if [[ $ERROR_COUNT -eq 0 ]]; then
        echo "✅ ¡Sin errores A-CD_READY!"
        echo "3. Probando comunicación AT..."
        sleep 5
        COMM_TEST=$(timeout 5s bash -c 'printf "ATI\r\n" | sudo socat - /dev/wwan0at0,raw 2>/dev/null' | head -2)
        if [[ -n "$COMM_TEST" && "$COMM_TEST" != *"socat"* ]]; then
            echo "🎉 ¡COMUNICACIÓN EXITOSA!"
            echo "$COMM_TEST"
            echo
            echo "4. Probando detección de SIM..."
            SIM_TEST=$(timeout 5s bash -c 'printf "AT+CPIN?\r\n" | sudo socat - /dev/wwan0at0,raw 2>/dev/null' | head -1)
            echo "Estado SIM: $SIM_TEST"
            
            if [[ "$SIM_TEST" == *"READY"* ]]; then
                echo "🎊 ¡SIM DETECTADO! ¡WWAN COMPLETAMENTE FUNCIONAL!"
            else
                echo "⚠️  SIM aún no detectado, pero hardware funcionando"
            fi
        else
            echo "⚠️  Hardware inicializado pero comunicación aún falló"
        fi
    else
        echo "❌ Aún hay errores A-CD_READY ($ERROR_COUNT)"
        echo "💡 Puede ser firmware incorrecto para este modelo específico"
    fi
    
else
    echo "❌ NO SE ENCONTRÓ FIRMWARE AUTOMÁTICAMENTE"
    echo "========================================"
    echo
    echo "📋 OPCIONES MANUALES:"
    echo "1. Contactar Lenovo Support:"
    echo "   - Mencionar FRU: 01AX792"
    echo "   - Modelo: ThinkPad T480"
    echo "   - Solicitar: Firmware Linux para Fibocom L850-GL"
    echo
    echo "2. Sitios oficiales para verificar:"
    echo "   - https://support.lenovo.com/"
    echo "   - https://www.fibocom.com/en/support/downloads"
    echo "   - https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/"
    echo
    echo "3. Verificar en BIOS:"
    echo "   - Entrar a BIOS/UEFI"
    echo "   - Buscar 'WWAN' o 'Wireless'"
    echo "   - Verificar que esté habilitado"
    echo
fi

echo "✅ Búsqueda completada"