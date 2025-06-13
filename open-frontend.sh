#!/bin/bash

echo "🌐 ABRIENDO INTERFACES WEB DEL E-COMMERCE"
echo "========================================"

# Obtener IP de Minikube
MINIKUBE_IP=$(minikube ip 2>/dev/null)

if [ -z "$MINIKUBE_IP" ]; then
    echo "❌ Minikube no está ejecutándose o no se puede obtener la IP"
    echo "💡 Ejecuta: minikube start"
    exit 1
fi

echo "🔗 IP de Minikube: $MINIKUBE_IP"
echo ""

# Función para verificar si un servicio está disponible
check_service() {
    local url=$1
    local name=$2
    
    if curl -s --max-time 5 "$url" >/dev/null 2>&1; then
        echo "✅ $name está disponible"
        return 0
    else
        echo "⚠️  $name no está disponible aún"
        return 1
    fi
}

# URLs principales
FRONTEND_URL="http://$MINIKUBE_IP:8900/swagger-ui.html"
GRAFANA_URL="http://$MINIKUBE_IP:30030"
PROMETHEUS_URL="http://$MINIKUBE_IP:30090"
KIBANA_URL="http://$MINIKUBE_IP:30601"
JAEGER_URL="http://$MINIKUBE_IP:30686"
API_GATEWAY_URL="http://$MINIKUBE_IP:8080"
SERVICE_DISCOVERY_URL="http://$MINIKUBE_IP:8761"

echo "🔍 Verificando servicios..."

# Verificar servicios principales
check_service "$FRONTEND_URL" "Frontend (Swagger UI)"
check_service "$API_GATEWAY_URL" "API Gateway"
check_service "$SERVICE_DISCOVERY_URL" "Service Discovery"
check_service "$GRAFANA_URL" "Grafana"
check_service "$PROMETHEUS_URL" "Prometheus"

echo ""
echo "🚀 URLS DISPONIBLES:"
echo "┌─────────────────────────┬─────────────────────────────────────────┐"
echo "│ Servicio                │ URL                                     │"
echo "├─────────────────────────┼─────────────────────────────────────────┤"
echo "│ 🎯 Frontend (Swagger)   │ $FRONTEND_URL │"
echo "│ 🚪 API Gateway          │ $API_GATEWAY_URL                │"
echo "│ 🔍 Service Discovery    │ $SERVICE_DISCOVERY_URL          │"
echo "│ 📊 Grafana              │ $GRAFANA_URL                    │"
echo "│ 📈 Prometheus           │ $PROMETHEUS_URL                 │"
echo "│ 📋 Kibana               │ $KIBANA_URL                     │"
echo "│ 🔍 Jaeger               │ $JAEGER_URL                     │"
echo "└─────────────────────────┴─────────────────────────────────────────┘"

echo ""
echo "🔑 Credenciales:"
echo "   • Grafana: admin / admin123"
echo "   • Otros servicios: Sin autenticación"

echo ""
echo "🎯 ABRIENDO FRONTEND PRINCIPAL..."

# Detectar el sistema operativo y abrir el navegador
case "$(uname -s)" in
    Darwin)  # macOS
        open "$FRONTEND_URL"
        echo "✅ Abriendo en macOS..."
        ;;
    Linux)   # Linux
        if command -v xdg-open > /dev/null; then
            xdg-open "$FRONTEND_URL"
            echo "✅ Abriendo en Linux..."
        else
            echo "💡 Abre manualmente: $FRONTEND_URL"
        fi
        ;;
    CYGWIN*|MINGW*|MSYS*) # Windows
        start "$FRONTEND_URL"
        echo "✅ Abriendo en Windows..."
        ;;
    *)
        echo "💡 Abre manualmente: $FRONTEND_URL"
        ;;
esac

echo ""
echo "🎮 CÓMO USAR EL FRONTEND:"
echo "1. En Swagger UI, expandir las secciones de APIs"
echo "2. Probar endpoints como:"
echo "   • GET /api/users - Listar usuarios"
echo "   • GET /api/products - Listar productos"
echo "   • POST /api/users - Crear usuario"
echo "   • POST /api/orders - Crear orden"

echo ""
echo "📊 PARA VER MONITOREO:"
echo "   • Grafana: http://$MINIKUBE_IP:30030 (admin/admin123)"
echo "   • Prometheus: http://$MINIKUBE_IP:30090"

echo ""
echo "🛠️ COMANDOS ÚTILES:"
echo "   # Generar tráfico de prueba:"
echo "   ./generate-monitoring-data.sh"
echo ""
echo "   # Ver logs de servicios:"
echo "   kubectl logs -f deployment/user-service -n ecommerce"
echo ""
echo "   # Ver estado de pods:"
echo "   kubectl get pods -n ecommerce"

echo ""
echo "🎉 ¡Frontend listo para usar!" 