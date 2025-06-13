#!/bin/bash

# ============================================================================
# DESPLIEGUE COMPLETO E-COMMERCE MICROSERVICES
# ============================================================================
# Script principal que orquesta todo el proceso:
# 1. Organiza y limpia scripts del proyecto
# 2. Ejecuta el pipeline maestro de despliegue
# 3. Proporciona información de acceso a todos los servicios
# ============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "============================================================================"
echo "🚀 DESPLIEGUE COMPLETO E-COMMERCE MICROSERVICES"
echo "============================================================================"
echo ""
echo "Este script desplegará automáticamente:"
echo "  • Jenkins CI/CD"
echo "  • 6 Microservicios de E-commerce"
echo "  • Stack completo de Monitoreo (Prometheus, Grafana, ELK, Jaeger)"
echo "  • Tests de Performance"
echo "  • Generación de datos de prueba"
echo ""
echo "Duración estimada: 10-15 minutos"
echo ""

# Verificar que estamos en la raíz del proyecto
if [ ! -f "$PROJECT_ROOT/pom.xml" ]; then
    echo "❌ ERROR: Ejecuta este script desde la raíz del proyecto e-commerce"
    exit 1
fi

# Preguntar confirmación
read -p "¿Continuar con el despliegue completo? [y/N]: " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Despliegue cancelado"
    exit 0
fi

echo ""
echo "============================================================================"
echo "📁 FASE 1: ORGANIZANDO ESTRUCTURA DEL PROYECTO"
echo "============================================================================"

# Crear directorio pipeline si no existe
mkdir -p "$PROJECT_ROOT/pipeline"

# Si existe el script de organización, ejecutarlo
if [ ! -f "$PROJECT_ROOT/pipeline/organize-scripts.sh" ]; then
    echo "⚠️  Script de organización no encontrado. Continuando con estructura actual..."
else
    echo "🔧 Organizando scripts del proyecto..."
    chmod +x "$PROJECT_ROOT/pipeline/organize-scripts.sh"
    bash "$PROJECT_ROOT/pipeline/organize-scripts.sh"
fi

echo ""
echo "============================================================================"
echo "🚀 FASE 2: EJECUTANDO PIPELINE MAESTRO DE DESPLIEGUE"
echo "============================================================================"

# Verificar que existe el pipeline maestro
if [ ! -f "$PROJECT_ROOT/pipeline/master-deployment-pipeline.sh" ]; then
    echo "❌ ERROR: Pipeline maestro no encontrado en pipeline/master-deployment-pipeline.sh"
    exit 1
fi

# Ejecutar el pipeline maestro
chmod +x "$PROJECT_ROOT/pipeline/master-deployment-pipeline.sh"
bash "$PROJECT_ROOT/pipeline/master-deployment-pipeline.sh"

# Verificar resultado del pipeline
if [ $? -eq 0 ]; then
    echo ""
    echo "============================================================================"
    echo "🎉 DESPLIEGUE COMPLETADO EXITOSAMENTE"
    echo "============================================================================"
    echo ""
    
    # Obtener URLs de acceso
    echo "📋 INFORMACIÓN DE ACCESO:"
    echo ""
    
    # Jenkins
    echo "🔧 JENKINS CI/CD:"
    echo "   URL: http://localhost:8081"
    echo "   Usuario: admin"
    echo "   Contraseña: Configurar en primera ejecución"
    echo ""
    
    # Microservicios
    echo "🛍️  MICROSERVICIOS E-COMMERCE:"
    minikube_ip=$(minikube ip 2>/dev/null || echo "localhost")
    echo "   user-service: http://$minikube_ip:30087"
    echo "   product-service: http://$minikube_ip:30082"
    echo "   order-service: http://$minikube_ip:30083"
    echo "   payment-service: http://$minikube_ip:30084"
    echo "   shipping-service: http://$minikube_ip:30085"
    echo "   favourite-service: http://$minikube_ip:30086"
    echo ""
    
    # Monitoreo
    echo "📊 SERVICIOS DE MONITOREO:"
    if [ -f "$PROJECT_ROOT/monitoring-tunnels.log" ]; then
        echo "   Ver URLs dinámicas en: monitoring-tunnels.log"
    else
        echo "   Grafana: http://$minikube_ip:30030 (admin/admin123)"
        echo "   Prometheus: http://$minikube_ip:30090"
        echo "   Kibana: http://$minikube_ip:30601"
        echo "   Jaeger: http://$minikube_ip:30686"
        echo "   AlertManager: http://$minikube_ip:30093"
    fi
    echo ""
    
    echo "📋 PRÓXIMOS PASOS:"
    echo "1. Configura Jenkins pipelines en http://localhost:8081"
    echo "2. Revisa dashboards de Grafana para métricas"
    echo "3. Analiza logs en Kibana"
    echo "4. Explora trazas distribuidas en Jaeger"
    echo ""
    
    echo "📄 DOCUMENTACIÓN:"
    echo "   Guía completa: docs/GUIA-ANALISIS-MONITOREO.md"
    echo "   Troubleshooting: docs/TROUBLESHOOTING.md"
    echo "   Log del despliegue: pipeline-deployment.log"
    echo ""
    
    echo "🔧 COMANDOS ÚTILES:"
    echo "   Ver pods: kubectl get pods -A"
    echo "   Ver servicios: kubectl get services -A"
    echo "   IP minikube: minikube ip"
    echo "   Logs del pipeline: tail -f pipeline-deployment.log"
    echo ""
    
else
    echo ""
    echo "============================================================================"
    echo "❌ EL DESPLIEGUE FALLÓ"
    echo "============================================================================"
    echo ""
    echo "🔍 DIAGNÓSTICO:"
    echo "   1. Revisa el log: pipeline-deployment.log"
    echo "   2. Verifica prerequisitos: minikube, kubectl, docker"
    echo "   3. Asegúrate de que minikube esté corriendo: minikube status"
    echo ""
    echo "🔧 REINTENTAR:"
    echo "   bash deploy-ecommerce-complete.sh"
    echo ""
    echo "📄 OBTENER AYUDA:"
    echo "   docs/TROUBLESHOOTING.md"
    echo ""
    exit 1
fi 