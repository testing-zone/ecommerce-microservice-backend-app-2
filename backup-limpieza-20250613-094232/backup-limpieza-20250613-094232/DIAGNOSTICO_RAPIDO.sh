#!/bin/bash

echo "🔍 DIAGNÓSTICO RÁPIDO TALLER 2"
echo "=============================="
echo ""

# Función para timeout de comandos
run_with_timeout() {
    local timeout=$1
    local cmd=$2
    echo "⏱️  Ejecutando: $cmd (timeout: ${timeout}s)"
    
    timeout $timeout bash -c "$cmd" 2>/dev/null
    local result=$?
    
    if [ $result -eq 124 ]; then
        echo "   ⚠️  TIMEOUT después de ${timeout}s"
        return 1
    elif [ $result -eq 0 ]; then
        echo "   ✅ OK"
        return 0
    else
        echo "   ❌ FALLÓ (código: $result)"
        return 1
    fi
}

echo "1. 🔍 Verificando Docker..."
if command -v docker >/dev/null 2>&1; then
    echo "   ✅ Docker command available"
    run_with_timeout 5 "docker version --format 'Client: {{.Client.Version}}'"
    run_with_timeout 10 "docker info --format 'Server Version: {{.ServerVersion}}'"
else
    echo "   ❌ Docker command not found"
fi

echo ""
echo "2. 🔍 Verificando minikube..."
if command -v minikube >/dev/null 2>&1; then
    echo "   ✅ minikube command available"
    run_with_timeout 10 "minikube status"
else
    echo "   ❌ minikube command not found"
fi

echo ""
echo "3. 🔍 Verificando kubectl..."
if command -v kubectl >/dev/null 2>&1; then
    echo "   ✅ kubectl command available"
    run_with_timeout 5 "kubectl version --client --short"
else
    echo "   ❌ kubectl command not found"
fi

echo ""
echo "4. 🔍 Verificando Jenkins..."
run_with_timeout 3 "curl -s http://localhost:8081/login 2>/dev/null | head -1"

echo ""
echo "5. 🔍 Verificando puertos..."
echo "   Puertos ocupados:"
lsof -i :8081 2>/dev/null | grep LISTEN || echo "   Puerto 8081: libre"
lsof -i :8082 2>/dev/null | grep LISTEN || echo "   Puerto 8082: libre"

echo ""
echo "6. 🔍 Verificando procesos problemáticos..."
ps aux | grep -E "(minikube|jenkins|Docker)" | grep -v grep || echo "   No hay procesos relacionados corriendo"

echo ""
echo "7. 🔍 Verificando dependencias básicas..."
echo "   Java: $(java -version 2>&1 | head -1 || echo 'No instalado')"
echo "   Python3: $(python3 --version 2>&1 || echo 'No instalado')"
echo "   Maven: $(mvn -version 2>&1 | head -1 || echo 'No instalado')"

echo ""
echo "8. 🔍 Verificando sistema..."
echo "   OS: $(uname -s)"
echo "   Arquitectura: $(uname -m)"
echo "   Memoria libre: $(vm_stat | grep 'Pages free' | awk '{print $3}' | sed 's/\.//')MB aproximadamente"

echo ""
echo "🎯 DIAGNÓSTICO COMPLETADO"
echo "========================"
echo ""
echo "💡 Problemas comunes detectados:"

# Detectar problemas comunes
PROBLEMS=()

if ! command -v docker >/dev/null 2>&1; then
    PROBLEMS+=("Docker no instalado")
fi

if ! docker info >/dev/null 2>&1; then
    PROBLEMS+=("Docker no está corriendo")
fi

if ! command -v minikube >/dev/null 2>&1; then
    PROBLEMS+=("minikube no instalado")
fi

if ! command -v kubectl >/dev/null 2>&1; then
    PROBLEMS+=("kubectl no instalado")
fi

if [ ${#PROBLEMS[@]} -eq 0 ]; then
    echo "✅ No se detectaron problemas obvios"
    echo ""
    echo "🚀 Puedes intentar:"
    echo "   ./SETUP_COMPLETO_TALLER_2.sh"
else
    echo "❌ Problemas detectados:"
    for problem in "${PROBLEMS[@]}"; do
        echo "   • $problem"
    done
    echo ""
    echo "🔧 Soluciones sugeridas:"
    echo "   1. Instalar Docker Desktop desde https://docker.com"
    echo "   2. Ejecutar: brew install kubectl minikube"
    echo "   3. Abrir Docker Desktop manualmente"
    echo "   4. Reiniciar terminal"
fi 