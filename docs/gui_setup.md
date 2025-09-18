# Configuración gráfica del módem WWAN

## 🎉 ¡Sí! Puedes usar tu módem WWAN con interfaz gráfica

Después de ejecutar `./scripts/setup_gui.sh`, tendrás disponibles **4 herramientas gráficas** para gestionar tu conexión móvil, similar al WiFi manager.

## 🛠️ Herramientas gráficas disponibles

### 1. 🎛️ GNOME Settings (Configuración del Sistema)
**La más fácil de usar - Recomendada para principiantes**

```bash
gnome-control-center network
```

**Cómo usarla:**
1. Abre "Configuración" desde el menú de aplicaciones
2. Ve a "Red" 
3. Busca la sección "Mobile Broadband" o "Banda ancha móvil"
4. Verás tu conexión "Fibocom-L850GL-WWAN"
5. Clic en el engranaje ⚙️ para configurar
6. Ingresa el APN de tu operadora

**Ventajas:**
- ✅ Interfaz simple e intuitiva
- ✅ Integrada con GNOME
- ✅ Conexión automática disponible

### 2. 🔧 NetworkManager Connection Editor
**Para usuarios avanzados**

```bash
nm-connection-editor
```

**Cómo usarla:**
1. Se abre una ventana con todas las conexiones de red
2. Busca tu conexión "Fibocom-L850GL-WWAN" 
3. Doble clic para editar o botón "Editar"
4. Configura:
   - **APN**: según tu operadora
   - **Usuario/Contraseña**: si es necesario
   - **PIN de SIM**: si está habilitado

**Ventajas:**
- ✅ Configuración detallada
- ✅ Opciones avanzadas de red
- ✅ Control completo de parámetros

### 3. 📊 Modem Manager GUI
**Herramienta especializada para módems**

```bash
modem-manager-gui
```

**Cómo usarla:**
1. Muestra todos los módems detectados
2. Información detallada del dispositivo:
   - IMEI, modelo, firmware
   - Calidad de señal en tiempo real
   - Información de la red
   - Estadísticas de datos

**Ventajas:**
- ✅ Información técnica completa
- ✅ Monitoreo en tiempo real
- ✅ Envío de SMS (si soportado)
- ✅ Diagnóstico avanzado

**Nota**: Si no detecta el módem inmediatamente, es por el problema del modo RPC que ya identificamos.

### 4. 🖱️ Applet de NetworkManager (Barra superior)
**Acceso rápido desde la barra de tareas**

**Cómo usarlo:**
1. Clic en el icono de red en la barra superior
2. Busca opciones de "Mobile Broadband", "WWAN" o "Cellular"
3. Activa/desactiva la conexión
4. Acceso rápido a configuración

**Ventajas:**
- ✅ Acceso inmediato
- ✅ Estado visual de la conexión
- ✅ Control de conectividad rápido

## ⚙️ Configuración de APN por operadora

### Operadoras México 🇲🇽
| Operadora | APN | Usuario | Contraseña |
|-----------|-----|---------|------------|
| **Telcel** | `internet.itelcel.com` | `webgprs` | `webgprs2002` |
| **Movistar** | `internet.movistar.mx` | `movistar` | `movistar` |
| **AT&T México** | `broadband` | - | - |
| **Unefon** | `internet.unefon.com.mx` | `unefon` | `unefon` |

### Operadoras USA 🇺🇸
| Operadora | APN | Usuario | Contraseña |
|-----------|-----|---------|------------|
| **Verizon** | `vzwinternet` | - | - |
| **AT&T** | `broadband` | - | - |
| **T-Mobile** | `fast.t-mobile.com` | - | - |
| **Sprint** | `cinet.spcs` | - | - |

### Operadoras España 🇪🇸
| Operadora | APN | Usuario | Contraseña |
|-----------|-----|---------|------------|
| **Movistar** | `internet` | `movistar` | `movistar` |
| **Vodafone** | `airtelnet.es` | `vodafone` | `vodafone` |
| **Orange** | `internet` | - | - |

## 🚀 Pasos para conectar

### Configuración inicial (una sola vez):
1. **Ejecutar**: `./scripts/setup_gui.sh`
2. **Cerrar sesión y volver a entrar** (importante para permisos)
3. **Insertar tarjeta SIM** en el slot M.2

### Conexión diaria:
1. **Abrir** GNOME Settings → Red
2. **Activar** Mobile Broadband 
3. **Seleccionar** tu conexión
4. **¡Conectar!**

## 🔧 Troubleshooting interfaz gráfica

### ❓ No aparece "Mobile Broadband" en Settings
**Solución:**
```bash
# Reiniciar NetworkManager
sudo systemctl restart NetworkManager

# Verificar que la conexión existe
nmcli con show | grep Fibocom
```

### ❓ Dice "No hay módem" o "Device not ready"
**Motivo**: Es el problema del modo RPC que ya identificamos.

**Soluciones:**
1. **Usar configuración directa**:
   ```bash
   nmcli con up Fibocom-L850GL-WWAN
   ```

2. **Intentar configuración avanzada**:
   ```bash
   sudo ./scripts/configure_modemmanager.sh
   ```

### ❓ Se conecta pero no hay internet
**Verificar**:
1. APN correcto para tu operadora
2. Tarjeta SIM activada para datos
3. Saldo/plan de datos válido
4. PIN de SIM deshabilitado (recomendado)

### ❓ Conexión intermitente
**Causas comunes**:
- Señal débil (verificar cobertura)
- Límite de datos alcanzado
- Problema con antena (verificar instalación física)

## 💡 Consejos útiles

### 📶 Mejorar señal:
- Usar cerca de ventanas
- Evitar objetos metálicos
- Verificar que las antenas estén bien conectadas

### 🔋 Ahorrar batería:
- Desconectar cuando no uses
- Configurar conexión manual (no automática)
- Usar modo avión cuando no necesites red

### 📊 Monitorear uso de datos:
- Usar Modem Manager GUI para estadísticas
- Configurar límites en Settings → Red → Uso de datos

## 🎯 Resumen

**¡Tu módem WWAN ahora funciona como WiFi!**

- ✅ **4 herramientas gráficas** disponibles
- ✅ **Configuración visual** fácil
- ✅ **Conexión automática** posible
- ✅ **Monitoreo en tiempo real**
- ✅ **Compatible con GNOME**

La experiencia es prácticamente idéntica a conectar WiFi, solo necesitas configurar el APN una vez y listo.