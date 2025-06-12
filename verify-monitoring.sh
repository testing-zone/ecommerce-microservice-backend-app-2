#!/bin/bash

echo "🔍 VERIFICANDO PILA COMPLETA DE MONITOREO"
echo "========================================="
echo ""

# Función para verificar el estado de un deployment
check_deployment() {
    local name=$1
    local namespace=$2
    
    if kubectl get deployment "$name" -n "$namespace" &>/dev/null; then
        local ready=$(kubectl get deployment "$name" -n "$namespace" -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        local desired=$(kubectl get deployment "$name" -n "$namespace" -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")
        
        if [ "$ready" = "$desired" ] && [ "$ready" != "0" ]; then
            echo "✅ $name: $ready/$desired pods ready"
            return 0
        else
            echo "❌ $name: $ready/$desired pods ready"
            return 1
        fi
    else
        echo "❌ $name: No encontrado"
        return 1
    fi
}

# Función para verificar servicio y conectividad
check_service() {
    local service_name=$1
    local namespace=$2
    local port=$3
    local path=${4:-"/"}
    
    if kubectl get service "$service_name" -n "$namespace" &>/dev/null; then
        echo "✅ Servicio $service_name existe"
        
        # Verificar conectividad usando port-forward en background
        kubectl port-forward svc/"$service_name" "$port:$port" -n "$namespace" &>/dev/null &
        local pf_pid=$!
        sleep 3
        
        if curl -s "http://localhost:$port$path" &>/dev/null; then
            echo "✅ $service_name responde en puerto $port"
            kill $pf_pid 2>/dev/null
            return 0
        else
            echo "⚠️  $service_name no responde en puerto $port"
            kill $pf_pid 2>/dev/null
            return 1
        fi
    else
        echo "❌ Servicio $service_name no encontrado"
        return 1
    fi
}

# Obtener IP de minikube
MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "localhost")

echo "📊 1. VERIFICANDO PROMETHEUS..."
check_deployment "prometheus" "monitoring"
check_service "prometheus" "monitoring" "9090" "/-/healthy"

echo ""
echo "📈 2. VERIFICANDO GRAFANA..."
check_deployment "grafana" "monitoring"
check_service "grafana" "monitoring" "3000" "/api/health"

echo ""
echo "🔍 3. VERIFICANDO ELK STACK..."
echo "   Elasticsearch:"
check_deployment "elasticsearch" "monitoring"
check_service "elasticsearch" "monitoring" "9200" "/_cluster/health"

echo "   Logstash:"
check_deployment "logstash" "monitoring"

echo "   Kibana:"
check_deployment "kibana" "monitoring"
check_service "kibana" "monitoring" "5601" "/api/status"

echo ""
echo "🔍 4. VERIFICANDO JAEGER..."
check_deployment "jaeger" "monitoring"
check_service "jaeger" "monitoring" "16686" "/"

echo ""
echo "🚨 5. VERIFICANDO ALERTMANAGER..."
check_deployment "alertmanager" "monitoring"
check_service "alertmanager" "monitoring" "9093" "/-/healthy"

echo ""
echo "📋 6. VERIFICANDO FILEBEAT..."
if kubectl get daemonset filebeat -n monitoring &>/dev/null; then
    local ready=$(kubectl get daemonset filebeat -n monitoring -o jsonpath='{.status.numberReady}' 2>/dev/null || echo "0")
    local desired=$(kubectl get daemonset filebeat -n monitoring -o jsonpath='{.status.desiredNumberScheduled}' 2>/dev/null || echo "1")
    
    if [ "$ready" = "$desired" ] && [ "$ready" != "0" ]; then
        echo "✅ Filebeat DaemonSet: $ready/$desired pods ready"
    else
        echo "❌ Filebeat DaemonSet: $ready/$desired pods ready"
    fi
else
    echo "❌ Filebeat DaemonSet no encontrado"
fi

echo ""
echo "🏥 7. VERIFICANDO HEALTH CHECKS DE MICROSERVICIOS..."

# Verificar health checks de los microservicios
SERVICES=("user-service" "product-service" "order-service" "payment-service" "shipping-service" "favourite-service")

for service in "${SERVICES[@]}"; do
    if kubectl get deployment "$service" -n ecommerce &>/dev/null; then
        local ready=$(kubectl get deployment "$service" -n ecommerce -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
        local desired=$(kubectl get deployment "$service" -n ecommerce -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")
        
        if [ "$ready" = "$desired" ] && [ "$ready" != "0" ]; then
            echo "✅ $service: $ready/$desired pods ready con health checks"
        else
            echo "❌ $service: $ready/$desired pods ready"
        fi
    else
        echo "❌ $service: No encontrado"
    fi
done

echo ""
echo "🌐 8. VERIFICANDO ACCESO EXTERNO..."
echo "   NodePorts configurados:"

NODEPORTS=(
    "prometheus:30090"
    "grafana:30030"
    "kibana:30601"
    "jaeger:30686"
    "alertmanager:30093"
)

for nodeport in "${NODEPORTS[@]}"; do
    service_name=$(echo $nodeport | cut -d: -f1)
    port=$(echo $nodeport | cut -d: -f2)
    
    if kubectl get service "$service_name" -n monitoring -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null | grep -q "$port"; then
        echo "✅ $service_name disponible en :$port"
    else
        echo "❌ $service_name no disponible en :$port"
    fi
done

echo ""
echo "📊 9. RESUMEN DE PODS DE MONITOREO:"
kubectl get pods -n monitoring -o wide 2>/dev/null || echo "❌ No se pueden obtener pods del namespace monitoring"

echo ""
echo "📊 10. RESUMEN DE SERVICIOS DE MONITOREO:"
kubectl get services -n monitoring 2>/dev/null || echo "❌ No se pueden obtener servicios del namespace monitoring"

echo ""
echo "🎯 11. URLS DE ACCESO DIRECTO:"
echo "┌─────────────────┬─────────────────────────────────────┐"
echo "│ Servicio        │ URL                                 │"
echo "├─────────────────┼─────────────────────────────────────┤"
echo "│ Prometheus      │ http://${MINIKUBE_IP}:30090         │"
echo "│ Grafana         │ http://${MINIKUBE_IP}:30030         │"
echo "│ Kibana          │ http://${MINIKUBE_IP}:30601         │"
echo "│ Jaeger          │ http://${MINIKUBE_IP}:30686         │"
echo "│ AlertManager    │ http://${MINIKUBE_IP}:30093         │"
echo "└─────────────────┴─────────────────────────────────────┘"

echo ""
echo "🔑 12. CREDENCIALES:"
echo "   • Grafana: admin / admin123"
echo "   • Kibana: Sin autenticación"
echo "   • Prometheus: Sin autenticación"
echo "   • Jaeger: Sin autenticación"

echo ""
echo "📋 13. COMANDOS ÚTILES:"
echo "   # Ver logs de cualquier componente:"
echo "   kubectl logs -f deployment/prometheus -n monitoring"
echo "   kubectl logs -f deployment/grafana -n monitoring"
echo "   kubectl logs -f deployment/elasticsearch -n monitoring"
echo ""
echo "   # Port-forward para acceso local:"
echo "   kubectl port-forward svc/grafana 3000:3000 -n monitoring"
echo "   kubectl port-forward svc/prometheus 9090:9090 -n monitoring"
echo ""
echo "   # Verificar métricas:"
echo "   curl http://${MINIKUBE_IP}:30090/api/v1/targets"
echo "   curl http://${MINIKUBE_IP}:30090/api/v1/query?query=up"

echo ""
echo "🎉 VERIFICACIÓN COMPLETADA!" 