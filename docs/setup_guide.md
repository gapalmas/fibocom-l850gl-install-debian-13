# Configuración paso a paso para Fibocom L850-GL

## Prerrequisitos verificados ✅

Tu sistema está bien configurado con:
- Hardware detectado: Intel XMM7360 LTE Advanced Modem
- Driver `iosm` cargado correctamente
- Puertos WWAN creados: `/dev/wwan0at0`, `/dev/wwan0at1`, `/dev/wwan0xmmrpc0`
- ModemManager instalado (versión 1.24.0)
- Librerías QMI/MBIM disponibles

## Problema identificado

ModemManager no puede crear el módem porque la versión 1.24.0 no soporta completamente el modo RPC del driver `iosm` para el XMM7360.

Error específico:
```
Intel XMM7360 in RPC mode not supported
```

## Soluciones recomendadas (en orden de preferencia)

### 1. Probar configuración directa (Más rápido)

```bash
cd /home/develop/Downloads/Fibocom
./scripts/configure_direct_wwan.sh
```

Este script verificará si puedes comunicarte directamente con el módem usando comandos AT.

### 2. Intentar configuración avanzada de ModemManager

```bash
cd /home/develop/Downloads/Fibocom
sudo ./scripts/configure_modemmanager.sh
```

Esto creará configuraciones personalizadas para forzar el reconocimiento del dispositivo.

### 3. Verificar funcionalidad con herramientas de bajo nivel

Si los scripts anteriores no funcionan, prueba comunicación directa:

```bash
# Verificar que el módem responde
sudo apt install socat
echo "AT" | sudo socat - /dev/wwan0at0,raw,echo=0
echo "ATI" | sudo socat - /dev/wwan0at0,raw,echo=0  # Info del dispositivo
echo "AT+CGSN" | sudo socat - /dev/wwan0at0,raw,echo=0  # IMEI
```

### 4. Actualizar ModemManager (Solución definitiva)

Para soporte completo del modo RPC, necesitas ModemManager >= 1.26:

```bash
# Verificar si hay backports disponibles
sudo apt update
sudo apt -t trixie-backports search modemmanager

# Si está disponible:
sudo apt -t trixie-backports install modemmanager

# Verificar nueva versión
mmcli --version
```

## Configuración manual con NetworkManager (Si AT funciona)

Si los comandos AT funcionan pero ModemManager no detecta el módem:

```bash
# Crear conexión GSM manualmente
nmcli con add type gsm ifname '*' con-name 'Fibocom-WWAN' \
    gsm.apn "tu-apn-aqui" \
    gsm.username "usuario" \
    gsm.password "contraseña"

# Activar conexión
nmcli con up 'Fibocom-WWAN'
```

## Monitoreo y diagnóstico continuo

Usa el script de diagnóstico para verificar el estado:

```bash
./scripts/diagnose_wwan.sh > logs/diagnostic_$(date +%Y%m%d_%H%M%S).log
```

## Qué esperar

### Si todo funciona correctamente:
- `mmcli -L` mostrará el módem detectado
- NetworkManager listará el dispositivo WWAN
- Podrás configurar conexiones móviles en la interfaz gráfica

### Si solo funciona AT pero no ModemManager:
- Podrás obtener información del módem (IMEI, señal, etc.)
- Necesitarás configuración manual de red
- Funcionalidad limitada hasta actualizar ModemManager

## Próximos pasos

1. **Ejecuta** `./scripts/configure_direct_wwan.sh`
2. **Verifica** si obtienes respuestas AT del módem  
3. **Si funciona**: Configura conexión manual con NetworkManager
4. **Si no funciona**: Reporta el problema (puede ser firmware/SIM)
5. **Para el futuro**: Actualiza a ModemManager 1.26+ cuando esté disponible

## Información de tu operadora

Para configurar la conexión necesitarás:
- **APN** (Access Point Name) de tu operadora
- **Usuario/contraseña** (si es requerido)
- **Tipo de autenticación** (normalmente automático)

Operadoras comunes:
- **Movistar MX**: APN `internet.movistar.mx`
- **Telcel**: APN `internet.itelcel.com` 
- **AT&T**: APN `broadband`
- **Verizon**: APN `vzwinternet`