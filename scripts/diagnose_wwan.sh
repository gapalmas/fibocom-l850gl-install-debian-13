#!/bin/bash

# Diagnóstico completo del módulo WWAN Fibocom L850-GL
# Para Lenovo ThinkPad T480 con Debian 13 Trixie

echo "=== Diagnóstico WWAN Fibocom L850-GL ==="
echo "Fecha: $(date)"
echo "Sistema: $(uname -a)"
echo ""

echo "1. Detección de hardware PCI:"
echo "=============================="
lspci | grep -i "wwan\|wireless\|modem\|cellular\|broadband\|xmm"
echo ""

echo "2. Información detallada del dispositivo:"
echo "========================================="
lspci -vnn | grep -A 10 -B 2 "XMM7360"
echo ""

echo "3. Módulos del kernel cargados:"
echo "==============================="
lsmod | grep -E "(iosm|wwan|cdc|qmi|mbim)"
echo ""

echo "4. Dispositivos WWAN en /dev:"
echo "============================="
ls -la /dev/wwan* 2>/dev/null || echo "No se encontraron dispositivos /dev/wwan*"
echo ""

echo "5. Estado del driver en dmesg:"
echo "=============================="
sudo dmesg | grep -E "(iosm|wwan|xmm7360)" | tail -10
echo ""

echo "6. Estado de ModemManager:"
echo "========================="
systemctl status ModemManager --no-pager -l
echo ""

echo "7. Versión de ModemManager:"
echo "=========================="
mmcli --version
echo ""

echo "8. Módems detectados por ModemManager:"
echo "====================================="
mmcli -L
echo ""

echo "9. Logs recientes de ModemManager:"
echo "================================="
sudo journalctl -u ModemManager --since "1 hour ago" | tail -15
echo ""

echo "10. Estado del switch WWAN (rfkill):"
echo "==================================="
rfkill list wwan
echo ""

echo "11. Información de red NetworkManager:"
echo "===================================="
nmcli device status | grep -E "(wwan|gsm)"
echo ""

echo "12. Paquetes instalados relacionados:"
echo "===================================="
dpkg -l | grep -E "(libqmi|mbim|wwan|modemmanager)"
echo ""

echo "=== Fin del diagnóstico ==="