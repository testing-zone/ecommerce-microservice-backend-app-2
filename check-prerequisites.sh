#!/bin/bash

echo "🔍 VERIFICANDO PREREQUISITOS PARA E-COMMERCE"
echo "============================================"

# Contadores para el resumen
CHECKS_TOTAL=0
CHECKS_PASSED=0
CHECKS_FAILED=0

# Función para verificar comandos
check_command() {
    local cmd=$1
    local name=$2
    local version_flag=${3:-"--version"}
    
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    
    if command -v "$cmd" >/dev/null 2>&1; then
        local version=$($cmd $version_flag 2>/dev/null | head -1)
        echo "✅ $name: $version"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
        return 0
    else
        echo "❌ $name: No instalado"
        CHECKS_FAILED=$((CHECKS_FAILED + 1))
        return 1
    fi
}

# Función para verificar recursos del sistema
check_resources() {
    echo ""
    echo "💻 VERIFICANDO RECURSOS DEL SISTEMA:"
    echo "====================================="
    
    # CPU
    CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo "unknown")
    echo "🔧 CPU Cores: $CPU_CORES"
    
    if [ "$CPU_CORES" != "unknown" ] && [ "$CPU_CORES" -ge 4 ]; then
        echo "✅ CPU: Suficientes cores ($CPU_CORES >= 4)"
    elif [ "$CPU_CORES" != "unknown" ] && [ "$CPU_CORES" -ge 2 ]; then
        echo "⚠️  CPU: Mínimo aceptable ($CPU_CORES cores, recomendado 4+)"
    else
        echo "❌ CPU: Insuficientes cores (necesario mínimo 2)"
    fi
    
    # Memoria RAM
    if command -v free >/dev/null 2>&1; then
        TOTAL_MEM_KB=$(free | grep '^Mem:' | awk '{print $2}')
        TOTAL_MEM_GB=$((TOTAL_MEM_KB / 1024 / 1024))
    elif command -v vm_stat >/dev/null 2>&1; then
        # macOS
        TOTAL_MEM_BYTES=$(sysctl -n hw.memsize 2>/dev/null)
        TOTAL_MEM_GB=$((TOTAL_MEM_BYTES / 1024 / 1024 / 1024))
    else
        TOTAL_MEM_GB="unknown"
    fi
    
    echo "🧠 RAM Total: ${TOTAL_MEM_GB}GB"
    
    if [ "$TOTAL_MEM_GB" != "unknown" ] && [ "$TOTAL_MEM_GB" -ge 8 ]; then
        echo "✅ RAM: Suficiente memoria (${TOTAL_MEM_GB}GB >= 8GB)"
    elif [ "$TOTAL_MEM_GB" != "unknown" ] && [ "$TOTAL_MEM_GB" -ge 6 ]; then
        echo "⚠️  RAM: Mínimo aceptable (${TOTAL_MEM_GB}GB, recomendado 8GB+)"
    else
        echo "❌ RAM: Memoria insuficiente (necesario mínimo 6GB)"
    fi
    
    # Espacio en disco
    DISK_AVAIL=$(df . | tail -1 | awk '{print $4}')
    DISK_AVAIL_GB=$((DISK_AVAIL / 1024 / 1024))
    
    echo "💾 Disco Disponible: ${DISK_AVAIL_GB}GB"
    
    if [ "$DISK_AVAIL_GB" -ge 30 ]; then
        echo "✅ Disco: Suficiente espacio (${DISK_AVAIL_GB}GB >= 30GB)"
    elif [ "$DISK_AVAIL_GB" -ge 20 ]; then
        echo "⚠️  Disco: Espacio mínimo (${DISK_AVAIL_GB}GB, recomendado 30GB+)"
    else
        echo "❌ Disco: Espacio insuficiente (necesario mínimo 20GB)"
    fi
}

# Función para verificar Docker
check_docker() {
    echo ""
    echo "🐳 VERIFICANDO DOCKER:"
    echo "====================="
    
    check_command "docker" "Docker"
    
    if command -v docker >/dev/null 2>&1; then
        # Verificar que Docker está ejecutándose
        if docker info >/dev/null 2>&1; then
            echo "✅ Docker: Servicio ejecutándose"
            
            # Verificar permisos de usuario
            if docker ps >/dev/null 2>&1; then
                echo "✅ Docker: Permisos de usuario correctos"
            else
                echo "⚠️  Docker: Sin permisos de usuario (ejecuta: sudo usermod -aG docker $USER)"
            fi
        else
            echo "❌ Docker: Servicio no está ejecutándose"
        fi
    fi
}

# Función para verificar Kubernetes
check_kubernetes() {
    echo ""
    echo "☸️  VERIFICANDO KUBERNETES:"
    echo "=========================="
    
    check_command "kubectl" "kubectl"
    check_command "minikube" "Minikube"
    
    if command -v minikube >/dev/null 2>&1; then
        # Verificar estado de Minikube
        MINIKUBE_STATUS=$(minikube status 2>/dev/null | grep "kubelet:" | awk '{print $2}' || echo "Stopped")
        
        if [ "$MINIKUBE_STATUS" = "Running" ]; then
            echo "✅ Minikube: Ejecutándose"
            
            # Verificar configuración de recursos
            MINIKUBE_MEMORY=$(minikube config get memory 2>/dev/null || echo "unknown")
            MINIKUBE_CPUS=$(minikube config get cpus 2>/dev/null || echo "unknown")
            
            echo "   Configuración actual:"
            echo "   ├─ Memoria: ${MINIKUBE_MEMORY}MB"
            echo "   └─ CPUs: $MINIKUBE_CPUS"
            
            # Verificar conectividad con kubectl
            if kubectl cluster-info >/dev/null 2>&1; then
                echo "✅ kubectl: Conectado al cluster"
            else
                echo "❌ kubectl: No puede conectar al cluster"
            fi
        else
            echo "⚠️  Minikube: No está ejecutándose (estado: $MINIKUBE_STATUS)"
        fi
    fi
}

# Función para verificar Java y Maven
check_java_maven() {
    echo ""
    echo "☕ VERIFICANDO JAVA Y MAVEN:"
    echo "==========================="
    
    check_command "java" "Java" "-version"
    check_command "javac" "Java Compiler" "-version"
    check_command "mvn" "Maven"
    
    # Verificar JAVA_HOME
    if [ -n "$JAVA_HOME" ]; then
        echo "✅ JAVA_HOME: $JAVA_HOME"
    else
        echo "⚠️  JAVA_HOME: No configurado"
    fi
    
    # Verificar versión de Java
    if command -v java >/dev/null 2>&1; then
        JAVA_VERSION=$(java -version 2>&1 | head -1 | cut -d'"' -f2 | cut -d'.' -f1-2)
        if [[ "$JAVA_VERSION" == "11."* ]] || [[ "$JAVA_VERSION" == "1.8"* ]] || [[ "$JAVA_VERSION" == "17."* ]]; then
            echo "✅ Java: Versión compatible ($JAVA_VERSION)"
        else
            echo "⚠️  Java: Versión no verificada ($JAVA_VERSION, recomendado Java 11)"
        fi
    fi
}

# Función para verificar herramientas adicionales
check_additional_tools() {
    echo ""
    echo "🛠️  VERIFICANDO HERRAMIENTAS ADICIONALES:"
    echo "========================================"
    
    check_command "curl" "curl"
    check_command "wget" "wget"
    check_command "git" "Git"
    check_command "jq" "jq (JSON processor)" "--version"
    
    if ! command -v jq >/dev/null 2>&1; then
        echo "💡 Instalar jq: sudo apt install jq"
    fi
}

# Función para verificar puertos
check_ports() {
    echo ""
    echo "🔌 VERIFICANDO PUERTOS DISPONIBLES:"
    echo "==================================="
    
    PORTS=(8900 3000 9090 8080 8761 5601 16686)
    BUSY_PORTS=()
    
    for port in "${PORTS[@]}"; do
        if command -v lsof >/dev/null 2>&1; then
            if lsof -i :$port >/dev/null 2>&1; then
                BUSY_PORTS+=($port)
                echo "⚠️  Puerto $port: Ocupado"
            else
                echo "✅ Puerto $port: Disponible"
            fi
        elif command -v netstat >/dev/null 2>&1; then
            if netstat -ln | grep ":$port " >/dev/null 2>&1; then
                BUSY_PORTS+=($port)
                echo "⚠️  Puerto $port: Ocupado"
            else
                echo "✅ Puerto $port: Disponible"
            fi
        else
            echo "⚠️  Puerto $port: No se puede verificar"
        fi
    done
    
    if [ ${#BUSY_PORTS[@]} -gt 0 ]; then
        echo ""
        echo "📝 Puertos ocupados: ${BUSY_PORTS[*]}"
        echo "💡 Para liberar: ./stop-port-forwards.sh"
    fi
}

# Ejecutar todas las verificaciones
echo "🚀 Iniciando verificación de prerequisitos..."
echo ""

check_resources
check_docker
check_kubernetes
check_java_maven
check_additional_tools
check_ports

# Mostrar resumen
echo ""
echo "📊 RESUMEN DE VERIFICACIÓN:"
echo "=========================="
echo "✅ Verificaciones exitosas: $CHECKS_PASSED"
echo "❌ Verificaciones fallidas: $CHECKS_FAILED"
echo "📋 Total verificaciones: $CHECKS_TOTAL"

echo ""
if [ $CHECKS_FAILED -eq 0 ]; then
    echo "🎉 ¡SISTEMA LISTO PARA DESPLIEGUE!"
    echo ""
    echo "🚀 SIGUIENTE PASO:"
    echo "   ./ecommerce-manager.sh"
elif [ $CHECKS_FAILED -le 2 ]; then
    echo "⚠️  SISTEMA PARCIALMENTE LISTO"
    echo ""
    echo "🔧 ACCIONES RECOMENDADAS:"
    [ $CHECKS_FAILED -gt 0 ] && echo "   1. Instalar herramientas faltantes"
    echo "   2. Revisar configuración de Minikube"
    echo "   3. Ejecutar: ./ecommerce-manager.sh"
else
    echo "❌ SISTEMA NO LISTO - FALTAN PREREQUISITOS"
    echo ""
    echo "🛠️ ACCIONES REQUERIDAS:"
    echo "   1. Seguir GUIA-VM-COMPLETA.md pasos 1-5"
    echo "   2. Instalar herramientas faltantes"
    echo "   3. Configurar Minikube correctamente"
    echo "   4. Ejecutar este script nuevamente"
fi

echo ""
echo "📚 RECURSOS:"
echo "   📖 Guía completa: cat GUIA-VM-COMPLETA.md"
echo "   🔧 Scripts disponibles: ls -la *.sh"
echo "   📞 Verificar estado: ./verify-monitoring.sh"

echo ""
echo "🎯 ¡Prerequisitos verificados!" 