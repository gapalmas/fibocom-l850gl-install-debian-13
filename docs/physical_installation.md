# Instalación física: SIM y antenas

## 📋 Checklist de instalación física

### 🔧 Lo que necesitas hacer:

#### 1. 📲 Instalación de SIM
- [ ] **Apagar** completamente el laptop
- [ ] **Localizar** el slot de SIM (generalmente cerca del módulo WWAN)
- [ ] **Insertar** la SIM con la orientación correcta
- [ ] **Verificar** que esté bien asentada

**💡 Tip**: En ThinkPad T480, el slot SIM suele estar accesible quitando la tapa inferior

#### 2. 📡 Instalación de antenas
- [ ] **Conectar antena principal** al conector marcado como **MAIN** o **1**
- [ ] **Conectar antena auxiliar** al conector marcado como **AUX**, **DIV** o **2**
- [ ] **Verificar** que los conectores estén bien apretados
- [ ] **Enrutar cables** sin pellizcarlos o doblarlos excesivamente

**⚠️ IMPORTANTE**: 
- Los conectores son frágiles, conectar con cuidado
- No forzar las conexiones
- Cables no deben tocar componentes calientes

#### 3. ⚙️ Configuración de SIM (Recomendado)
**Antes de usar en el laptop**:
- [ ] **Insertar SIM en un teléfono**
- [ ] **Desactivar PIN** de la SIM (Configuración → SIM → PIN)
- [ ] **Verificar** que tenga plan de datos activo
- [ ] **Probar** conectividad de datos en el teléfono

## 🔍 Después de la instalación

### Verificación inmediata:
```bash
./scripts/final_check.sh
```

Este script verificará:
- ✅ Detección del módulo
- ✅ Comunicación con SIM
- ✅ Calidad de señal
- ✅ Información de operadora

### Si todo está OK:
1. **Abrir**: Configuración → Red → Mobile Broadband
2. **Editar**: Conexión "Fibocom-L850GL-WWAN"
3. **Configurar APN** de tu operadora:
   - **Telcel**: `internet.itelcel.com`
   - **Movistar**: `internet.movistar.mx`
   - **AT&T**: `broadband`
4. **Conectar** y ¡listo!

## 🚨 Troubleshooting instalación física

### ❌ SIM no detectada
**Causas comunes**:
- SIM mal insertada o en orientación incorrecta
- Contactos sucios
- SIM dañada

**Soluciones**:
1. Retirar y reinsertar SIM
2. Limpiar contactos con alcohol isopropílico
3. Probar SIM en teléfono primero

### ❌ Señal muy débil o nula
**Causas comunes**:
- Antenas no conectadas
- Antenas mal posicionadas
- Cables pellizcados

**Soluciones**:
1. Verificar conexiones de antena
2. Reposicionar antenas lejos de metal
3. Verificar que cables no estén dañados

### ❌ Módem no responde después de instalación
**Causas comunes**:
- Módulo se desconectó durante instalación
- Problema de alimentación
- Interference electromagnética

**Soluciones**:
1. Apagar y reiniciar sistema
2. Verificar asentamiento del módulo M.2
3. Desconectar y reconectar antenas

## 📍 Ubicación de componentes en ThinkPad T480

```
 [Batería]    [RAM]     [SSD]    [WWAN]
     |          |         |        |
     |          |         |     [Antenas]
     |          |         |        |
 [Ventilador] [CPU]   [WiFi]   [SIM Slot]
```

**Acceso**:
- **SIM**: Tapa inferior (puede requerir quitar batería)
- **Antenas**: Cables negros/grises que van hacia la pantalla
- **Módulo WWAN**: Slot M.2 marcado como WWAN

## 💡 Consejos profesionales

### 🔧 Instalación de antenas:
- **Negro/Principal** → Conector MAIN
- **Gris/Auxiliar** → Conector AUX
- Verificar que no toquen metal
- Enrutar por canales previstos

### 📲 Preparación de SIM:
- Usar nano-SIM (la más pequeña)
- Activar plan de datos antes de instalar
- Verificar que funcione en teléfono
- Desactivar PIN para uso automático

### 🔍 Verificación post-instalación:
- Ejecutar `./scripts/final_check.sh`
- Verificar señal > 50% para buena conectividad
- Probar APN correcto de la operadora
- Configurar límites de datos si es necesario

¡Con estos pasos tendrás tu módulo WWAN funcionando perfectamente! 🎉