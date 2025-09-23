#!/bin/bash

# Script para configurar y activar la conexión WWAN
# Fibocom L850-GL con BAIT/Altan

set -e

echo "🔧 Configurando conexión WWAN BAIT..."

# 1. Ejecutar inicialización RPC
echo "📡 Inicializando módem..."
cd /home/develop/Downloads/Fibocom/third_party/xmm7360-pci/rpc
sudo timeout 120s python3 open_xdatachannel.py || echo "RPC completado"

# 2. Activar interfaz
echo "🔗 Activando interfaz wwan0..."
sudo ip link set wwan0 up 2>/dev/null || true

# 3. Verificar IP
echo "📋 Configuración actual:"
ip addr show wwan0 | grep "inet "

# 4. Configurar rutas si es necesario
echo "🛣️  Configurando rutas..."
# Añadir ruta por defecto si no hay WiFi
if ! ip route | grep -q "default.*wlp3s0"; then
    sudo ip route add default dev wwan0 2>/dev/null || echo "Ruta ya existe"
fi

# 5. Probar conectividad
echo "🌐 Probando conectividad..."
ping -c 2 -I wwan0 8.8.8.8

echo "✅ Conexión WWAN configurada correctamente!"
echo "💡 IP: $(ip addr show wwan0 | grep 'inet ' | awk '{print $2}')"
echo "💡 Para usar en aplicaciones: sudo route add default dev wwan0"