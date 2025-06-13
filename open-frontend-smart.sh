#!/bin/bash

echo "🌐 DETECTOR INTELIGENTE DE INTERFACES WEB"
echo "========================================="

# Función para detectar port-forwards activos
detect_port_forwards() {
    echo "🔍 Detectando port-forwards activos..."
    
    # Detectar port-forwards de kubectl
    GRAFANA_LOCAL=""
    PROMETHEUS_LOCAL=""
    FRONTEND_LOCAL=""
    API_GATEWAY_LOCAL=""
    SERVICE_DISCOVERY_LOCAL=""
    
    # Buscar procesos kubectl port-forward
    if command -v pgrep >/dev/null 2>&1; then
        # En sistemas Unix-like
        for pid in $(pgrep -f "kubectl.*port-forward" 2>/dev/null); do
            if ps -p $pid -o args= 2>/dev/null | grep -q "grafana.*3000"; then
                local port=$(ps -p $pid -o args= | grep -o "3000:[0-9]*" | cut -d: -f2)
                if [ -n "$port" ]; then
                    GRAFANA_LOCAL="http://127.0.0.1:$port"
                fi
            fi
            
            if ps -p $pid -o args= 2>/dev/null | grep -q "prometheus.*9090"; then
                local port=$(ps -p $pid -o args= | grep -o "9090:[0-9]*" | cut -d: -f2)
                if [ -n "$port" ]; then
                    PROMETHEUS_LOCAL="http://127.0.0.1:$port"
                fi
            fi
            
            if ps -p $pid -o args= 2>/dev/null | grep -q "proxy-client.*8900"; then
                local port=$(ps -p $pid -o args= | grep -o "8900:[0-9]*" | cut -d: -f2)
                if [ -n "$port" ]; then
                    FRONTEND_LOCAL="http://127.0.0.1:$port/swagger-ui.html"
                fi
            fi
        done
    fi
    
    # Verificar puertos locales comunes
    for port in 51977 51976 51975 51974 51973; do
        if curl -s --max-time 2 "http://127.0.0.1:$port/api/health" >/dev/null 2>&1; then
            GRAFANA_LOCAL="http://127.0.0.1:$port"
            break
        fi
    done
    
    for port in 51972 51971 51970 51969 51968; do
        if curl -s --max-time 2 "http://127.0.0.1:$port/-/healthy" >/dev/null 2>&1; then
            PROMETHEUS_LOCAL="http://127.0.0.1:$port"
            break
        fi
    done
    
    for port in 51967 51966 51965 51964 51963; do
        if curl -s --max-time 2 "http://127.0.0.1:$port/swagger-ui.html" >/dev/null 2>&1; then
            FRONTEND_LOCAL="http://127.0.0.1:$port/swagger-ui.html"
            break
        fi
    done
}

# Función para verificar NodePorts con Minikube
check_minikube_nodeports() {
    echo "🔍 Verificando NodePorts con Minikube..."
    
    MINIKUBE_IP=$(minikube ip 2>/dev/null)
    
    if [ -n "$MINIKUBE_IP" ]; then
        echo "✅ Minikube IP: $MINIKUBE_IP"
        
        # URLs con NodePorts
        FRONTEND_NODEPORT="http://$MINIKUBE_IP:8900/swagger-ui.html"
        GRAFANA_NODEPORT="http://$MINIKUBE_IP:30030"
        PROMETHEUS_NODEPORT="http://$MINIKUBE_IP:30090"
        API_GATEWAY_NODEPORT="http://$MINIKUBE_IP:8080"
        SERVICE_DISCOVERY_NODEPORT="http://$MINIKUBE_IP:8761"
    else
        echo "⚠️  Minikube no está disponible o no se puede obtener la IP"
    fi
}

# Función para verificar disponibilidad de una URL
check_url() {
    local url=$1
    local timeout=${2:-3}
    
    if curl -s --max-time $timeout "$url" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Función principal para mostrar servicios disponibles
show_available_services() {
    echo ""
    echo "🚀 SERVICIOS DISPONIBLES:"
    echo "┌─────────────────────────┬─────────────────────────────────────────┬────────────┐"
    echo "│ Servicio                │ URL                                     │ Estado     │"
    echo "├─────────────────────────┼─────────────────────────────────────────┼────────────┤"
    
    # Frontend
    if [ -n "$FRONTEND_LOCAL" ] && check_url "$FRONTEND_LOCAL"; then
        echo "│ 🎯 Frontend (Swagger)   │ $FRONTEND_LOCAL │ ✅ Port-Forward │"
        MAIN_FRONTEND="$FRONTEND_LOCAL"
    elif [ -n "$FRONTEND_NODEPORT" ] && check_url "$FRONTEND_NODEPORT"; then
        echo "│ 🎯 Frontend (Swagger)   │ $FRONTEND_NODEPORT │ ✅ NodePort    │"
        MAIN_FRONTEND="$FRONTEND_NODEPORT"
    else
        echo "│ 🎯 Frontend (Swagger)   │ No disponible                           │ ❌ Offline    │"
        MAIN_FRONTEND=""
    fi
    
    # Grafana
    if [ -n "$GRAFANA_LOCAL" ] && check_url "$GRAFANA_LOCAL/api/health"; then
        echo "│ 📊 Grafana              │ $GRAFANA_LOCAL │ ✅ Port-Forward │"
        MAIN_GRAFANA="$GRAFANA_LOCAL"
    elif [ -n "$GRAFANA_NODEPORT" ] && check_url "$GRAFANA_NODEPORT/api/health"; then
        echo "│ 📊 Grafana              │ $GRAFANA_NODEPORT │ ✅ NodePort    │"
        MAIN_GRAFANA="$GRAFANA_NODEPORT"
    else
        echo "│ 📊 Grafana              │ No disponible                           │ ❌ Offline    │"
        MAIN_GRAFANA=""
    fi
    
    # Prometheus
    if [ -n "$PROMETHEUS_LOCAL" ] && check_url "$PROMETHEUS_LOCAL/-/healthy"; then
        echo "│ 📈 Prometheus           │ $PROMETHEUS_LOCAL │ ✅ Port-Forward │"
        MAIN_PROMETHEUS="$PROMETHEUS_LOCAL"
    elif [ -n "$PROMETHEUS_NODEPORT" ] && check_url "$PROMETHEUS_NODEPORT/-/healthy"; then
        echo "│ 📈 Prometheus           │ $PROMETHEUS_NODEPORT │ ✅ NodePort    │"
        MAIN_PROMETHEUS="$PROMETHEUS_NODEPORT"
    else
        echo "│ 📈 Prometheus           │ No disponible                           │ ❌ Offline    │"
        MAIN_PROMETHEUS=""
    fi
    
    # API Gateway
    if [ -n "$API_GATEWAY_NODEPORT" ] && check_url "$API_GATEWAY_NODEPORT"; then
        echo "│ 🚪 API Gateway          │ $API_GATEWAY_NODEPORT │ ✅ Disponible │"
    else
        echo "│ 🚪 API Gateway          │ No disponible                           │ ❌ Offline    │"
    fi
    
    # Service Discovery
    if [ -n "$SERVICE_DISCOVERY_NODEPORT" ] && check_url "$SERVICE_DISCOVERY_NODEPORT"; then
        echo "│ 🔍 Service Discovery    │ $SERVICE_DISCOVERY_NODEPORT │ ✅ Disponible │"
    else
        echo "│ 🔍 Service Discovery    │ No disponible                           │ ❌ Offline    │"
    fi
    
    echo "└─────────────────────────┴─────────────────────────────────────────┴────────────┘"
}

# Detectar configuración actual
detect_port_forwards
check_minikube_nodeports

# Mostrar servicios disponibles
show_available_services

echo ""
echo "🔑 Credenciales:"
echo "   • Grafana: admin / admin123"
echo "   • Otros servicios: Sin autenticación"

echo ""
if [ -n "$MAIN_FRONTEND" ]; then
    echo "🎯 ABRIENDO FRONTEND PRINCIPAL..."
    echo "   URL: $MAIN_FRONTEND"
    
    # Detectar el sistema operativo y abrir el navegador
    case "$(uname -s)" in
        Darwin)  # macOS
            open "$MAIN_FRONTEND"
            echo "✅ Abriendo en macOS..."
            ;;
        Linux)   # Linux
            if command -v xdg-open > /dev/null; then
                xdg-open "$MAIN_FRONTEND"
                echo "✅ Abriendo en Linux..."
            else
                echo "💡 Abre manualmente: $MAIN_FRONTEND"
            fi
            ;;
        CYGWIN*|MINGW*|MSYS*) # Windows
            start "$MAIN_FRONTEND"
            echo "✅ Abriendo en Windows..."
            ;;
        *)
            echo "💡 Abre manualmente: $MAIN_FRONTEND"
            ;;
    esac
else
    echo "❌ Frontend no está disponible"
    echo ""
    echo "🛠️ OPCIONES PARA ACCEDER:"
    echo "   1. Usar port-forward:"
    echo "      kubectl port-forward svc/proxy-client 8900:8900 -n ecommerce &"
    echo "      # Luego accede a: http://127.0.0.1:8900/swagger-ui.html"
    echo ""
    echo "   2. Verificar que los pods estén ejecutándose:"
    echo "      kubectl get pods -n ecommerce"
    echo ""
    echo "   3. Ver logs del proxy-client:"
    echo "      kubectl logs -f deployment/proxy-client -n ecommerce"
fi

echo ""
echo "🎮 CÓMO USAR EL FRONTEND:"
echo "1. En Swagger UI, expandir las secciones de APIs"
echo "2. Probar endpoints como:"
echo "   • GET /api/users - Listar usuarios"
echo "   • GET /api/products - Listar productos"
echo "   • POST /api/users - Crear usuario"
echo "   • POST /api/orders - Crear orden"

if [ -n "$MAIN_GRAFANA" ]; then
    echo ""
    echo "📊 MONITOREO DISPONIBLE:"
    echo "   • Grafana: $MAIN_GRAFANA (admin/admin123)"
    if [ -n "$MAIN_PROMETHEUS" ]; then
        echo "   • Prometheus: $MAIN_PROMETHEUS"
    fi
fi

echo ""
echo "🛠️ COMANDOS ÚTILES PARA PORT-FORWARD:"
echo "   # Frontend:"
echo "   kubectl port-forward svc/proxy-client 8900:8900 -n ecommerce &"
echo ""
echo "   # Grafana:"
echo "   kubectl port-forward svc/grafana 3000:3000 -n monitoring &"
echo ""
echo "   # Prometheus:"
echo "   kubectl port-forward svc/prometheus 9090:9090 -n monitoring &"

echo ""
echo "🎉 Detección completada!" 