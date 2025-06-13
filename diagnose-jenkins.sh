#!/bin/bash

echo "🔍 DIAGNÓSTICO COMPLETO DE JENKINS"
echo "=================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

# Variables de diagnóstico
JENKINS_RUNNING=false
DOCKER_IN_JENKINS=false
KUBECTL_IN_JENKINS=false
JENKINS_RESPONDING=false

log_step "1. Verificando estado de Jenkins..."

# Verificar si Jenkins está corriendo
if docker ps | grep -q jenkins-server; then
    JENKINS_RUNNING=true
    log_info "✅ Jenkins container está corriendo"
    
    # Obtener información del contenedor
    echo "📊 Información del contenedor Jenkins:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep jenkins
    
    # Verificar conectividad
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 | grep -q "403\|200"; then
        JENKINS_RESPONDING=true
        log_info "✅ Jenkins respondiendo en puerto 8081"
    else
        log_error "❌ Jenkins no responde en puerto 8081"
    fi
    
else
    log_error "❌ Jenkins container no está corriendo"
fi

log_step "2. Verificando Docker dentro de Jenkins..."

if [ "$JENKINS_RUNNING" = true ]; then
    # Verificar Docker en Jenkins
    if docker exec jenkins-server docker --version >/dev/null 2>&1; then
        DOCKER_IN_JENKINS=true
        log_info "✅ Docker disponible en Jenkins"
        echo "🐳 Versión Docker en Jenkins:"
        docker exec jenkins-server docker --version
    else
        log_error "❌ Docker NO disponible en Jenkins"
        echo "🔧 Esto causa que los pipelines fallen en el stage 'Docker Build'"
    fi
    
    # Verificar socket Docker
    if docker exec jenkins-server test -S /var/run/docker.sock; then
        log_info "✅ Docker socket montado correctamente"
    else
        log_error "❌ Docker socket NO montado en Jenkins"
    fi
    
    # Verificar permisos
    echo "🔐 Verificando permisos Docker socket:"
    docker exec jenkins-server ls -la /var/run/docker.sock
fi

log_step "3. Verificando kubectl en Jenkins..."

if [ "$JENKINS_RUNNING" = true ]; then
    if docker exec jenkins-server kubectl version --client >/dev/null 2>&1; then
        KUBECTL_IN_JENKINS=true
        log_info "✅ kubectl disponible en Jenkins"
        echo "☸️ Versión kubectl en Jenkins:"
        docker exec jenkins-server kubectl version --client --short
        
        # Verificar conectividad a cluster
        if docker exec jenkins-server kubectl cluster-info --request-timeout=5s >/dev/null 2>&1; then
            log_info "✅ Jenkins puede conectar al cluster Kubernetes"
        else
            log_warn "⚠️ Jenkins NO puede conectar al cluster Kubernetes"
        fi
    else
        log_error "❌ kubectl NO disponible en Jenkins"
    fi
fi

log_step "4. Verificando herramientas adicionales..."

if [ "$JENKINS_RUNNING" = true ]; then
    echo "📋 Herramientas en Jenkins:"
    
    # Java
    if docker exec jenkins-server java -version >/dev/null 2>&1; then
        echo "  ✅ Java: $(docker exec jenkins-server java -version 2>&1 | head -1)"
    else
        echo "  ❌ Java no disponible"
    fi
    
    # Maven
    if docker exec jenkins-server mvn -version >/dev/null 2>&1; then
        echo "  ✅ Maven disponible"
    else
        echo "  ⚠️ Maven no instalado (se instalará automáticamente)"
    fi
    
    # Git
    if docker exec jenkins-server git --version >/dev/null 2>&1; then
        echo "  ✅ Git: $(docker exec jenkins-server git --version)"
    else
        echo "  ❌ Git no disponible"
    fi
fi

log_step "5. Verificando logs de Jenkins..."

if [ "$JENKINS_RUNNING" = true ]; then
    echo "📜 Últimas líneas del log de Jenkins:"
    docker logs jenkins-server --tail 10
fi

log_step "6. Verificando volúmenes y persistencia..."

echo "💾 Volúmenes Docker relacionados con Jenkins:"
docker volume ls | grep jenkins || echo "No hay volúmenes Jenkins"

if [ "$JENKINS_RUNNING" = true ]; then
    echo "📁 Contenido del directorio Jenkins home:"
    docker exec jenkins-server ls -la /var/jenkins_home/ | head -10
fi

echo ""
echo "📊 RESUMEN DEL DIAGNÓSTICO"
echo "========================="
echo ""

if [ "$JENKINS_RUNNING" = true ]; then
    echo "✅ Jenkins Status: CORRIENDO"
else
    echo "❌ Jenkins Status: NO CORRIENDO"
fi

if [ "$JENKINS_RESPONDING" = true ]; then
    echo "✅ Web Interface: ACCESIBLE"
else
    echo "❌ Web Interface: NO ACCESIBLE"
fi

if [ "$DOCKER_IN_JENKINS" = true ]; then
    echo "✅ Docker en Jenkins: FUNCIONANDO"
else
    echo "❌ Docker en Jenkins: NO FUNCIONANDO"
fi

if [ "$KUBECTL_IN_JENKINS" = true ]; then
    echo "✅ kubectl en Jenkins: FUNCIONANDO"
else
    echo "❌ kubectl en Jenkins: NO FUNCIONANDO"
fi

echo ""
echo "🔧 SOLUCIONES RECOMENDADAS"
echo "========================="
echo ""

if [ "$JENKINS_RUNNING" = false ]; then
    echo "🚀 PROBLEMA: Jenkins no está corriendo"
    echo "   SOLUCIÓN: ./setup-jenkins.sh"
    echo ""
fi

if [ "$JENKINS_RUNNING" = true ] && [ "$DOCKER_IN_JENKINS" = false ]; then
    echo "🐳 PROBLEMA: Docker no funciona en Jenkins"
    echo "   SOLUCIÓN: ./fix-jenkins-docker.sh"
    echo ""
fi

if [ "$JENKINS_RUNNING" = true ] && [ "$KUBECTL_IN_JENKINS" = false ]; then
    echo "☸️ PROBLEMA: kubectl no disponible en Jenkins"
    echo "   SOLUCIÓN: Ejecutar fix-jenkins-docker.sh (incluye kubectl)"
    echo ""
fi

if [ "$JENKINS_RUNNING" = true ] && [ "$JENKINS_RESPONDING" = false ]; then
    echo "🌐 PROBLEMA: Jenkins no responde en puerto 8081"
    echo "   SOLUCIÓN 1: docker restart jenkins-server"
    echo "   SOLUCIÓN 2: Verificar firewall/puertos"
    echo ""
fi

echo "🎯 ACCIONES RÁPIDAS"
echo "==================="
echo ""
echo "Para SOLUCIONAR TODOS los problemas encontrados:"
echo ""

if [ "$JENKINS_RUNNING" = false ]; then
    echo "1️⃣ ./setup-jenkins.sh        # Iniciar Jenkins"
fi

if [ "$DOCKER_IN_JENKINS" = false ] || [ "$KUBECTL_IN_JENKINS" = false ]; then
    echo "2️⃣ ./fix-jenkins-docker.sh   # Configurar Docker + kubectl"
fi

echo "3️⃣ ./update-jenkinsfiles-docker.sh  # Actualizar pipelines"
echo ""

echo "📋 VERIFICACIÓN POST-SOLUCIÓN:"
echo "  ./diagnose-jenkins.sh        # Ejecutar este diagnóstico nuevamente"
echo "  http://localhost:8081        # Acceder a Jenkins UI"
echo ""

echo "🔑 CONTRASEÑA JENKINS (si es primera vez):"
if [ "$JENKINS_RUNNING" = true ]; then
    docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Jenkins ya configurado"
else
    echo "Ejecutar primero setup-jenkins.sh"
fi

echo ""
echo "✅ DIAGNÓSTICO COMPLETADO" 