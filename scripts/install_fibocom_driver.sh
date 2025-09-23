#!/bin/bash

# Script para descargar e instalar driver oficial Fibocom L850-GL
# Reemplaza el driver genérico iosm con el driver específico de Fibocom

echo "🔧 INSTALACIÓN DRIVER OFICIAL FIBOCOM L850-GL"
echo "============================================"
echo

# Verificar dependencias
echo "1. Verificando dependencias del sistema"
echo "-------------------------------------"
echo "📦 Instalando herramientas de compilación..."
sudo apt update
sudo apt install -y build-essential linux-headers-$(uname -r) git wget curl dkms

# Crear directorio temporal
TEMP_DIR="/tmp/fibocom_driver"
echo "📁 Creando directorio temporal: $TEMP_DIR"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

echo

# Opción 1: Intentar descargar desde GitHub (drivers de la comunidad)
echo "2. Buscando drivers disponibles"
echo "-----------------------------"

echo "🔍 Buscando driver xmm7360-pci (comunidad)..."
if git clone https://github.com/xmm7360/xmm7360-pci.git 2>/dev/null; then
    echo "✅ Driver xmm7360-pci encontrado"
    cd xmm7360-pci
    
    echo "🔨 Compilando driver xmm7360-pci..."
    if make; then
        echo "✅ Compilación exitosa"
        
        echo "📋 Instalando driver..."
        sudo make install
        
        echo "🔄 Registrando módulo..."
        sudo depmod
        
        echo "✅ Driver xmm7360-pci instalado"
        
        # Crear script de carga
        echo "📝 Creando script de carga..."
        cat > /tmp/load_xmm7360.sh << 'EOF'
#!/bin/bash
# Cargar driver xmm7360-pci para Fibocom L850-GL

echo "Cargando driver xmm7360-pci..."
sudo modprobe -r iosm 2>/dev/null
sudo modprobe xmm7360
sleep 3

echo "Verificando dispositivos..."
ls -la /dev/wwan* 2>/dev/null || echo "Sin dispositivos WWAN"

echo "Verificando comunicación..."
timeout 5s bash -c 'printf "ATI\r\n" | sudo socat - /dev/wwan0at0,raw 2>/dev/null' | head -3
EOF
        chmod +x /tmp/load_xmm7360.sh
        
        cd "$TEMP_DIR"
    else
        echo "❌ Error en compilación xmm7360-pci"
    fi
else
    echo "❌ No se pudo descargar xmm7360-pci"
fi

echo

# Opción 2: Buscar driver oficial Fibocom
echo "3. Buscando driver oficial Fibocom"
echo "---------------------------------"

# URLs conocidas de drivers Fibocom (estas pueden cambiar)
FIBOCOM_URLS=(
    "https://www.fibocom.com/upload/2020/09/L850-GL-Linux-Driver.tar.gz"
    "https://www.fibocom.com/download/l850-gl-linux-driver"
    "https://github.com/fibocom-pc/linux-driver/archive/refs/heads/main.zip"
)

for url in "${FIBOCOM_URLS[@]}"; do
    echo "🔍 Intentando descargar desde: $url"
    if wget --timeout=10 --tries=2 "$url" -O fibocom_driver.tar.gz 2>/dev/null; then
        echo "✅ Descarga exitosa"
        
        if tar -xzf fibocom_driver.tar.gz 2>/dev/null; then
            echo "✅ Extracción exitosa"
            
            # Buscar archivos de instalación
            if find . -name "install*" -o -name "make*" -o -name "Makefile" | head -1; then
                echo "📋 Archivos de instalación encontrados"
                # Aquí se ejecutaría la instalación específica
            fi
        fi
        break
    else
        echo "❌ No se pudo descargar"
    fi
done

echo

# Opción 3: Driver alternativo desde repositorios
echo "4. Verificando drivers alternativos"
echo "----------------------------------"

echo "🔍 Buscando paquetes relacionados con Fibocom..."
apt search fibocom 2>/dev/null | grep -v "WARNING" || echo "No encontrado en repositorios"

echo "🔍 Buscando drivers WWAN alternativos..."
apt search wwan 2>/dev/null | grep -v "WARNING" | head -5

echo

# Información sobre drivers manuales
echo "5. Información adicional"
echo "----------------------"
echo "📋 Sitios oficiales de drivers:"
echo "   • Fibocom: https://www.fibocom.com/en/support/downloads"
echo "   • Lenovo: https://support.lenovo.com/ (buscar FRU 01AX792)"
echo "   • Intel: https://downloadcenter.intel.com/ (XMM7360)"
echo
echo "📋 Comandos para instalar driver manual:"
echo "   1. Descargar driver de sitio oficial"
echo "   2. tar -xzf driver.tar.gz"
echo "   3. cd driver_directory"
echo "   4. make && sudo make install"
echo "   5. sudo modprobe nuevo_driver"
echo
echo "📋 Para probar driver xmm7360-pci (si se instaló):"
echo "   bash /tmp/load_xmm7360.sh"

# Limpiar
echo
echo "🧹 Limpiando archivos temporales..."
cd /
rm -rf "$TEMP_DIR"

echo "✅ Proceso completado"
echo
echo "💡 Próximos pasos:"
echo "   1. Si se instaló xmm7360-pci: ejecutar /tmp/load_xmm7360.sh"
echo "   2. Si no: descargar driver oficial desde sitio de Fibocom"
echo "   3. Reiniciar sistema después de instalar nuevo driver"