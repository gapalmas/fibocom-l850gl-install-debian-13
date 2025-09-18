# Troubleshooting Fibocom L850-GL en Lenovo ThinkPad T480

## Resumen del problema

El módulo WWAN Fibocom L850-GL (FRU# 01AX792) está físicamente instalado y siendo detectado por el kernel, pero ModemManager no puede crear un módem funcional debido a limitaciones en el soporte del modo RPC del driver `iosm`.

## Diagnóstico realizado

### ✅ Hardware detectado correctamente
- **Dispositivo PCI**: Intel Corporation XMM7360 LTE Advanced Modem (8086:7360)
- **Driver**: `iosm` (Intel Offload Service Manager) 
- **Puertos creados**: `/dev/wwan0at0`, `/dev/wwan0at1`, `/dev/wwan0xmmrpc0`
- **WWAN switch**: Desbloqueado (rfkill)

### ❌ Problema identificado
ModemManager 1.24.0 muestra el error:
```
couldn't create modem for device: Intel XMM7360 in RPC mode not supported
```

El driver `iosm` opera en modo RPC (Remote Procedure Call), que no está completamente soportado por la versión actual de ModemManager en Debian 13 Trixie.

## Soluciones disponibles

### Opción 1: Configuración avanzada de ModemManager
Ejecutar el script de configuración:
```bash
sudo ./scripts/configure_modemmanager.sh
```

Este script:
- Crea configuración personalizada para el dispositivo
- Establece reglas udev específicas
- Habilita logging verbose para debugging

### Opción 2: Configuración directa de bajo nivel
Ejecutar el script de configuración directa:
```bash
./scripts/configure_direct_wwan.sh
```

Este script:
- Prueba comunicación AT directa con el módem
- Obtiene información del dispositivo (IMEI, versión)
- Prepara para configuración manual con NetworkManager

### Opción 3: Actualización de ModemManager (Recomendado)
Para soporte completo, actualizar a ModemManager >= 1.26:

#### 3a. Desde Debian backports (si está disponible):
```bash
sudo apt update
sudo apt -t trixie-backports install modemmanager
```

#### 3b. Compilar desde fuente:
```bash
# Descargar ModemManager 1.26+ desde
# https://www.freedesktop.org/software/ModemManager/
wget https://gitlab.freedesktop.org/mobile-broadband/ModemManager/-/archive/main/ModemManager-main.tar.gz
```

## Estado actual de los componentes

| Componente | Estado | Versión | Notas |
|------------|--------|---------|-------|
| Hardware | ✅ OK | XMM7360 rev 01 | Detectado correctamente |
| Driver iosm | ✅ OK | Cargado | Puertos /dev/wwan* creados |
| ModemManager | ⚠️ Limitado | 1.24.0 | No soporta modo RPC completo |
| libqmi-utils | ✅ OK | 1.36.0 | Instalado |
| libmbim-utils | ✅ OK | 1.32.0 | Instalado |
| NetworkManager | ✅ OK | - | Esperando módem |

## Comandos útiles para monitoreo

### Verificar estado del hardware:
```bash
./scripts/diagnose_wwan.sh
```

### Monitorear logs de ModemManager:
```bash
sudo journalctl -u ModemManager -f
```

### Verificar dispositivos WWAN:
```bash
ls -la /dev/wwan*
mmcli -L
```

### Verificar comunicación AT:
```bash
sudo minicom -D /dev/wwan0at0
# O usar socat:
echo "AT" | sudo socat - /dev/wwan0at0,raw
```

## Próximos pasos recomendados

1. **Inmediato**: Probar Opción 2 (configuración directa) para verificar funcionalidad básica
2. **Corto plazo**: Implementar Opción 3 (actualizar ModemManager) para soporte completo
3. **Seguimiento**: Monitorear actualizaciones de Debian Trixie para ModemManager 1.26+

## Información técnica adicional

### Driver iosm
- **Propósito**: Maneja módems Intel XMM (7160, 7260, 7360, 7480, 7560)
- **Modo de operación**: RPC sobre PCIe
- **Soporte en kernel**: Disponible desde Linux 5.15+

### Alternativas de conectividad
Si ModemManager no funciona completamente:
- **wvdial**: Configuración PPP tradicional
- **qmi-network**: Herramientas QMI de bajo nivel
- **AT commands**: Control directo del módem

### Referencias
- [ModemManager GitLab](https://gitlab.freedesktop.org/mobile-broadband/ModemManager)
- [Driver iosm documentation](https://www.kernel.org/doc/html/latest/networking/device_drivers/wwan/iosm.html)
- [Intel XMM7360 specifications](https://www.intel.com/content/www/us/en/wireless-products/mobile-communications/xmm-7360-brief.html)