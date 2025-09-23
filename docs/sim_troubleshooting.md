# Verificación Física del SIM y Hardware - Fibocom L850-GL

## 🔍 DIAGNÓSTICO ACTUAL

Según las pruebas realizadas:

### ✅ Funcionando Correctamente
- **Hardware**: Fibocom L850-GL detectado en PCIe (02:00.0)
- **Driver**: iosm cargado y funcional
- **Firmware**: Version 18500.5001.09.01.20.72
- **IMEI**: 015550004912595 (válido)
- **Comunicación AT**: Comandos básicos responden

### ❌ Problemas Identificados
- **SIM no detectado**: Todos los comandos de SIM fallan (AT+CPIN?, AT+CCID, AT+CIMI)
- **Sin registro de red**: +CREG: 0,0 (no registrado)
- **Sin señal**: +CSQ: 99,99 (sin señal válida)
- **Estado del módem**: Fase A-CD_READY (esperando inicialización completa)

## 🔧 PASOS DE VERIFICACIÓN FÍSICA

### 1. Verificación del SIM
1. **Apagar completamente** la laptop
2. **Retirar la batería** si es posible
3. **Localizar la bandeja del SIM**:
   - En ThinkPad T480, suele estar en el lado derecho
   - Buscar pequeña bandeja con icono de SIM
4. **Extraer la bandeja del SIM**:
   - Usar herramienta SIM (clip enderezado)
   - Presionar suavemente el botón de liberación
5. **Verificar el SIM**:
   - ✅ SIM nano (tamaño correcto)
   - ✅ Contactos dorados limpios
   - ✅ No dañado físicamente
   - ✅ Orientación correcta (muesca en esquina)

### 2. Verificación de Antenas WWAN
1. **Acceder al compartimiento interno**:
   - Quitar panel inferior de la laptop
   - Localizar el módulo WWAN
2. **Verificar conexiones de antena**:
   - **Main**: Cable negro conectado firmemente
   - **Aux**: Cable gris conectado firmemente  
   - **GPS** (opcional): Cable blanco si existe
3. **Verificar cables**:
   - Sin daños visibles
   - Conectores bien asentados
   - Rutas sin pellizcos

### 3. Inserción Correcta del SIM
1. **Limpiar contactos** del SIM con alcohol isopropílico
2. **Colocar en bandeja** con orientación correcta
3. **Insertar bandeja** hasta que haga clic
4. **Verificar que está completamente insertada**

## 🖥️ COMANDOS DE VERIFICACIÓN POST-INSERCIÓN

Una vez verificada la instalación física:

```bash
# 1. Reinicio completo
sudo systemctl stop ModemManager NetworkManager
sudo modprobe -r iosm
sleep 5
sudo modprobe iosm
sleep 10
sudo systemctl start NetworkManager ModemManager

# 2. Verificar comunicación básica
printf "ATI\r\n" | sudo socat - /dev/wwan0at0,raw | head -3

# 3. Verificar SIM
printf "AT+CPIN?\r\n" | sudo socat - /dev/wwan0at0,raw | head -3

# 4. Si SIM detectado, verificar ICCID
printf "AT+CCID\r\n" | sudo socat - /dev/wwan0at0,raw | head -3

# 5. Buscar redes (puede tomar 60+ segundos)
printf "AT+COPS=?\r\n" | sudo socat - /dev/wwan0at0,raw
```

## 🔄 ALTERNATIVAS SI PERSISTE EL PROBLEMA

### Opción 1: Probar SIM en otro dispositivo
- Insertar SIM BAIT en teléfono móvil
- Verificar que funciona y tiene señal
- Confirmar que no está bloqueado por PIN

### Opción 2: Probar SIM diferente
- Usar SIM de otro operador (Telcel, AT&T, Movistar)
- Verificar si el problema es específico de BAIT/Altan

### Opción 3: Verificar compatibilidad
- BAIT/Altan usa red LTE 700MHz, 1700MHz, 2100MHz
- Verificar que L850-GL soporta estas bandas

### Opción 4: Configuración manual de red
```bash
# Forzar búsqueda en red mexicana
printf "AT+COPS=1,0,\"MEXICO\"\r\n" | sudo socat - /dev/wwan0at0,raw

# Configurar bandas LTE específicas de México
printf "AT+QCFG=\"band\",0,8000400000000000,0,1\r\n" | sudo socat - /dev/wwan0at0,raw
```

## 📞 CONTACTO TÉCNICO

Si todos los pasos fallan:

**BAIT Soporte Técnico**:
- Teléfono: 800-123-2248 
- Verificar compatibilidad específica con Fibocom L850-GL
- Solicitar configuración APN personalizada

**Lenovo Soporte**:
- Verificar instalación correcta del módulo WWAN
- Confirmar compatibilidad con ThinkPad T480

## ⚠️ NOTAS IMPORTANTES

1. **Nunca insertar/extraer SIM con laptop encendida**
2. **Verificar que el SIM no tiene PIN activo**
3. **BAIT puede requerir activación específica para datos**
4. **Algunas tarjetas WWAN requieren whitelist en BIOS**

## 📝 REGISTRO DE ESTADO

Después de cada verificación, ejecutar:
```bash
./scripts/diagnose_sim.sh > verificacion_$(date +%Y%m%d_%H%M%S).log
```

Esto guardará el estado para referencia futura.