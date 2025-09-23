#!/bin/bash

# Sistema de Failover Inteligente WiFi -> WWAN
# Monitorea conectividad WiFi y activa WWAN automáticamente cuando falla

set -e

# Configuración
WIFI_INTERFACE="wlp3s0"
WWAN_INTERFACE="wwan0" 
SCRIPT_DIR="/home/develop/Downloads/Fibocom"
RPC_SCRIPT="$SCRIPT_DIR/third_party/xmm7360-pci/rpc/open_xdatachannel.py"
LOG_FILE="$SCRIPT_DIR/logs/failover.log"
PID_FILE="/tmp/wifi_failover.pid"

# Servidores para test de conectividad
TEST_SERVERS=("8.8.8.8" "1.1.1.1" "208.67.222.222")
WIFI_TEST_TIMEOUT=5
WWAN_ACTIVATION_TIMEOUT=120

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

colored_echo() {
    echo -e "${2}${1}${NC}"
}

check_wifi_connectivity() {
    local wifi_working=false
    
    # Verificar que la interfaz WiFi esté UP
    if ! ip link show "$WIFI_INTERFACE" | grep -q "state UP"; then
        log "WiFi interface $WIFI_INTERFACE is DOWN"
        return 1
    fi
    
    # Test de conectividad a múltiples servidores
    for server in "${TEST_SERVERS[@]}"; do
        if ping -I "$WIFI_INTERFACE" -c 2 -W "$WIFI_TEST_TIMEOUT" "$server" &>/dev/null; then
            wifi_working=true
            break
        fi
    done
    
    if $wifi_working; then
        log "WiFi connectivity: OK"
        return 0
    else
        log "WiFi connectivity: FAILED"
        return 1
    fi
}

check_wwan_status() {
    if ip link show "$WWAN_INTERFACE" &>/dev/null; then
        if ip link show "$WWAN_INTERFACE" | grep -q "state UP"; then
            if ip addr show "$WWAN_INTERFACE" | grep -q "inet "; then
                return 0  # WWAN is UP and has IP
            fi
        fi
    fi
    return 1  # WWAN is DOWN or no IP
}

activate_wwan() {
    colored_echo "🔄 Activando WWAN como backup..." "$YELLOW"
    log "Activating WWAN failover"
    
    cd "$(dirname "$RPC_SCRIPT")"
    
    # Ejecutar script RPC con timeout
    if timeout "$WWAN_ACTIVATION_TIMEOUT" sudo python3 "$(basename "$RPC_SCRIPT")" &>/dev/null; then
        sleep 3
        sudo ip link set "$WWAN_INTERFACE" up &>/dev/null || true
        
        # Verificar que se activó correctamente
        if check_wwan_status; then
            # Configurar ruta con menor prioridad que WiFi
            sudo ip route add default dev "$WWAN_INTERFACE" metric 600 &>/dev/null || true
            colored_echo "✅ WWAN activado exitosamente" "$GREEN"
            log "WWAN activated successfully"
            return 0
        fi
    fi
    
    colored_echo "❌ Fallo al activar WWAN" "$RED"
    log "Failed to activate WWAN"
    return 1
}

deactivate_wwan() {
    colored_echo "🔽 Desactivando WWAN (WiFi restaurado)" "$BLUE"
    log "Deactivating WWAN (WiFi restored)"
    
    # Remover rutas WWAN
    sudo ip route del default dev "$WWAN_INTERFACE" &>/dev/null || true
    
    # Bajar interfaz WWAN (opcional - comentado para mantener disponible)
    # sudo ip link set "$WWAN_INTERFACE" down &>/dev/null || true
    
    colored_echo "✅ WWAN en standby" "$GREEN"
    log "WWAN set to standby"
}

monitor_loop() {
    local wifi_down_count=0
    local wifi_up_count=0
    local wwan_active=false
    local max_failures=3  # Fallos consecutivos antes de activar WWAN
    local max_recovery=2  # Éxitos consecutivos para desactivar WWAN
    
    colored_echo "🚀 Iniciando monitoreo inteligente WiFi -> WWAN" "$GREEN"
    log "Failover monitor started"
    
    while true; do
        if check_wifi_connectivity; then
            wifi_up_count=$((wifi_up_count + 1))
            wifi_down_count=0
            
            # Si WiFi está OK y WWAN está activo, considerar desactivar WWAN
            if $wwan_active && [ $wifi_up_count -ge $max_recovery ]; then
                deactivate_wwan
                wwan_active=false
                wifi_up_count=0
            fi
            
            if ! $wwan_active; then
                colored_echo "✅ WiFi: OK (Principal)" "$GREEN"
            else
                colored_echo "✅ WiFi: OK | WWAN: Backup activo" "$BLUE"
            fi
            
        else
            wifi_down_count=$((wifi_down_count + 1))
            wifi_up_count=0
            
            colored_echo "⚠️  WiFi: FALLA #$wifi_down_count" "$RED"
            
            # Activar WWAN después de múltiples fallas
            if [ $wifi_down_count -ge $max_failures ] && ! $wwan_active; then
                if activate_wwan; then
                    wwan_active=true
                    wifi_down_count=0  # Reset counter
                fi
            fi
            
            if $wwan_active; then
                colored_echo "🚀 WWAN: Activo como backup" "$YELLOW"
            fi
        fi
        
        sleep 30  # Check every 30 seconds
    done
}

show_status() {
    echo
    colored_echo "📊 ESTADO ACTUAL DEL SISTEMA" "$BLUE"
    echo "=================================="
    
    # WiFi Status
    if check_wifi_connectivity; then
        colored_echo "WiFi ($WIFI_INTERFACE): ✅ CONECTADO" "$GREEN"
    else
        colored_echo "WiFi ($WIFI_INTERFACE): ❌ SIN CONEXIÓN" "$RED"
    fi
    
    # WWAN Status  
    if check_wwan_status; then
        local wwan_ip=$(ip addr show "$WWAN_INTERFACE" | grep 'inet ' | awk '{print $2}')
        colored_echo "WWAN ($WWAN_INTERFACE): ✅ ACTIVO ($wwan_ip)" "$GREEN"
    else
        colored_echo "WWAN ($WWAN_INTERFACE): ⭕ INACTIVO" "$YELLOW"
    fi
    
    echo
    colored_echo "📋 Rutas activas:" "$BLUE"
    ip route | grep default
    echo
}

stop_monitor() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            rm -f "$PID_FILE"
            colored_echo "🛑 Monitor detenido" "$YELLOW"
            log "Failover monitor stopped"
        else
            colored_echo "⚠️  Monitor no estaba ejecutándose" "$YELLOW"
            rm -f "$PID_FILE"
        fi
    else
        colored_echo "ℹ️  Monitor no está ejecutándose" "$BLUE"
    fi
}

case "${1:-}" in
    "start")
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            colored_echo "⚠️  Monitor ya está ejecutándose (PID: $(cat "$PID_FILE"))" "$YELLOW"
            exit 1
        fi
        
        # Crear directorio de logs si no existe
        mkdir -p "$(dirname "$LOG_FILE")"
        
        # Iniciar monitor en background
        monitor_loop &
        echo $! > "$PID_FILE"
        colored_echo "🚀 Monitor iniciado en background (PID: $!)" "$GREEN"
        ;;
        
    "stop")
        stop_monitor
        ;;
        
    "status")
        show_status
        if [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
            colored_echo "🟢 Monitor: EJECUTÁNDOSE (PID: $(cat "$PID_FILE"))" "$GREEN"
        else
            colored_echo "🔴 Monitor: DETENIDO" "$RED"
        fi
        ;;
        
    "test")
        colored_echo "🧪 Probando conectividad..." "$BLUE"
        show_status
        ;;
        
    *)
        echo "🔄 Sistema de Failover Inteligente WiFi -> WWAN"
        echo "=============================================="
        echo
        echo "Uso: $0 {start|stop|status|test}"
        echo
        echo "Comandos:"
        echo "  start   - Iniciar monitoreo automático"
        echo "  stop    - Detener monitoreo"
        echo "  status  - Ver estado actual"
        echo "  test    - Probar conectividad"
        echo
        echo "El sistema monitoreará WiFi cada 30 segundos y activará"
        echo "WWAN automáticamente cuando WiFi falle por más de 3 intentos."
        exit 1
        ;;
esac