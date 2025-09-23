#!/bin/bash

# Instalador del Sistema de Failover WiFi -> WWAN
# Configura el servicio automático y comandos de control

set -e

SCRIPT_DIR="/home/develop/Downloads/Fibocom"
SERVICE_FILE="$SCRIPT_DIR/config/wifi-wwan-failover.service"
SYSTEM_SERVICE="/etc/systemd/system/wifi-wwan-failover.service"
FAILOVER_SCRIPT="$SCRIPT_DIR/scripts/wifi_wwan_failover.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

colored_echo() {
    echo -e "${2}${1}${NC}"
}

install_failover_service() {
    colored_echo "🔧 Instalando servicio de failover..." "$BLUE"
    
    # Copiar servicio systemd
    sudo cp "$SERVICE_FILE" "$SYSTEM_SERVICE"
    
    # Recargar systemd
    sudo systemctl daemon-reload
    
    # Habilitar el servicio (pero no iniciar aún)
    sudo systemctl enable wifi-wwan-failover.service
    
    colored_echo "✅ Servicio instalado correctamente" "$GREEN"
}

uninstall_failover_service() {
    colored_echo "🗑️  Desinstalando servicio de failover..." "$YELLOW"
    
    # Detener servicio si está ejecutándose
    sudo systemctl stop wifi-wwan-failover.service 2>/dev/null || true
    
    # Deshabilitar servicio
    sudo systemctl disable wifi-wwan-failover.service 2>/dev/null || true
    
    # Remover archivo de servicio
    sudo rm -f "$SYSTEM_SERVICE"
    
    # Recargar systemd
    sudo systemctl daemon-reload
    
    colored_echo "✅ Servicio desinstalado correctamente" "$GREEN"
}

show_usage() {
    echo
    colored_echo "🔄 SISTEMA DE FAILOVER INTELIGENTE WiFi -> WWAN" "$BLUE"
    echo "================================================="
    echo
    colored_echo "🎯 FUNCIONALIDADES:" "$GREEN"
    echo "• Monitoreo automático de conectividad WiFi cada 30 segundos"
    echo "• Activación automática de WWAN cuando WiFi falla 3 veces seguidas"
    echo "• Desactivación automática de WWAN cuando WiFi se restaura"
    echo "• Logging completo de eventos"
    echo "• Control manual y automático"
    echo
    colored_echo "📋 COMANDOS DISPONIBLES:" "$BLUE"
    echo
    echo "🚀 CONTROL MANUAL:"
    echo "  $FAILOVER_SCRIPT start    # Iniciar monitoreo"
    echo "  $FAILOVER_SCRIPT stop     # Detener monitoreo"
    echo "  $FAILOVER_SCRIPT status   # Ver estado actual"
    echo "  $FAILOVER_SCRIPT test     # Probar conectividad"
    echo
    echo "⚙️  SERVICIO AUTOMÁTICO:"
    echo "  sudo systemctl start wifi-wwan-failover    # Iniciar servicio"
    echo "  sudo systemctl stop wifi-wwan-failover     # Detener servicio"
    echo "  sudo systemctl status wifi-wwan-failover   # Ver estado servicio"
    echo "  sudo systemctl enable wifi-wwan-failover   # Auto-iniciar en boot"
    echo "  sudo systemctl disable wifi-wwan-failover  # No auto-iniciar"
    echo
    colored_echo "📊 MONITOREO:" "$BLUE"
    echo "  tail -f $SCRIPT_DIR/logs/failover.log     # Ver logs en tiempo real"
    echo
    colored_echo "🔧 CONFIGURACIÓN:" "$BLUE"
    echo "  $0 install      # Instalar servicio automático"
    echo "  $0 uninstall    # Desinstalar servicio"
    echo "  $0 help         # Mostrar esta ayuda"
    echo
}

case "${1:-}" in
    "install")
        install_failover_service
        echo
        colored_echo "🎉 INSTALACIÓN COMPLETADA" "$GREEN"
        echo
        colored_echo "Para iniciar el failover automático:" "$BLUE"
        echo "  sudo systemctl start wifi-wwan-failover"
        echo
        colored_echo "Para que se inicie automáticamente en cada boot:" "$BLUE" 
        echo "  sudo systemctl enable wifi-wwan-failover"
        echo
        ;;
        
    "uninstall")
        uninstall_failover_service
        ;;
        
    "help"|"--help"|"-h"|"")
        show_usage
        ;;
        
    *)
        colored_echo "❌ Comando desconocido: $1" "$RED"
        echo
        show_usage
        exit 1
        ;;
esac