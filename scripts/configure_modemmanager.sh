#!/bin/bash

# Script para configurar ModemManager con soporte mejorado para Fibocom L850-GL
# Requiere permisos de administrador

set -e

echo "=== Configuración ModemManager para Fibocom L850-GL ==="

# Verificar que somos root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root (sudo)"
   exit 1
fi

echo "1. Parando ModemManager..."
systemctl stop ModemManager

echo "2. Creando configuración personalizada para el dispositivo..."

# Crear directorio de configuración si no existe
mkdir -p /etc/ModemManager

# Crear archivo de configuración para forzar el reconocimiento del dispositivo
cat > /etc/ModemManager/connection.d/fibocom-l850gl.conf << 'EOF'
# Configuración para Fibocom L850-GL (XMM7360)
[connection]
id=intel-xmm7360
vid=8086
pid=7360
# Forzar el uso del plugin Intel
plugin=Intel
# Configuración de puertos
port-type-hints=at:wwan0at0,at:wwan0at1,rpc:wwan0xmmrpc0
EOF

echo "3. Creando reglas udev personalizadas..."

# Crear reglas udev para los dispositivos WWAN
cat > /etc/udev/rules.d/77-mm-fibocom-port-types.rules << 'EOF'
# Fibocom L850-GL con driver iosm
SUBSYSTEM=="wwan", KERNEL=="wwan0at0", TAG+="systemd", ENV{SYSTEMD_WANTS}="ModemManager.service"
SUBSYSTEM=="wwan", KERNEL=="wwan0at1", TAG+="systemd", ENV{SYSTEMD_WANTS}="ModemManager.service"
SUBSYSTEM=="wwan", KERNEL=="wwan0xmmrpc0", TAG+="systemd", ENV{SYSTEMD_WANTS}="ModemManager.service"

# Asegurar permisos correctos
SUBSYSTEM=="wwan", KERNEL=="wwan0*", MODE="0660", GROUP="dialout"
EOF

echo "4. Recargando reglas udev..."
udevadm control --reload-rules
udevadm trigger

echo "5. Configurando ModemManager para debug verbose..."

# Crear override para systemd con logging verbose
mkdir -p /etc/systemd/system/ModemManager.service.d/
cat > /etc/systemd/system/ModemManager.service.d/override.conf << 'EOF'
[Service]
# Logging verbose para debugging
ExecStart=
ExecStart=/usr/sbin/ModemManager --debug
EOF

echo "6. Recargando configuración de systemd..."
systemctl daemon-reload

echo "7. Iniciando ModemManager con nueva configuración..."
systemctl start ModemManager

echo "8. Esperando inicialización..."
sleep 5

echo "9. Verificando estado..."
systemctl status ModemManager --no-pager

echo ""
echo "=== Configuración completada ==="
echo "Ejecute los siguientes comandos para verificar:"
echo "  mmcli -L"
echo "  journalctl -u ModemManager -f"
echo ""
echo "Si el problema persiste, es posible que necesite:"
echo "1. Actualizar ModemManager a una versión >= 1.26"
echo "2. O usar herramientas de bajo nivel como qmi-network"