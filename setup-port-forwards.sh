#!/bin/bash

echo "🚀 CONFIGURANDO PORT-FORWARDS PARA ACCESO LOCAL"
echo "==============================================="

# Función para verificar si un port-forward ya está activo
check_port_forward() {
    local port=$1
    local service_name=$2
    
    if lsof -i :$port >/dev/null 2>&1; then
        echo "⚠️  Puerto $port ya está en uso por $service_name"
        return 1
    else
        echo "✅ Puerto $port disponible para $service_name"
        return 0
    fi
}

# Función para iniciar port-forward
start_port_forward() {
    local service=$1
    local namespace=$2
    local local_port=$3
    local remote_port=$4
    local service_name=$5
    
    echo "🔗 Iniciando port-forward para $service_name..."
    echo "   Comando: kubectl port-forward svc/$service $local_port:$remote_port -n $namespace"
    
    kubectl port-forward svc/$service $local_port:$remote_port -n $namespace >/dev/null 2>&1 &
    local pid=$!
    
    sleep 2
    
    if ps -p $pid >/dev/null 2>&1; then
        echo "✅ $service_name disponible en http://127.0.0.1:$local_port"
        echo "   PID: $pid"
        echo "$pid" >> /tmp/ecommerce-port-forwards.pids
        return 0
    else
        echo "❌ Error iniciando port-forward para $service_name"
        return 1
    fi
}

# Crear archivo para guardar PIDs
echo "" > /tmp/ecommerce-port-forwards.pids

echo "🔍 Verificando servicios disponibles..."

# Verificar que los namespaces existen
if ! kubectl get namespace ecommerce >/dev/null 2>&1; then
    echo "❌ Namespace 'ecommerce' no existe. Ejecuta primero el despliegue."
    exit 1
fi

if ! kubectl get namespace monitoring >/dev/null 2>&1; then
    echo "❌ Namespace 'monitoring' no existe. Ejecuta primero el despliegue."
    exit 1
fi

echo ""
echo "🎯 CONFIGURANDO PORT-FORWARDS PRINCIPALES:"

# Frontend (Proxy Client)
if kubectl get service proxy-client -n ecommerce >/dev/null 2>&1; then
    if check_port_forward 8900 "Frontend (Swagger UI)"; then
        start_port_forward "proxy-client" "ecommerce" "8900" "8900" "Frontend (Swagger UI)"
    fi
else
    echo "❌ Servicio proxy-client no encontrado en namespace ecommerce"
fi

# Grafana
if kubectl get service grafana -n monitoring >/dev/null 2>&1; then
    if check_port_forward 3000 "Grafana"; then
        start_port_forward "grafana" "monitoring" "3000" "3000" "Grafana"
    fi
else
    echo "❌ Servicio grafana no encontrado en namespace monitoring"
fi

# Prometheus
if kubectl get service prometheus -n monitoring >/dev/null 2>&1; then
    if check_port_forward 9090 "Prometheus"; then
        start_port_forward "prometheus" "monitoring" "9090" "9090" "Prometheus"
    fi
else
    echo "❌ Servicio prometheus no encontrado en namespace monitoring"
fi

# API Gateway
if kubectl get service api-gateway -n ecommerce >/dev/null 2>&1; then
    if check_port_forward 8080 "API Gateway"; then
        start_port_forward "api-gateway" "ecommerce" "8080" "8080" "API Gateway"
    fi
else
    echo "❌ Servicio api-gateway no encontrado en namespace ecommerce"
fi

# Service Discovery
if kubectl get service service-discovery -n ecommerce >/dev/null 2>&1; then
    if check_port_forward 8761 "Service Discovery"; then
        start_port_forward "service-discovery" "ecommerce" "8761" "8761" "Service Discovery"
    fi
else
    echo "❌ Servicio service-discovery no encontrado en namespace ecommerce"
fi

echo ""
echo "📊 CONFIGURANDO PORT-FORWARDS ADICIONALES:"

# Kibana
if kubectl get service kibana -n monitoring >/dev/null 2>&1; then
    if check_port_forward 5601 "Kibana"; then
        start_port_forward "kibana" "monitoring" "5601" "5601" "Kibana"
    fi
fi

# Jaeger
if kubectl get service jaeger -n monitoring >/dev/null 2>&1; then
    if check_port_forward 16686 "Jaeger"; then
        start_port_forward "jaeger" "monitoring" "16686" "16686" "Jaeger"
    fi
fi

echo ""
echo "🎉 PORT-FORWARDS CONFIGURADOS!"
echo ""
echo "🌐 URLS DE ACCESO LOCAL:"
echo "┌─────────────────────────┬─────────────────────────────────────────┐"
echo "│ Servicio                │ URL Local                               │"
echo "├─────────────────────────┼─────────────────────────────────────────┤"
echo "│ 🎯 Frontend (Swagger)   │ http://127.0.0.1:8900/swagger-ui.html  │"
echo "│ 🚪 API Gateway          │ http://127.0.0.1:8080                  │"
echo "│ 🔍 Service Discovery    │ http://127.0.0.1:8761                  │"
echo "│ 📊 Grafana              │ http://127.0.0.1:3000                  │"
echo "│ 📈 Prometheus           │ http://127.0.0.1:9090                  │"
echo "│ 📋 Kibana               │ http://127.0.0.1:5601                  │"
echo "│ 🔍 Jaeger               │ http://127.0.0.1:16686                 │"
echo "└─────────────────────────┴─────────────────────────────────────────┘"

echo ""
echo "🔑 Credenciales:"
echo "   • Grafana: admin / admin123"
echo "   • Otros servicios: Sin autenticación"

echo ""
echo "🎯 ABRIR FRONTEND PRINCIPAL:"
echo "   Frontend: http://127.0.0.1:8900/swagger-ui.html"

# Abrir automáticamente el frontend
case "$(uname -s)" in
    Darwin)  # macOS
        sleep 3 && open "http://127.0.0.1:8900/swagger-ui.html" &
        echo "✅ Abriendo frontend en macOS..."
        ;;
    Linux)   # Linux
        if command -v xdg-open > /dev/null; then
            sleep 3 && xdg-open "http://127.0.0.1:8900/swagger-ui.html" &
            echo "✅ Abriendo frontend en Linux..."
        fi
        ;;
esac

echo ""
echo "🛠️ COMANDOS ÚTILES:"
echo "   # Ver port-forwards activos:"
echo "   ps aux | grep 'kubectl.*port-forward'"
echo ""
echo "   # Detener todos los port-forwards:"
echo "   ./stop-port-forwards.sh"
echo ""
echo "   # Ver logs de un servicio:"
echo "   kubectl logs -f deployment/proxy-client -n ecommerce"

echo ""
echo "⚠️  NOTA: Los port-forwards se ejecutan en background."
echo "   Para detenerlos, ejecuta: ./stop-port-forwards.sh"
echo "   O usa Ctrl+C si los ejecutaste manualmente."

echo ""
echo "🎮 PARA USAR EL FRONTEND:"
echo "1. Ve a: http://127.0.0.1:8900/swagger-ui.html"
echo "2. Expande las secciones de APIs"
echo "3. Prueba endpoints como GET /api/users, GET /api/products"
echo "4. Crea datos con POST /api/users, POST /api/orders"

echo ""
echo "🎉 ¡Todo listo para usar!" 