#!/bin/bash

echo "🎯 GENERANDO DATOS PARA MONITOREO"
echo "================================="
echo ""
echo "📋 Este script generará tráfico y datos para verificar:"
echo "   • Métricas en Prometheus"
echo "   • Logs en ELK Stack"
echo "   • Trazas en Jaeger"
echo "   • Alertas en AlertManager"
echo ""

# Configuración
NAMESPACE="ecommerce"
MONITORING_NAMESPACE="monitoring"
SERVICES=(
    "user-service"
    "product-service"
    "order-service"
    "payment-service"
    "shipping-service"
    "favourite-service"
)

# Endpoints válidos e inválidos para pruebas
VALID_ENDPOINTS=(
    "/"
    "/actuator/health"
    "/actuator/metrics"
)

INVALID_ENDPOINTS=(
    "/notfound"
    "/error/500"
    "/admin/unauthorized"
)

# Función para verificar conectividad de servicios
verify_services() {
    echo "🔍 1. VERIFICANDO QUE LOS SERVICIOS ESTÉN UP..."
    echo "=============================================="
    
    # Verificar que el namespace existe
    if ! kubectl get namespace $NAMESPACE &>/dev/null; then
        echo "❌ Namespace '$NAMESPACE' no existe"
        return 1
    fi
    
    # Verificar pods de microservicios
    echo "📋 Estado de pods en namespace $NAMESPACE:"
    kubectl get pods -n $NAMESPACE --no-headers | while read line; do
        pod_name=$(echo $line | awk '{print $1}')
        pod_status=$(echo $line | awk '{print $3}')
        if [[ $pod_status == "Running" ]]; then
            echo "✅ $pod_name: $pod_status"
        else
            echo "❌ $pod_name: $pod_status"
        fi
    done
    
    echo ""
    echo "🌐 Verificando servicios expuestos:"
    for service in "${SERVICES[@]}"; do
        if kubectl get service $service -n $NAMESPACE &>/dev/null; then
            ports=$(kubectl get service $service -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
            if [[ -n $ports ]]; then
                echo "✅ $service: NodePort $ports"
            else
                echo "⚠️  $service: Existe pero sin NodePort"
            fi
        else
            echo "❌ $service: No encontrado"
        fi
    done
    
    echo ""
}

# Función para obtener URL de servicio
get_service_url() {
    local service=$1
    local url
    
    # Intentar obtener URL con minikube service
    url=$(minikube service $service -n $NAMESPACE --url 2>/dev/null | head -1)
    
    if [[ -n $url ]]; then
        echo $url
        return 0
    fi
    
    # Fallback: usar IP de minikube + NodePort
    local minikube_ip=$(minikube ip 2>/dev/null)
    local nodeport=$(kubectl get service $service -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}' 2>/dev/null)
    
    if [[ -n $minikube_ip ]] && [[ -n $nodeport ]]; then
        echo "http://$minikube_ip:$nodeport"
        return 0
    fi
    
    return 1
}

# Función para hacer request y mostrar detalles
make_request() {
    local service=$1
    local url=$2
    local endpoint=$3
    local full_url="${url}${endpoint}"
    local method="GET"
    local response_code
    local response_body
    local temp_file=$(mktemp)
    
    response_code=$(curl -s -o "$temp_file" -w "%{http_code}" -X $method "$full_url" 2>/dev/null)
    response_body=$(cat "$temp_file" 2>/dev/null)
    rm -f "$temp_file"
    
    echo "[$service] $method $full_url => $response_code"
    
    # Mostrar body si hay error
    if [[ $response_code -ge 400 ]]; then
        if [[ -n $response_body ]]; then
            echo "   Body: ${response_body:0:100}..."
        fi
    fi
    
    return $response_code
}

# Función para generar tráfico normal
generate_normal_traffic() {
    echo "📊 2. GENERANDO TRÁFICO NORMAL PARA DASHBOARDS..."
    echo "=============================================="
    
    for service in "${SERVICES[@]}"; do
        echo ""
        echo "🔄 Testeando $service..."
        
        local service_url=$(get_service_url $service)
        if [[ -z $service_url ]]; then
            echo "❌ No se pudo obtener URL de $service"
            continue
        fi
        
        echo "   URL detectada: $service_url"
        
        # Hacer requests a endpoints válidos
        for endpoint in "${VALID_ENDPOINTS[@]}"; do
            for i in $(seq 1 3); do
                make_request $service $service_url $endpoint
                sleep 0.5
            done
        done
        
        echo "✅ Tráfico normal generado para $service"
    done
}

# Función para generar errores controlados
generate_error_traffic() {
    echo ""
    echo "🚨 3. GENERANDO ERRORES CONTROLADOS PARA ALERTAS..."
    echo "=============================================="
    
    for service in "${SERVICES[@]}"; do
        echo ""
        echo "🚨 Generando errores en $service..."
        
        local service_url=$(get_service_url $service)
        if [[ -z $service_url ]]; then
            echo "❌ No se pudo obtener URL de $service"
            continue
        fi
        
        # Hacer requests a endpoints inválidos para generar errores
        for endpoint in "${INVALID_ENDPOINTS[@]}"; do
            make_request $service $service_url $endpoint
            sleep 1
        done
        
        echo "✅ Errores generados para $service"
    done
}

# Función para verificar componentes de monitoreo
verify_monitoring_stack() {
    echo ""
    echo "📈 4. VERIFICANDO STACK DE MONITOREO..."
    echo "======================================"
    
    # Verificar Prometheus
    echo "🔍 Verificando Prometheus..."
    local prom_url=$(minikube service prometheus -n $MONITORING_NAMESPACE --url 2>/dev/null | head -1)
    if [[ -n $prom_url ]]; then
        if curl -s "$prom_url/-/healthy" &>/dev/null; then
            echo "✅ Prometheus: $prom_url"
            
            # Verificar targets
            local targets=$(curl -s "$prom_url/api/v1/targets" 2>/dev/null | grep -c '"health":"up"')
            echo "   Targets UP: $targets"
        else
            echo "❌ Prometheus no responde"
        fi
    else
        echo "❌ No se pudo obtener URL de Prometheus"
    fi
    
    # Verificar Grafana
    echo "🔍 Verificando Grafana..."
    local grafana_url=$(minikube service grafana -n $MONITORING_NAMESPACE --url 2>/dev/null | head -1)
    if [[ -n $grafana_url ]]; then
        if curl -s "$grafana_url/api/health" &>/dev/null; then
            echo "✅ Grafana: $grafana_url"
        else
            echo "❌ Grafana no responde"
        fi
    else
        echo "❌ No se pudo obtener URL de Grafana"
    fi
    
    # Verificar Kibana
    echo "🔍 Verificando Kibana..."
    local kibana_url=$(minikube service kibana -n $MONITORING_NAMESPACE --url 2>/dev/null | head -1)
    if [[ -n $kibana_url ]]; then
        if curl -s "$kibana_url/api/status" &>/dev/null; then
            echo "✅ Kibana: $kibana_url"
        else
            echo "❌ Kibana no responde"
        fi
    else
        echo "❌ No se pudo obtener URL de Kibana"
    fi
    
    # Verificar Jaeger
    echo "🔍 Verificando Jaeger..."
    local jaeger_url=$(minikube service jaeger -n $MONITORING_NAMESPACE --url 2>/dev/null | head -1)
    if [[ -n $jaeger_url ]]; then
        if curl -s "$jaeger_url/" &>/dev/null; then
            echo "✅ Jaeger: $jaeger_url"
        else
            echo "❌ Jaeger no responde"
        fi
    else
        echo "❌ No se pudo obtener URL de Jaeger"
    fi
}

# Función principal
main() {
    # Verificar prerrequisitos
    if ! command -v kubectl &> /dev/null; then
        echo "❌ kubectl no está instalado"
        exit 1
    fi
    
    if ! command -v minikube &> /dev/null; then
        echo "❌ minikube no está instalado"
        exit 1
    fi
    
    # Ejecutar verificaciones y generación de tráfico
    verify_services
    
    # Solo continuar si los servicios están OK
    echo ""
    read -p "¿Continuar con la generación de tráfico? [y/N]: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        generate_normal_traffic
        generate_error_traffic
        verify_monitoring_stack
        
        echo ""
        echo "✅ GENERACIÓN DE DATOS COMPLETADA"
        echo "================================="
        echo "🔍 Revisa tus dashboards en:"
        echo "   • Grafana: para métricas y alertas"
        echo "   • Kibana: para logs de errores"
        echo "   • Jaeger: para trazas distribuidas"
        echo "   • Prometheus: para métricas raw"
        echo ""
        echo "💡 Espera 1-2 minutos para ver los datos reflejados"
    else
        echo "❌ Operación cancelada"
    fi
}

# Ejecutar script
main 