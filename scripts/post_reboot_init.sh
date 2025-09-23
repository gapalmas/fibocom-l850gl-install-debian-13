#!/bin/bash

# Script de arranque automático para verificar estado post-reinicio
# Para ser ejecutado después de reinicio completo del sistema

echo "� VERIFICACIÓN POST-REINICIO COMPLETO DEL SISTEMA"
echo "================================================"
echo "Fecha: $(date)"
echo "Usuario: $USER"
echo

# Crear log
LOG_FILE="/home/develop/Downloads/Fibocom/logs/post_reboot_$(date +%Y%m%d_%H%M%S).log"
mkdir -p "/home/develop/Downloads/Fibocom/logs"

# Función para log y mostrar
log_and_show() {
    echo "$1" | tee -a "$LOG_FILE"
}

log_and_show "🔍 Verificación inicial post-reinicio"
log_and_show "Fecha: $(date)"
log_and_show "Kernel: $(uname -r)"
log_and_show ""

# 1. Verificar hardware PCIe
log_and_show "1. Verificación hardware PCIe"
log_and_show "----------------------------"
PCIE_DEVICE=$(lspci | grep -i "XMM7360\|Fibocom" | head -1)
if [[ -n "$PCIE_DEVICE" ]]; then
    log_and_show "✅ Hardware detectado: $PCIE_DEVICE"
else
    log_and_show "❌ Hardware no detectado en PCIe"
    exit 1
fi
log_and_show ""

# 2. Verificar driver
log_and_show "2. Verificación driver iosm"
log_and_show "-------------------------"
if lsmod | grep -q iosm; then
    log_and_show "✅ Driver iosm cargado"
else
    log_and_show "🔄 Cargando driver iosm..."
    sudo modprobe iosm
    sleep 5
fi
log_and_show ""

# 3. Verificar dispositivos
log_and_show "3. Verificación dispositivos WWAN"
log_and_show "-------------------------------"
sleep 5  # Esperar creación de dispositivos
DEVICES=$(ls /dev/wwan* 2>/dev/null | wc -l)
log_and_show "Dispositivos encontrados: $DEVICES"
ls -la /dev/wwan* 2>/dev/null | while read line; do
    log_and_show "   $line"
done
log_and_show ""

# 4. Esperar estabilización
log_and_show "4. Esperando estabilización del módem"
log_and_show "-----------------------------------"
log_and_show "⏳ Esperando 15 segundos para estabilización..."
sleep 15

# 5. Intentar comunicación inicial
log_and_show "5. Verificación comunicación AT"
log_and_show "-----------------------------"
for attempt in 1 2 3; do
    log_and_show "Intento $attempt/3..."
    RESPONSE=$(timeout 5s bash -c 'printf "ATI\r\n" | sudo socat - /dev/wwan0at0,raw 2>/dev/null' | head -2)
    if [[ -n "$RESPONSE" && "$RESPONSE" != *"socat"* ]]; then
        log_and_show "✅ Comunicación establecida: $RESPONSE"
        break
    else
        log_and_show "❌ Sin respuesta, esperando..."
        sleep 5
    fi
done
log_and_show ""

# 6. Ejecutar detección forzada de SIM
log_and_show "6. Ejecutando detección forzada de SIM"
log_and_show "------------------------------------"
if [[ -f "/home/develop/Downloads/Fibocom/scripts/force_sim_detection.sh" ]]; then
    log_and_show "🔄 Ejecutando script de detección forzada..."
    cd /home/develop/Downloads/Fibocom
    ./scripts/force_sim_detection.sh 2>&1 | tee -a "$LOG_FILE"
else
    log_and_show "❌ Script de detección no encontrado"
fi
log_and_show ""

# 7. Configurar servicios
log_and_show "7. Iniciando servicios de red"
log_and_show "----------------------------"
log_and_show "🔄 Iniciando NetworkManager..."
sudo systemctl start NetworkManager
sleep 5

log_and_show "🔄 Iniciando ModemManager..."
sudo systemctl start ModemManager
sleep 10

log_and_show "✅ Servicios iniciados"
log_and_show ""

# 8. Verificación final
log_and_show "8. Verificación final"
log_and_show "------------------"
cd /home/develop/Downloads/Fibocom
./scripts/diagnose_sim.sh 2>&1 | tail -20 | tee -a "$LOG_FILE"

log_and_show ""
log_and_show "📝 Log completo guardado en: $LOG_FILE"
log_and_show "✅ Proceso post-reinicio completado"

# Mostrar resumen final
echo
echo "🎯 RESUMEN EJECUTIVO"
echo "==================="
echo "Hardware: $(lspci | grep -i XMM7360 >/dev/null && echo '✅ OK' || echo '❌ FALLO')"
echo "Driver: $(lsmod | grep -q iosm && echo '✅ OK' || echo '❌ FALLO')"
echo "Dispositivos: $(ls /dev/wwan* 2>/dev/null | wc -l) encontrados"
echo "Log: $LOG_FILE"
echo
echo "💡 Próximo paso: Revisar el log y verificar detección del SIM"