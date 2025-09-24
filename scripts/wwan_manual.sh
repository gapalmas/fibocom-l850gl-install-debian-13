#!/bin/bash

# Control Manual WWAN + BAIT (Fibocom L850-GL)
# Activar/Desactivar conexión WAN sin afectar WiFi

set -e

# Configuración
WWAN_INTERFACE="wwan0"
WIFI_INTERFACE="wlp3s0"
SCRIPT_DIR="/home/develop/Downloads/Fibocom"
RPC_SCRIPT="$SCRIPT_DIR/third_party/xmm7360-pci/rpc/open_xdatachannel.py"

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

colored_echo() {
    echo -e "${2}${1}${NC}"
}

show_header() {
    echo
    colored_echo "📱 CONTROL MANUAL WWAN + BAIT (Fibocom L850-GL)" "$CYAN"
    echo "=================================================="
}

check_wwan_status() {
    if ip link show "$WWAN_INTERFACE" &>/dev/null; then
        if ip link show "$WWAN_INTERFACE" | grep -q -E "(state UP|state UNKNOWN)"; then
            if ip addr show "$WWAN_INTERFACE" | grep -q "inet "; then
                return 0  # WWAN UP con IP
            fi
        fi
    fi
    return 1  # WWAN DOWN o sin IP
}

activate_wwan() {
    show_header
    colored_echo "🚀 ACTIVANDO WAN + CONEXIÓN BAIT..." "$YELLOW"
    echo
    
    # Paso 1: Activar canal RPC  
    colored_echo "📡 1/4 - Activando canal de datos RPC..." "$BLUE"
    cd "$(dirname "$RPC_SCRIPT")"
    
    # Usar timeout para evitar que se cuelgue
    if timeout 60 sudo python3 "$(basename "$RPC_SCRIPT")" 2>/dev/null; then
        colored_echo "   ✅ Canal RPC activado (parcial - errores esperados al final)" "$GREEN"
    else
        colored_echo "   ⚠️  RPC completado con errores al final (normal)" "$YELLOW"
        colored_echo "   📋 Verificando si la interfaz está disponible..." "$BLUE"
    fi
    
    sleep 2
    
    # Paso 2: Levantar interfaz
    colored_echo "🔗 2/4 - Levantando interfaz WWAN..." "$BLUE"
    if sudo ip link set "$WWAN_INTERFACE" up; then
        colored_echo "   ✅ Interfaz $WWAN_INTERFACE UP" "$GREEN"
    else
        colored_echo "   ❌ Error levantando interfaz" "$RED"
        return 1
    fi
    
    sleep 3
    
    # Paso 3: Verificar IP asignada por RPC
    colored_echo "🌐 3/4 - Verificando IP asignada por RPC..." "$BLUE"
    local ip_check=0
    for i in {1..10}; do
        if ip addr show "$WWAN_INTERFACE" | grep -q "inet "; then
            local wwan_ip=$(ip addr show "$WWAN_INTERFACE" | grep 'inet ' | awk '{print $2}')
            colored_echo "   ✅ IP obtenida via RPC: $wwan_ip" "$GREEN"
            ip_check=1
            break
        fi
        sleep 1
    done
    
    if [ $ip_check -eq 0 ]; then
        colored_echo "   ❌ No se pudo obtener IP" "$RED"
        return 1
    fi
    
    sleep 2

    # Paso extra: Configurar DNS público para WWAN
    colored_echo "🧩 Configurando DNS público (8.8.8.8) para WWAN..." "$BLUE"
    echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf >/dev/null

    # Paso 4: Verificar conexión
    colored_echo "🔍 4/4 - Verificando conexión..." "$BLUE"
    if check_wwan_status; then
        local wwan_ip=$(ip addr show "$WWAN_INTERFACE" | grep 'inet ' | awk '{print $2}')
        colored_echo "   ✅ WWAN conectado: $wwan_ip" "$GREEN"

        # Test conectividad
        if ping -I "$WWAN_INTERFACE" -c 3 8.8.8.8 &>/dev/null; then
            colored_echo "   ✅ Conectividad BAIT: OK" "$GREEN"
        else
            colored_echo "   ⚠️  Conectividad limitada" "$YELLOW"
        fi
    else
        colored_echo "   ❌ Conexión fallida" "$RED"
        return 1
    fi

    echo
    colored_echo "🎉 WAN + BAIT ACTIVADO EXITOSAMENTE" "$GREEN"
    show_connection_info
}

deactivate_wwan() {
    show_header
    colored_echo "🛑 DESACTIVANDO WAN + CONEXIÓN BAIT..." "$YELLOW"
    echo
    
    # Paso 1: Liberar IP DHCP
    colored_echo "💾 1/4 - Liberando IP DHCP..." "$BLUE"
    sudo dhclient -r "$WWAN_INTERFACE" 2>/dev/null || colored_echo "   ⚠️  Sin IP DHCP activa" "$YELLOW"
    colored_echo "   ✅ IP liberada" "$GREEN"

    # Paso 2: Remover rutas
    colored_echo "🛤️  2/4 - Removiendo rutas WWAN..." "$BLUE"
    sudo ip route del default dev "$WWAN_INTERFACE" 2>/dev/null || colored_echo "   ⚠️  Sin ruta por defecto" "$YELLOW"
    sudo ip route flush dev "$WWAN_INTERFACE" 2>/dev/null || true
    colored_echo "   ✅ Rutas removidas" "$GREEN"

    # Paso 3: Bajar interfaz
    colored_echo "⬇️  3/4 - Bajando interfaz WWAN..." "$BLUE"
    if sudo ip link set "$WWAN_INTERFACE" down; then
        colored_echo "   ✅ Interfaz $WWAN_INTERFACE DOWN" "$GREEN"
    else
        colored_echo "   ⚠️  Error bajando interfaz" "$YELLOW"
    fi

    # Paso 4: Restaurar DNS del WiFi si está activo
    colored_echo "🧩 Restaurando DNS del WiFi si está conectado..." "$BLUE"
    if ip link show "$WIFI_INTERFACE" | grep -q "state UP"; then
        local wifi_dns=$(nmcli dev show "$WIFI_INTERFACE" | grep 'IP4.DNS' | awk '{print $2}' | head -n1)
        if [ -n "$wifi_dns" ]; then
            echo "nameserver $wifi_dns" | sudo tee /etc/resolv.conf >/dev/null
            colored_echo "   ✅ DNS restaurado: $wifi_dns" "$GREEN"
        else
            colored_echo "   ⚠️  No se detectó DNS en WiFi, dejando DNS actual" "$YELLOW"
        fi
    else
        colored_echo "   ⚠️  WiFi no activo, DNS no restaurado" "$YELLOW"
    fi

    echo
    colored_echo "✅ WAN + BAIT DESACTIVADO EXITOSAMENTE" "$GREEN"
    show_connection_info
}

show_status() {
    show_header
    colored_echo "📊 ESTADO ACTUAL DEL SISTEMA" "$BLUE"
    echo "================================"
    echo
    
    # Estado WiFi
    if ip link show "$WIFI_INTERFACE" | grep -q "state UP" && ping -I "$WIFI_INTERFACE" -c 1 8.8.8.8 &>/dev/null; then
        local wifi_ip=$(ip addr show "$WIFI_INTERFACE" | grep 'inet ' | awk '{print $2}')
        colored_echo "📶 WiFi ($WIFI_INTERFACE): ✅ CONECTADO ($wifi_ip)" "$GREEN"
    else
        colored_echo "📶 WiFi ($WIFI_INTERFACE): ❌ DESCONECTADO" "$RED"
    fi
    
    # Estado WWAN
    if check_wwan_status; then
        local wwan_ip=$(ip addr show "$WWAN_INTERFACE" | grep 'inet ' | awk '{print $2}')
        colored_echo "📱 WWAN ($WWAN_INTERFACE): ✅ CONECTADO ($wwan_ip)" "$GREEN"
        
        # Test conectividad WWAN
        if ping -I "$WWAN_INTERFACE" -c 1 8.8.8.8 &>/dev/null; then
            colored_echo "🌐 Conectividad BAIT: ✅ FUNCIONANDO" "$GREEN"
        else
            colored_echo "🌐 Conectividad BAIT: ❌ SIN INTERNET" "$RED"
        fi
    else
        colored_echo "📱 WWAN ($WWAN_INTERFACE): ⭕ DESCONECTADO" "$YELLOW"
    fi
    
    echo
    show_connection_info
}

show_connection_info() {
    colored_echo "📋 INFORMACIÓN DE CONEXIONES:" "$CYAN"
    echo "=============================="
    
    # Mostrar IPs activas
    echo "🔗 Interfaces con IP:"
    ip addr show | grep -E "(wlp3s0|wwan0)" | grep -E "(UP|inet)" | sed 's/^/   /'
    
    echo
    echo "🛤️  Rutas por defecto:"
    ip route show | grep default | sed 's/^/   /' || echo "   Sin rutas configuradas"
    
    echo
}

test_connectivity() {
    show_header
    colored_echo "🧪 PROBANDO CONECTIVIDAD..." "$BLUE"
    echo
    
    # Test WiFi
    colored_echo "📶 Probando WiFi..." "$BLUE"
    if ping -I "$WIFI_INTERFACE" -c 3 8.8.8.8 &>/dev/null; then
        colored_echo "   ✅ WiFi: Conectividad OK" "$GREEN"
    else
        colored_echo "   ❌ WiFi: Sin conectividad" "$RED"
    fi
    
    # Test WWAN
    if check_wwan_status; then
        colored_echo "📱 Probando WWAN..." "$BLUE"
        if ping -I "$WWAN_INTERFACE" -c 3 8.8.8.8 &>/dev/null; then
            colored_echo "   ✅ WWAN: Conectividad OK" "$GREEN"
        else
            colored_echo "   ❌ WWAN: Sin conectividad" "$RED"
        fi
    else
        colored_echo "📱 WWAN: No disponible para test" "$YELLOW"
    fi
    
    echo
    show_connection_info
}

show_help() {
    show_header
    echo
    echo "Uso: $0 {on|off|status|test|help}"
    echo
    colored_echo "COMANDOS DISPONIBLES:" "$CYAN"
    echo "===================="
    echo "  on      - 🚀 Activar WAN + conexión BAIT"
    echo "  off     - 🛑 Desactivar WAN + conexión BAIT"  
    echo "  status  - 📊 Ver estado actual del sistema"
    echo "  test    - 🧪 Probar conectividad WiFi y WWAN"
    echo "  help    - ❓ Mostrar esta ayuda"
    echo
    colored_echo "EJEMPLOS:" "$CYAN"
    echo "========="
    echo "  $0 on       # Conectar a BAIT"
    echo "  $0 off      # Desconectar de BAIT"
    echo "  $0 status   # Ver qué está conectado"
    echo
    colored_echo "NOTAS:" "$CYAN"
    echo "======"
    echo "• WiFi no se ve afectado por estos comandos"
    echo "• Requiere permisos sudo para configurar red"
    echo "• BAIT es el operador (MCC 334, MNC 140)"
    echo
}

# Verificar que el script RPC existe
if [ ! -f "$RPC_SCRIPT" ]; then
    colored_echo "❌ Error: No se encuentra el script RPC en $RPC_SCRIPT" "$RED"
    exit 1
fi

# Procesar comandos
case "${1:-}" in
    "on"|"start"|"connect")
        activate_wwan
        ;;
    "off"|"stop"|"disconnect") 
        deactivate_wwan
        ;;
    "status"|"info")
        show_status
        ;;
    "test"|"check")
        test_connectivity
        ;;
    "help"|"--help"|"-h")
        show_help
        ;;
    *)
        show_help
        exit 1
        ;;
esac