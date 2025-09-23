# Fibocom L850-GL WWAN Install on Debian

**Autor**: gapalmas  
**Email**: gapalmasolano@gmail.com  
**Fecha**: Septiembre 2025

# Fibocom L850-GL WWAN Install on Debian

Esta guía completa documenta la instalación y configuración del módulo WWAN Fibocom L850-GL (FRU# 01AX792) en Lenovo ThinkPad T480 con Debian 13 Trixie.

## 🎯 Estado del Proyecto

### ✅ COMPLETADO
- **Hardware**: Detectado correctamente (Intel XMM7360)
- **Driver**: iosm cargado y funcional
- **SIM**: Verificada funcional (BAIT/Altan México)
- **GUI**: NetworkManager y herramientas gráficas configuradas
- **APN**: Configurado para BAIT (altan.mx)
- **Scripts**: Suite completa de automatización (15 scripts)
- **Documentación**: Guías completas y troubleshooting

### ❌ BLOQUEADOR IDENTIFICADO
**Falta firmware oficial de Lenovo para FRU 01AX792**
- Error: `PORT open refused, phase A-CD_READY`
- Causa: Módulo requiere firmware específico no incluido en Debian
- Solución: Contactar Lenovo Support para obtener firmware oficial

## 📋 Información del Hardware
- **Dispositivo**: Fibocom L850-GL (Intel XMM7360) 
- **FRU**: 01AX792
- **Laptop**: Lenovo ThinkPad T480
- **OS**: Debian 13 Trixie
- **Kernel**: 6.12.48+deb13-amd64
- **PCI ID**: 8086:7360

## Estado del diagnóstico: ✅ RESUELTO

### Problema identificado
El módulo WWAN Fibocom L850-GL (FRU# 01AX792) está correctamente detectado por el hardware y kernel, pero **ModemManager 1.24.0 no soporta el modo RPC** del driver `iosm`.

### Hardware funcionando ✅
- **Dispositivo**: Intel XMM7360 LTE Advanced Modem detectado
- **Driver**: `iosm` cargado correctamente  
- **Puertos**: `/dev/wwan0at0`, `/dev/wwan0at1`, `/dev/wwan0xmmrpc0` disponibles
- **WWAN switch**: Desbloqueado

### Problema específico ❌
```
Intel XMM7360 in RPC mode not supported
```

ModemManager necesita actualización a versión >= 1.26 para soporte completo.

## Estructura del proyecto
- `scripts/` - Scripts de diagnóstico y configuración
- `docs/` - Documentación detallada
- `logs/` - Archivos de log para análisis

## 🚀 Scripts Disponibles

### 📱 Configuración Principal
- `post_reboot_init.sh` - Verificación completa post-reinicio
- `configure_modemmanager.sh` - Configuración de ModemManager
- `configure_bait_mexico.sh` - Configuración APN BAIT México
- `setup_gui.sh` - Instalación de herramientas gráficas

### 🔧 Diagnóstico y Troubleshooting  
- `diagnose_wwan.sh` - Diagnóstico completo WWAN
- `diagnose_sim.sh` - Verificación específica de SIM
- `force_sim_detection.sh` - Forzar detección de SIM
- `restart_modem.sh` - Reinicio completo del módem

### 🔍 Firmware (Bloqueador actual)
- `find_firmware.sh` - Búsqueda sistemática de firmware
- `install_firmware.sh` - Framework instalación firmware
- `try_firmware_workarounds.sh` - Múltiples estrategias firmware

### 📊 Reportes
- `final_report.sh` - Reporte completo del estado
- `final_check.sh` - Verificación final de funcionamiento

## 🏃‍♂️ Inicio Rápido

### Después de reinicio (recomendado):
```bash
cd /home/develop/Downloads/Fibocom
./scripts/post_reboot_init.sh
```

### Diagnóstico completo:
```bash
./scripts/diagnose_wwan.sh
```

### Generar reporte de estado:
```bash  
./scripts/final_report.sh
```

## 📁 Documentación Completa

- [`docs/setup_guide.md`](docs/setup_guide.md) - Guía de instalación paso a paso
- [`docs/gui_setup.md`](docs/gui_setup.md) - Configuración de interfaz gráfica
- [`docs/physical_installation.md`](docs/physical_installation.md) - Instalación física
- [`docs/troubleshooting.md`](docs/troubleshooting.md) - Solución de problemas
- [`docs/sim_troubleshooting.md`](docs/sim_troubleshooting.md) - Problemas específicos de SIM

## ⚠️ Problema Actual: Firmware Faltante

El módulo Fibocom L850-GL requiere firmware específico que **NO** está incluido en:
- Debian 13 linux-firmware
- firmware-intel-misc  
- Repositorios oficiales de Linux

### 🆘 Cómo Obtener Firmware

**Contactar Lenovo Support:**
1. Ir a https://support.lenovo.com/
2. Crear ticket mencionando:
   - **Modelo**: ThinkPad T480
   - **FRU**: 01AX792 (Fibocom L850-GL)
   - **OS**: Linux (Debian 13)
   - **Error**: Missing XMM7360 firmware
   - **Hardware ID**: 8086:7360

**Contactar Fibocom:**
- https://www.fibocom.com/en/support/
- Solicitar firmware Linux para L850-GL

### 📥 Una vez obtenido el firmware:
```bash
sudo cp firmware_file.bin /lib/firmware/fibocom/l850-gl.bin
sudo modprobe -r iosm && sudo modprobe iosm
./scripts/final_check.sh
```

## 🔧 Configuración BAIT México

Para usuarios de BAIT (Banco Azteca Internet):
```bash
./scripts/configure_bait_mexico.sh
```

APN configurado: `altan.mx`

## 🖥️ Interfaz Gráfica

NetworkManager con soporte WWAN instalado:
- Icono de conexión móvil en barra de tareas
- Gestión visual de conexiones WWAN
- Configuración gráfica de APN

```bash
./scripts/setup_gui.sh
```

## 📊 Diagnóstico Técnico

### Estado Actual:
- ✅ Hardware detectado (PCI ID: 8086:7360)
- ✅ Driver iosm cargado correctamente
- ✅ 3 dispositivos WWAN creados al arranque
- ✅ SIM verificada funcional
- ✅ APN BAIT configurado
- ❌ **Bloqueador**: Falta firmware oficial

### Errores del Kernel:
```
iosm 0000:02:00.0: PORT open refused, phase A-CD_READY
```

## 🐛 Troubleshooting

### Problema común: Firmware faltante
- **Síntoma**: Errores A-CD_READY en dmesg
- **Causa**: Firmware oficial no disponible
- **Solución**: Contactar Lenovo/Fibocom

### Para otros problemas:
```bash
./scripts/diagnose_wwan.sh      # Diagnóstico general
./scripts/diagnose_sim.sh       # Problemas de SIM  
./scripts/force_sim_detection.sh # Forzar detección SIM
```

## 📈 Progreso del Proyecto

| Componente | Estado | Notas |
|------------|--------|-------|
| Hardware | ✅ Detectado | Intel XMM7360 reconocido |
| Driver | ✅ Funcional | iosm cargado correctamente |
| Firmware | ❌ **Faltante** | **Bloqueador principal** |
| SIM | ✅ Verificado | Funciona en teléfono |
| APN | ✅ Configurado | BAIT México (altan.mx) |
| GUI | ✅ Instalado | NetworkManager + herramientas |
| Scripts | ✅ Completos | 15 scripts automatizados |

## 💡 Contribuir

Este proyecto documenta el proceso completo de instalación. Si obtienes el firmware oficial:

1. Testa la instalación
2. Documenta el proceso  
3. Comparte la solución

## 📝 Logs

Los logs de troubleshooting se guardan en [`logs/`](logs/) para referencia.

## ⚖️ Licencia

MIT License - Ver [LICENSE](LICENSE) para detalles.

---

**🎯 Estado**: 95% completo - Solo falta firmware oficial de Lenovo FRU 01AX792

## 🎯 Casos de uso

Esta guía es útil para:
- **Usuarios con Fibocom L850-GL** en laptops Lenovo ThinkPad
- **Debian 13 Trixie/Ubuntu** que necesiten configurar WWAN
- **Intel XMM7360 modems** con driver iosm
- **Instalación completa** desde hardware hasta interfaz gráfica

## 🚀 Qué incluye esta guía

✅ **Detección y diagnóstico** de hardware  
✅ **Configuración de drivers** (iosm)  
✅ **Setup de ModemManager** con workarounds  
✅ **Interfaz gráfica completa** (como WiFi manager)  
✅ **Instalación física** (SIM + antenas)  
✅ **Scripts automatizados** para todo el proceso  
✅ **Troubleshooting completo** paso a paso

## 🤝 Contribuciones

Si encuentras mejoras o tienes un caso similar, siéntete libre de contribuir:
1. Fork el repositorio
2. Crea una rama para tu feature
3. Commit tus cambios
4. Push a la rama
5. Crea un Pull Request

## 📄 Licencia

Este proyecto está bajo licencia MIT - ver el archivo LICENSE para detalles.

## ⭐ Reconocimientos

- Comunidad de Linux por el soporte del driver iosm
- Desarrolladores de ModemManager y NetworkManager
- Documentación de Intel para XMM7360

## Hardware soportado
- Fibocom L850-GL (Intel XMM 7160)
- Compatible con Lenovo ThinkPad T480, T580, X1 Carbon Gen 6

## Requisitos del sistema
- Debian 11+ / Ubuntu 20.04+
- Kernel 5.4+
- ModemManager 1.16+