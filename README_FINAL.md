# 📱 Fibocom L850-GL WWAN - Instalación Exitosa en Debian 13

## ✅ Estado Final: COMPLETAMENTE FUNCIONAL

### 📋 Información del Sistema
- **Laptop**: Lenovo ThinkPad T480
- **Módulo**: Fibocom L850-GL (FRU: 01AX792)
- **OS**: Debian 13 Trixie
- **Kernel**: 6.12.48+deb13-amd64
- **Operador**: BAIT/Altan (MNC 140, MCC 334)
- **Firmware**: 18500.5001.09.01.20.72

### 🎯 Configuración Final Óptima
- **WiFi doméstico**: Conexión principal
- **WWAN móvil**: Disponible como backup/viajes
- **IP móvil**: 196.10.234.214/32
- **APN**: altan.mx
- **DNS**: 10.5.100.100, 10.1.101.94

## 🚀 CÓMO ACTIVAR LA CONEXIÓN WWAN

### 🔄 Método 1: Failover Automático (NUEVO - Recomendado)
**Sistema inteligente que cambia automáticamente de WiFi a WWAN cuando hay fallas:**
```bash
# Instalar servicio automático
/home/develop/Downloads/Fibocom/scripts/install_failover.sh install
sudo systemctl start wifi-wwan-failover
sudo systemctl enable wifi-wwan-failover  # Auto-iniciar en boot

# Monitorear en tiempo real
tail -f /home/develop/Downloads/Fibocom/logs/failover.log
```

### Método 2: Script Manual
```bash
/home/develop/Downloads/Fibocom/scripts/setup_wwan_connection.sh
```

### Método 3: Control Avanzado
```bash
cd /home/develop/Downloads/Fibocom/third_party/xmm7360-pci/rpc
sudo python3 open_xdatachannel.py
sudo ip link set wwan0 up
```

### Método 4: Acceso Directo del Escritorio
- Hacer doble clic en: `BAIT-Mobile-Connection` (creado en el escritorio)

## 📊 Verificar Estado de la Conexión
```bash
# Ver interfaz activa
ip addr show wwan0

# Ver conexiones disponibles  
nmcli connection show

# Probar conectividad
ping -c 4 -I wwan0 8.8.8.8
```

## 🔧 Componentes del Sistema

### ✅ Funcional
- **Driver**: `iosm` (kernel nativo)
- **Hardware**: Intel XMM7360 detectado
- **RPC**: Herramientas Python personalizadas
- **Antenas**: Conectadas (MAIN + AUX)
- **SIM**: "Mi SIM" - totalmente operativo
- **Internet**: 4G/LTE con baja latencia (~140ms)
- **🆕 Failover Automático**: WiFi ↔ WWAN inteligente

### ❌ Deshabilitado/No Funcional
- **ModemManager GUI**: Desinstalado (no compatible)
- **gnome-control-center**: No muestra APN (limitación técnica)
- **Comandos AT**: No disponibles (módem opera solo por RPC)

## 📁 Estructura de Archivos Importantes

```
/home/develop/Downloads/Fibocom/
├── scripts/
│   ├── wifi_wwan_failover.sh             # 🆕 FAILOVER AUTOMÁTICO
│   ├── install_failover.sh               # 🆕 Instalador failover
│   ├── setup_wwan_connection.sh          # ⭐ SCRIPT MANUAL
│   ├── diagnose_wwan.sh                 # Diagnóstico
│   ├── final_check.sh                   # Verificación
│   └── restart_modem.sh                 # Reinicio de módem
├── third_party/xmm7360-pci/rpc/
│   └── open_xdatachannel.py             # ⭐ CONEXIÓN MANUAL
├── config/
│   └── wifi-wwan-failover.service       # 🆕 Servicio systemd
├── docs/
│   ├── setup_guide.md
│   ├── troubleshooting.md
│   └── sim_troubleshooting.md
└── logs/                                # Logs de instalación y failover
```

## 🎮 Control de la Conexión

### 🔄 Failover Automático (Nuevo)
```bash
# Iniciar failover automático
sudo systemctl start wifi-wwan-failover

# Ver estado del sistema
/home/develop/Downloads/Fibocom/scripts/wifi_wwan_failover.sh status

# Monitorear logs en tiempo real
tail -f /home/develop/Downloads/Fibocom/logs/failover.log
```

### 📋 Control Manual
```bash
# Activar WWAN manualmente
/home/develop/Downloads/Fibocom/scripts/setup_wwan_connection.sh

# Desactivar WWAN
sudo ip link set wwan0 down

# Reiniciar Módem (si hay problemas)
/home/develop/Downloads/Fibocom/scripts/restart_modem.sh
```

## 💡 Tips de Uso

1. **🆕 Failover Automático**: Configúralo una vez y olvídalo - cambio automático WiFi ↔ WWAN
2. **Uso Normal**: WiFi como conexión principal, WWAN como backup inteligente
3. **Viajes/Emergencias**: El sistema detecta fallas de WiFi y cambia automáticamente
4. **Ahorro de Batería**: WWAN solo se activa cuando es necesario
5. **Troubleshooting**: Consultar logs en `/home/develop/Downloads/Fibocom/logs/`

## 🔄 Proceso de Conexión Automático

El script principal (`setup_wwan_connection.sh`) ejecuta:
1. Inicialización RPC del módem
2. Configuración automática de APN (altan.mx)
3. Obtención de IP dinámica
4. Configuración de DNS
5. Activación de interfaz wwan0
6. Verificación de conectividad

## 🆘 Solución de Problemas

Si la conexión falla:
1. Verificar que las antenas estén conectadas
2. Ejecutar: `/home/develop/Downloads/Fibocom/scripts/restart_modem.sh`
3. Verificar cobertura BAIT en la zona
4. Consultar logs en: `/home/develop/Downloads/Fibocom/logs/`

## ✅ Instalación Completada Exitosamente

**Fecha de finalización**: 23 de Septiembre, 2025
**Estado**: Totalmente funcional con internet móvil 4G/LTE
**Latencia promedio**: ~140ms
**Pérdida de paquetes**: 0%

---

### 📞 Soporte
Para problemas técnicos, consultar:
- `docs/troubleshooting.md`
- `docs/sim_troubleshooting.md`
- Logs en directorio `logs/`