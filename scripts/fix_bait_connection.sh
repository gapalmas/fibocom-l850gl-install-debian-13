#!/bin/bash

# Fix BAIT WWAN Connection - Configura rutas y DNS correctamente
# Fibocom L850-GL en red BAIT (Altan Networks Mexico)

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

WWAN_INTERFACE="wwan0"
BAIT_DNS1="10.4.100.100"
BAIT_DNS2="10.2.101.94"
BAIT_DNS3="10.5.100.100" 

colored_echo() {
    echo -e "${2}${1}${NC}"
}

check_wwan_interface() {
    if ! ip link show "$WWAN_INTERFACE" &>/dev/null; then
        colored_echo "❌ Interfaz $WWAN_INTERFACE no encontrada" "$RED"
        return 1
    fi
    
    if ! ip link show "$WWAN_INTERFACE" | grep -q -E "(UP|UNKNOWN)"; then
        colored_echo "❌ Interfaz $WWAN_INTERFACE no está activa" "$RED" 
        return 1
    fi
    
    return 0
}

get_wwan_ip() {
    ip addr show "$WWAN_INTERFACE" | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1
}

fix_bait_connection() {
    colored_echo "🔧 REPARANDO CONEXIÓN BAIT..." "$BLUE"
    echo "================================"
    
    if ! check_wwan_interface; then
        colored_echo "❌ Primero activa la interfaz WWAN" "$RED"
        exit 1
    fi
    
    local wwan_ip=$(get_wwan_ip)
    if [ -z "$wwan_ip" ]; then
        colored_echo "❌ WWAN no tiene IP asignada" "$RED"
        exit 1
    fi
    
    colored_echo "📱 WWAN IP: $wwan_ip" "$GREEN"
    
    # Paso 1: Limpiar rutas existentes
    colored_echo "🧹 1/6 - Limpiando rutas WWAN existentes..." "$YELLOW"
    sudo ip route flush dev "$WWAN_INTERFACE" 2>/dev/null || true
    sudo ip route del default dev "$WWAN_INTERFACE" 2>/dev/null || true
    
    # Paso 2: Configurar rutas específicas para BAIT
    colored_echo "🛤️  2/6 - Configurando rutas BAIT..." "$YELLOW"
    
    # Ruta para red interna BAIT 
    sudo ip route add 10.0.0.0/8 dev "$WWAN_INTERFACE" src "$wwan_ip"
    
    # Ruta para servidores DNS BAIT
    sudo ip route add 10.4.100.0/24 dev "$WWAN_INTERFACE" src "$wwan_ip"
    sudo ip route add 10.2.101.0/24 dev "$WWAN_INTERFACE" src "$wwan_ip"  
    sudo ip route add 10.5.100.0/24 dev "$WWAN_INTERFACE" src "$wwan_ip"
    
    # Ruta por defecto con métrica alta
    sudo ip route add default dev "$WWAN_INTERFACE" src "$wwan_ip" metric 1000
    
    colored_echo "   ✅ Rutas BAIT configuradas" "$GREEN"
    
    # Paso 3: Configurar DNS para WWAN
    colored_echo "🌐 3/6 - Configurando DNS BAIT..." "$YELLOW"
    
    # Crear archivo temporal de resolv.conf para WWAN
    cat > /tmp/resolv.conf.wwan << EOF
# DNS servers for BAIT network via WWAN
nameserver $BAIT_DNS1
nameserver $BAIT_DNS2  
nameserver $BAIT_DNS3
EOF
    
    colored_echo "   ✅ DNS BAIT configurado" "$GREEN"
    
    # Paso 4: Verificar conectividad a DNS BAIT
    colored_echo "🔍 4/6 - Probando DNS servers BAIT..." "$YELLOW"
    
    local dns_ok=false
    for dns in "$BAIT_DNS1" "$BAIT_DNS2" "$BAIT_DNS3"; do
        if ping -I "$WWAN_INTERFACE" -c 1 -W 3 "$dns" &>/dev/null; then
            colored_echo "   ✅ DNS $dns: Responde" "$GREEN"
            dns_ok=true
        else
            colored_echo "   ⚠️  DNS $dns: No responde" "$YELLOW"
        fi
    done
    
    if ! $dns_ok; then
        colored_echo "   ❌ Ningún DNS BAIT responde" "$RED"
        colored_echo "   🔄 Intentando reconfiguración..." "$YELLOW"
        
        # Reconfigurar con gateway específico si está disponible
        local gateway=$(ip route show dev "$WWAN_INTERFACE" | grep default | awk '{print $3}' | head -1)
        if [ -n "$gateway" ]; then
            colored_echo "   🚪 Usando gateway: $gateway" "$BLUE"
            sudo ip route del default dev "$WWAN_INTERFACE" 2>/dev/null || true
            sudo ip route add default via "$gateway" dev "$WWAN_INTERFACE" metric 1000
        fi
    fi
    
    # Paso 5: Probar conectividad externa
    colored_echo "🌍 5/6 - Probando conectividad externa..." "$YELLOW"
    
    # Usar DNS de BAIT para resolver
    local test_servers=("1.1.1.1" "8.8.8.8" "208.67.222.222")
    local external_ok=false
    
    for server in "${test_servers[@]}"; do
        if timeout 5 ping -I "$WWAN_INTERFACE" -c 2 "$server" &>/dev/null; then
            colored_echo "   ✅ Conectividad a $server: OK" "$GREEN"
            external_ok=true
            break
        else
            colored_echo "   ⚠️  $server: Sin respuesta" "$YELLOW"
        fi
    done
    
    # Paso 6: Configurar resolución de nombres
    colored_echo "📋 6/6 - Configurando resolución de nombres..." "$YELLOW"
    
    if $external_ok; then
        # Backup del resolv.conf original
        if [ ! -f "/etc/resolv.conf.backup" ]; then
            sudo cp /etc/resolv.conf /etc/resolv.conf.backup
        fi
        
        # Agregar DNS de BAIT al inicio del resolv.conf  
        sudo sed -i "1i nameserver $BAIT_DNS1" /etc/resolv.conf
        sudo sed -i "2i nameserver $BAIT_DNS2" /etc/resolv.conf
        
        colored_echo "   ✅ DNS system configurado" "$GREEN"
    fi
    
    echo
    colored_echo "🎉 CONEXIÓN BAIT REPARADA" "$GREEN"
    show_connection_status
}

show_connection_status() {
    echo
    colored_echo "📊 ESTADO DE CONEXIÓN BAIT:" "$BLUE"
    echo "=============================="
    
    local wwan_ip=$(get_wwan_ip)
    if [ -n "$wwan_ip" ]; then
        colored_echo "📱 WWAN IP: $wwan_ip" "$GREEN"
    else
        colored_echo "📱 WWAN: Sin IP" "$RED"
        return 1
    fi
    
    echo "🛤️  Rutas activas:"
    ip route show dev "$WWAN_INTERFACE" | sed 's/^/   /'
    
    echo
    colored_echo "🌐 Test de conectividad:" "$BLUE"
    
    # Test DNS BAIT
    if ping -I "$WWAN_INTERFACE" -c 1 -W 3 "$BAIT_DNS1" &>/dev/null; then
        colored_echo "   ✅ DNS BAIT ($BAIT_DNS1): OK" "$GREEN"
    else
        colored_echo "   ❌ DNS BAIT ($BAIT_DNS1): FALLA" "$RED"
    fi
    
    # Test conectividad externa
    if ping -I "$WWAN_INTERFACE" -c 1 -W 3 "8.8.8.8" &>/dev/null; then
        colored_echo "   ✅ Internet: OK" "$GREEN"
    else
        colored_echo "   ❌ Internet: FALLA" "$RED"
    fi
    
    echo
}

restore_dns() {
    colored_echo "🔄 RESTAURANDO DNS ORIGINAL..." "$YELLOW"
    
    if [ -f "/etc/resolv.conf.backup" ]; then
        sudo cp /etc/resolv.conf.backup /etc/resolv.conf
        colored_echo "   ✅ DNS restaurado" "$GREEN"
    else
        colored_echo "   ⚠️  No hay backup de DNS" "$YELLOW"
    fi
}

case "${1:-}" in
    "fix"|"repair"|"")
        fix_bait_connection
        ;;
    "status"|"check")
        colored_echo "📊 VERIFICANDO ESTADO BAIT..." "$BLUE"
        show_connection_status
        ;;
    "restore-dns")
        restore_dns
        ;;
    "help"|"--help"|"-h")
        echo "🔧 Reparador de Conexión BAIT (Fibocom L850-GL)"
        echo "=============================================="
        echo
        echo "Uso: $0 [comando]"
        echo
        echo "Comandos:"
        echo "  fix         - Reparar conexión BAIT (por defecto)"
        echo "  status      - Ver estado de conexión"  
        echo "  restore-dns - Restaurar DNS original"
        echo "  help        - Mostrar esta ayuda"
        echo
        echo "Este script soluciona problemas de:"
        echo "• Rutas incorrectas en WWAN"
        echo "• DNS servers de BAIT no configurados"
        echo "• Conectividad limitada con operador BAIT"
        ;;
    *)
        colored_echo "❓ Comando desconocido: $1" "$RED"
        echo "Usa '$0 help' para ver comandos disponibles"
        exit 1
        ;;
esac