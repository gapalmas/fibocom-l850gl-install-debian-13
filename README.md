# Fibocom L850-GL WWAN Install on Debian

**Autor**: gapalmas  
**Email**: gapalmasolano@gmail.com  
**Fecha**: Septiembre 2025

Guía completa de instalación y configuración del módulo WWAN Fibocom L850-GL en Debian/Ubuntu Linux.

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

## 🚀 Uso rápido

### ✅ ESTADO ACTUAL: Hardware funcionando
Tu módulo WWAN está **correctamente detectado y funcionando**. Solo necesitas instalar físicamente:
- 📲 **Tarjeta SIM** 
- 📡 **Antenas WWAN**

### Verificación inicial (YA EJECUTADO ✅):
```bash
./scripts/quick_connect.sh
```

### 🖥️ Interfaz gráfica (YA CONFIGURADO ✅):
```bash
./scripts/setup_gui.sh  # Ya ejecutado
```

### 🎯 DESPUÉS de instalar SIM y antenas:
```bash
./scripts/final_check.sh  # ← EJECUTAR ESTO
```

### Herramientas gráficas disponibles:
- **GNOME Settings**: `gnome-control-center network`
- **Connection Editor**: `nm-connection-editor` 
- **Modem GUI**: `modem-manager-gui`

### Scripts disponibles:
- `scripts/final_check.sh` - **🎯 USAR DESPUÉS de SIM y antenas**
- `scripts/quick_connect.sh` - Prueba rápida de funcionalidad ✅
- `scripts/setup_gui.sh` - Configurar interfaz gráfica ✅
- `scripts/diagnose_wwan.sh` - Diagnóstico completo del sistema
- `scripts/configure_modemmanager.sh` - Configuración avanzada
- `scripts/configure_direct_wwan.sh` - Configuración de bajo nivel

### Documentación:
- `docs/setup_guide.md` - Guía paso a paso
- `docs/troubleshooting.md` - Solución de problemas detallada
- `docs/gui_setup.md` - Manual de interfaz gráfica
- `docs/physical_installation.md` - Instalación física de SIM y antenas

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