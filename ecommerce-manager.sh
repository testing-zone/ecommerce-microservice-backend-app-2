#!/bin/bash

# ============================================================================
# GESTOR PRINCIPAL E-COMMERCE MICROSERVICES
# ============================================================================
# Script maestro con menú interactivo para gestionar todo el proyecto:
# - Despliegue completo
# - Componentes individuales  
# - Verificaciones y diagnósticos
# - Limpieza y organización
# - Port-forwarding para acceso externo
# ============================================================================

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$PROJECT_ROOT/ecommerce-manager.log"

# ASCII Art para estados (versiones compactas)
ASCII_SUCCESS="
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠶⠚⠉⢉⣩⠽⠟⠛⠛⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡞⠁⠀⠀⣰⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"

ASCII_ERROR="
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⠶⣻⠝⠋⠠⠔⠛⠁⡀⠀⠈⢉⡙⠓⠶⣄⡀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⢋⣴⡮⠓⠋⠀⠀⢄⠀⠀⠉⠢⣄⠀⠈⠁⠀⡀⠙⢶⣄⠀⠀⠀⠀"

# Funciones de utilidad
print_header() {
    clear
    echo "============================================================================"
    echo "                    🚀 E-COMMERCE MICROSERVICES MANAGER"
    echo "============================================================================"
    echo ""
}

print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "success")
            echo "$ASCII_SUCCESS"
            echo "✅ SUCCESS: $message"
            ;;
        "error")
            echo "$ASCII_ERROR"  
            echo "❌ ERROR: $message"
            ;;
        "info")
            echo "ℹ️  INFO: $message"
            ;;
        "warning")
            echo "⚠️  WARNING: $message"
            ;;
    esac
}

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_prerequisites() {
    echo "🔍 Verificando prerequisitos..."
    local failed=0
    
    for tool in kubectl minikube docker curl; do
        if ! command -v $tool &> /dev/null; then
            echo "❌ $tool no está instalado"
            failed=1
        else
            echo "✅ $tool disponible"
        fi
    done
    
    if [ $failed -eq 1 ]; then
        print_status "error" "Faltan prerequisitos. Instala las herramientas faltantes."
        return 1
    fi
    
    return 0
}

# Función para crear namespaces necesarios
create_namespaces() {
    echo "🏗️  Creando namespaces necesarios..."
    
    # Crear namespace ecommerce
    if ! kubectl get namespace ecommerce &> /dev/null; then
        echo "📦 Creando namespace 'ecommerce'..."
        kubectl create namespace ecommerce
        echo "✅ Namespace 'ecommerce' creado"
    else
        echo "✅ Namespace 'ecommerce' ya existe"
    fi
    
    # Crear namespace monitoring
    if ! kubectl get namespace monitoring &> /dev/null; then
        echo "📊 Creando namespace 'monitoring'..."
        kubectl create namespace monitoring
        echo "✅ Namespace 'monitoring' creado"
    else
        echo "✅ Namespace 'monitoring' ya existe"
    fi
    
    echo ""
}

# Función para configurar port-forwarding externo
setup_external_port_forwarding() {
    print_header
    echo "🌐 CONFIGURANDO PORT-FORWARDING PARA ACCESO EXTERNO"
    echo "============================================================================"
    echo ""
    
    local minikube_ip=$(minikube ip 2>/dev/null || echo "N/A")
    
    if [[ $minikube_ip == "N/A" ]]; then
        print_status "error" "Minikube no está ejecutándose"
        return 1
    fi
    
    echo "🔧 IP de Minikube: $minikube_ip"
    echo ""
    echo "Configurando port-forwarding para acceso desde fuera de la VM..."
    echo ""
    
    # Detener port-forwards existentes
    echo "🛑 Deteniendo port-forwards existentes..."
    pkill -f "kubectl port-forward" 2>/dev/null || true
    sleep 2
    
    echo "🚀 Iniciando port-forwards externos..."
    
    # Port-forward para microservicios (binding a 0.0.0.0 para acceso externo)
    if kubectl get service proxy-client -n ecommerce &> /dev/null; then
        echo "  📱 Proxy Client (Frontend) -> 0.0.0.0:8900"
        kubectl port-forward svc/proxy-client 8900:8900 -n ecommerce --address=0.0.0.0 &
        sleep 1
    fi
    
    if kubectl get service api-gateway -n ecommerce &> /dev/null; then
        echo "  🚪 API Gateway -> 0.0.0.0:8080"
        kubectl port-forward svc/api-gateway 8080:8080 -n ecommerce --address=0.0.0.0 &
        sleep 1
    fi
    
    if kubectl get service service-discovery -n ecommerce &> /dev/null; then
        echo "  🔍 Service Discovery -> 0.0.0.0:8761"
        kubectl port-forward svc/service-discovery 8761:8761 -n ecommerce --address=0.0.0.0 &
        sleep 1
    fi
    
    # Port-forward para servicios individuales
    local services=("user-service:8700:8087" "product-service:8500:8082" "order-service:8300:8083" "payment-service:8400:8084" "shipping-service:8600:8085" "favourite-service:8800:8086")
    
    for service_config in "${services[@]}"; do
        IFS=':' read -r service local_port target_port <<< "$service_config"
        if kubectl get service "$service" -n ecommerce &> /dev/null; then
            echo "  🔧 $service -> 0.0.0.0:$local_port"
            kubectl port-forward svc/"$service" "$local_port:$target_port" -n ecommerce --address=0.0.0.0 &
            sleep 1
        fi
    done
    
    # Port-forward para servicios de monitoreo
    echo ""
    echo "📊 Configurando monitoreo..."
    
    local monitoring_services=("grafana:3000:3000" "prometheus:9090:9090" "kibana:5601:5601" "jaeger:16686:16686" "alertmanager:9093:9093")
    
    for service_config in "${monitoring_services[@]}"; do
        IFS=':' read -r service local_port target_port <<< "$service_config"
        if kubectl get service "$service" -n monitoring &> /dev/null; then
            echo "  📈 $service -> 0.0.0.0:$local_port"
            kubectl port-forward svc/"$service" "$local_port:$target_port" -n monitoring --address=0.0.0.0 &
            sleep 1
        fi
    done
    
    sleep 3
    
    echo ""
    echo "🎉 PORT-FORWARDING CONFIGURADO!"
    echo "============================================================================"
    echo ""
    echo "🌐 URLs DE ACCESO EXTERNO (desde cualquier IP):"
    echo ""
    echo "🛍️  FRONTEND E-COMMERCE:"
    echo "   Frontend Principal: http://$minikube_ip:8900/swagger-ui.html"
    echo "   API Gateway:        http://$minikube_ip:8080"
    echo "   Service Discovery:  http://$minikube_ip:8761"
    echo ""
    echo "🔧 MICROSERVICIOS INDIVIDUALES:"
    echo "   User Service:       http://$minikube_ip:8700/actuator/health"
    echo "   Product Service:    http://$minikube_ip:8500/actuator/health"
    echo "   Order Service:      http://$minikube_ip:8300/actuator/health"
    echo "   Payment Service:    http://$minikube_ip:8400/actuator/health"
    echo "   Shipping Service:   http://$minikube_ip:8600/actuator/health"
    echo "   Favourite Service:  http://$minikube_ip:8800/actuator/health"
    echo ""
    echo "📊 MONITOREO Y OBSERVABILIDAD:"
    echo "   Grafana:            http://$minikube_ip:3000 (admin/admin123)"
    echo "   Prometheus:         http://$minikube_ip:9090"
    echo "   Kibana:             http://$minikube_ip:5601"
    echo "   Jaeger:             http://$minikube_ip:16686"
    echo "   AlertManager:       http://$minikube_ip:9093"
    echo ""
    echo "💡 NOTA: Estas URLs son accesibles desde cualquier dispositivo en la red"
    echo "    que tenga acceso a la VM con IP: $minikube_ip"
    echo ""
    echo "🛑 Para detener port-forwards: pkill -f 'kubectl port-forward'"
    echo ""
    
    # Guardar información de acceso
    cat > "$PROJECT_ROOT/external-access-info.txt" << EOF
# INFORMACIÓN DE ACCESO EXTERNO
# Generado: $(date)
# IP de Minikube: $minikube_ip

## FRONTEND E-COMMERCE
Frontend Principal: http://$minikube_ip:8900/swagger-ui.html
API Gateway: http://$minikube_ip:8080
Service Discovery: http://$minikube_ip:8761

## MICROSERVICIOS
User Service: http://$minikube_ip:8700/actuator/health
Product Service: http://$minikube_ip:8500/actuator/health
Order Service: http://$minikube_ip:8300/actuator/health
Payment Service: http://$minikube_ip:8400/actuator/health
Shipping Service: http://$minikube_ip:8600/actuator/health
Favourite Service: http://$minikube_ip:8800/actuator/health

## MONITOREO
Grafana: http://$minikube_ip:3000 (admin/admin123)
Prometheus: http://$minikube_ip:9090
Kibana: http://$minikube_ip:5601
Jaeger: http://$minikube_ip:16686
AlertManager: http://$minikube_ip:9093

# Para detener port-forwards: pkill -f 'kubectl port-forward'
EOF
    
    echo "📄 Información guardada en: external-access-info.txt"
    echo ""
    echo "Presiona Enter para continuar..."
    read
}

check_services_status() {
    print_header
    echo "📊 ESTADO ACTUAL DE SERVICIOS"
    echo "============================================================================"
    echo ""
    
    # Verificar minikube
    echo "🔍 Minikube:"
    if minikube status &> /dev/null; then
        echo "  ✅ Corriendo (IP: $(minikube ip 2>/dev/null || echo 'N/A'))"
    else
        echo "  ❌ Detenido"
    fi
    echo ""
    
    # Verificar namespaces
    echo "🏗️  Namespaces:"
    if kubectl get namespace ecommerce &> /dev/null; then
        echo "  ✅ ecommerce: Existe"
    else
        echo "  ❌ ecommerce: No existe"
    fi
    
    if kubectl get namespace monitoring &> /dev/null; then
        echo "  ✅ monitoring: Existe"
    else
        echo "  ❌ monitoring: No existe"
    fi
    echo ""
    
    # Verificar Jenkins
    echo "🔍 Jenkins:"
    if curl -s http://localhost:8081 &> /dev/null; then
        echo "  ✅ Accesible en http://localhost:8081"
    else
        echo "  ❌ No accesible"
    fi
    echo ""
    
    # Verificar microservicios
    echo "🔍 Microservicios (namespace: ecommerce):"
    local services=("user-service" "product-service" "order-service" "payment-service" "shipping-service" "favourite-service" "proxy-client" "api-gateway" "service-discovery")
    for service in "${services[@]}"; do
        local status=$(kubectl get pod -l app=$service -n ecommerce --no-headers 2>/dev/null | awk '{print $3}' | head -1)
        if [[ $status == "Running" ]]; then
            echo "  ✅ $service: Running"
        elif [[ -n $status ]]; then
            echo "  ⚠️  $service: $status"
        else
            echo "  ❌ $service: No encontrado"
        fi
    done
    echo ""
    
    # Verificar monitoreo
    echo "🔍 Stack de Monitoreo (namespace: monitoring):"
    local monitoring=("prometheus" "grafana" "kibana" "jaeger" "alertmanager")
    for service in "${monitoring[@]}"; do
        local status=$(kubectl get pod -l app=$service -n monitoring --no-headers 2>/dev/null | awk '{print $3}' | head -1)
        if [[ $status == "Running" ]]; then
            echo "  ✅ $service: Running"
        elif [[ -n $status ]]; then
            echo "  ⚠️  $service: $status"
        else
            echo "  ❌ $service: No encontrado"
        fi
    done
    echo ""
    
    # Verificar port-forwards activos
    echo "🌐 Port-forwards activos:"
    local pf_count=$(ps aux | grep -c "kubectl port-forward" | grep -v grep || echo "0")
    if [ "$pf_count" -gt 0 ]; then
        echo "  ✅ $pf_count port-forward(s) activo(s)"
        ps aux | grep "kubectl port-forward" | grep -v grep | while read line; do
            echo "    🔗 $(echo $line | awk '{for(i=11;i<=NF;i++) printf "%s ", $i; print ""}')"
        done
    else
        echo "  ❌ No hay port-forwards activos"
    fi
    echo ""
    
    echo "Presiona Enter para continuar..."
    read
}

show_access_urls() {
    print_header
    echo "🌐 URLS DE ACCESO A SERVICIOS"
    echo "============================================================================"
    echo ""
    
    local minikube_ip=$(minikube ip 2>/dev/null || echo "N/A")
    
    echo "🔧 JENKINS CI/CD:"
    echo "   URL: http://localhost:8081"
    echo ""
    
    echo "🛍️  MICROSERVICIOS E-COMMERCE:"
    if [[ $minikube_ip != "N/A" ]]; then
        echo "   Frontend (Swagger UI): http://$minikube_ip:8900/swagger-ui.html"
        echo "   API Gateway:           http://$minikube_ip:8080"
        echo "   Service Discovery:     http://$minikube_ip:8761"
        echo ""
        echo "   Servicios individuales:"
        echo "   user-service:          http://$minikube_ip:8700"
        echo "   product-service:       http://$minikube_ip:8500"
        echo "   order-service:         http://$minikube_ip:8300"
        echo "   payment-service:       http://$minikube_ip:8400"
        echo "   shipping-service:      http://$minikube_ip:8600"
        echo "   favourite-service:     http://$minikube_ip:8800"
    else
        echo "   ❌ Minikube no está corriendo"
    fi
    echo ""
    
    echo "📊 SERVICIOS DE MONITOREO:"
    if [[ $minikube_ip != "N/A" ]]; then
        echo "   Grafana:        http://$minikube_ip:3000 (admin/admin123)"
        echo "   Prometheus:     http://$minikube_ip:9090"
        echo "   Kibana:         http://$minikube_ip:5601"
        echo "   Jaeger:         http://$minikube_ip:16686"
        echo "   AlertManager:   http://$minikube_ip:9093"
    else
        echo "   ❌ Minikube no está corriendo"
    fi
    echo ""
    
    if [ -f "$PROJECT_ROOT/external-access-info.txt" ]; then
        echo "📋 Información detallada de acceso: external-access-info.txt"
        echo ""
    fi
    
    echo "Presiona Enter para continuar..."
    read
}

deploy_complete() {
    print_header
    echo "🚀 DESPLIEGUE COMPLETO DEL SISTEMA"
    echo "============================================================================"
    echo ""
    echo "Esto desplegará:"
    echo "  • Namespaces necesarios (ecommerce, monitoring)"
    echo "  • Jenkins CI/CD"
    echo "  • 6 Microservicios de E-commerce"
    echo "  • Stack completo de Monitoreo"
    echo "  • Port-forwarding para acceso externo"
    echo "  • Tests de Performance"
    echo "  • Generación de datos de prueba"
    echo ""
    echo "Duración estimada: 10-15 minutos"
    echo ""
    
    read -p "¿Continuar con el despliegue completo? [y/N]: " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    # Crear namespaces primero
    create_namespaces
    
    # Ejecutar despliegue de microservicios
    echo "📦 Desplegando microservicios..."
    if [ -f "$PROJECT_ROOT/DEPLOY_ALL_MICROSERVICES.sh" ]; then
        chmod +x "$PROJECT_ROOT/DEPLOY_ALL_MICROSERVICES.sh"
        bash "$PROJECT_ROOT/DEPLOY_ALL_MICROSERVICES.sh"
    else
        print_status "error" "Script DEPLOY_ALL_MICROSERVICES.sh no encontrado"
        return 1
    fi
    
    # Ejecutar despliegue de monitoreo
    echo "📊 Desplegando stack de monitoreo..."
    if [ -f "$PROJECT_ROOT/deploy-monitoring.sh" ]; then
        chmod +x "$PROJECT_ROOT/deploy-monitoring.sh"
        bash "$PROJECT_ROOT/deploy-monitoring.sh"
    else
        print_status "warning" "Script deploy-monitoring.sh no encontrado, saltando monitoreo"
    fi
    
    # Esperar a que los pods estén listos
    echo "⏱️  Esperando que los servicios estén listos..."
    sleep 30
    
    # Configurar port-forwarding externo
    echo "🌐 Configurando acceso externo..."
    setup_external_port_forwarding
    
    print_status "success" "Despliegue completo finalizado"
    
    echo ""
    echo "Presiona Enter para continuar..."
    read
}

deploy_jenkins_only() {
    print_header
    echo "🔧 DESPLIEGUE SOLO DE JENKINS"
    echo "============================================================================"
    
    if [ -f "$PROJECT_ROOT/pipeline/setup-jenkins.sh" ]; then
        chmod +x "$PROJECT_ROOT/pipeline/setup-jenkins.sh"
        bash "$PROJECT_ROOT/pipeline/setup-jenkins.sh"
        print_status "success" "Jenkins desplegado"
    else
        print_status "error" "Script setup-jenkins.sh no encontrado"
    fi
    
    echo ""
    echo "Presiona Enter para continuar..."
    read
}

deploy_microservices_only() {
    print_header
    echo "🛍️  DESPLIEGUE SOLO DE MICROSERVICIOS"
    echo "============================================================================"
    
    # Crear namespace ecommerce primero
    create_namespaces
    
    if [ -f "$PROJECT_ROOT/DEPLOY_ALL_MICROSERVICES.sh" ]; then
        chmod +x "$PROJECT_ROOT/DEPLOY_ALL_MICROSERVICES.sh"
        bash "$PROJECT_ROOT/DEPLOY_ALL_MICROSERVICES.sh"
        print_status "success" "Microservicios desplegados"
        
        # Configurar port-forwarding para microservicios
        echo ""
        read -p "¿Configurar port-forwarding para acceso externo? [Y/n]: " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            setup_external_port_forwarding
        fi
    else
        print_status "error" "Script DEPLOY_ALL_MICROSERVICES.sh no encontrado"
    fi
    
    echo ""
    echo "Presiona Enter para continuar..."
    read
}

deploy_monitoring_only() {
    print_header
    echo "📊 DESPLIEGUE SOLO DE MONITOREO"
    echo "============================================================================"
    
    # Crear namespace monitoring primero
    create_namespaces
    
    if [ -f "$PROJECT_ROOT/deploy-monitoring.sh" ]; then
        chmod +x "$PROJECT_ROOT/deploy-monitoring.sh"
        bash "$PROJECT_ROOT/deploy-monitoring.sh"
        
        # Aplicar NodePorts si existen
        if [ -f "$PROJECT_ROOT/monitoring/monitoring-nodeports.yaml" ]; then
            kubectl apply -f "$PROJECT_ROOT/monitoring/monitoring-nodeports.yaml"
        fi
        
        print_status "success" "Stack de monitoreo desplegado"
        
        # Configurar port-forwarding para monitoreo
        echo ""
        read -p "¿Configurar port-forwarding para acceso externo? [Y/n]: " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            setup_external_port_forwarding
        fi
    else
        print_status "error" "Script deploy-monitoring.sh no encontrado"
    fi
    
    echo ""
    echo "Presiona Enter para continuar..."
    read
}

generate_monitoring_data() {
    print_header
    echo "📈 GENERACIÓN DE DATOS DE MONITOREO"
    echo "============================================================================"
    
    if [ -f "$PROJECT_ROOT/pipeline/generate-monitoring-data.sh" ]; then
        chmod +x "$PROJECT_ROOT/pipeline/generate-monitoring-data.sh"
        echo "y" | bash "$PROJECT_ROOT/pipeline/generate-monitoring-data.sh"
        print_status "success" "Datos de monitoreo generados"
    else
        print_status "error" "Script generate-monitoring-data.sh no encontrado"
    fi
    
    echo ""
    echo "Presiona Enter para continuar..."
    read
}

run_performance_tests() {
    print_header
    echo "⚡ TESTS DE PERFORMANCE"
    echo "============================================================================"
    
    if [ -f "$PROJECT_ROOT/pipeline/run-performance-tests-optimized.sh" ]; then
        chmod +x "$PROJECT_ROOT/pipeline/run-performance-tests-optimized.sh"
        bash "$PROJECT_ROOT/pipeline/run-performance-tests-optimized.sh"
        print_status "success" "Tests de performance completados"
    else
        print_status "error" "Script de performance no encontrado"
    fi
    
    echo ""
    echo "Presiona Enter para continuar..."
    read
}

expose_monitoring_services() {
    print_header
    echo "🌐 EXPOSICIÓN DE SERVICIOS DE MONITOREO"
    echo "============================================================================"
    
    # Crear y ejecutar script de exposición
    cat > "$PROJECT_ROOT/expose-monitoring-temp.sh" << 'EOF'
#!/bin/bash
SERVICES=("grafana" "prometheus" "kibana" "jaeger" "alertmanager")
NAMESPACE="monitoring"

echo "Exponiendo servicios de monitoreo..."
for service in "${SERVICES[@]}"; do
    echo "Abriendo túnel para $service..."
    minikube service $service -n $NAMESPACE --url &
    sleep 2
done

echo ""
echo "URLs de acceso:"
for service in "${SERVICES[@]}"; do
    url=$(minikube service $service -n $NAMESPACE --url 2>/dev/null | head -1)
    if [[ -n $url ]]; then
        echo "$service: $url"
    fi
done

echo ""
echo "Presiona Ctrl+C para cerrar todos los túneles"
wait
EOF
    
    chmod +x "$PROJECT_ROOT/expose-monitoring-temp.sh"
    
    echo "Ejecutando exposición de servicios en background..."
    nohup bash "$PROJECT_ROOT/expose-monitoring-temp.sh" > "$PROJECT_ROOT/monitoring-tunnels.log" 2>&1 &
    
    sleep 3
    print_status "success" "Servicios expuestos. Ver monitoring-tunnels.log para URLs"
    
    echo ""
    echo "Presiona Enter para continuar..."
    read
}

clean_project() {
    print_header
    echo "🧹 LIMPIEZA Y ORGANIZACIÓN DEL PROYECTO"
    echo "============================================================================"
    
    echo "Esto organizará todos los scripts y eliminará duplicados."
    echo ""
    read -p "¿Continuar con la limpieza? [y/N]: " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    if [ -f "$PROJECT_ROOT/pipeline/organize-scripts.sh" ]; then
        chmod +x "$PROJECT_ROOT/pipeline/organize-scripts.sh"
        bash "$PROJECT_ROOT/pipeline/organize-scripts.sh"
        print_status "success" "Proyecto organizado"
    else
        print_status "error" "Script de organización no encontrado"
    fi
    
    echo ""
    echo "Presiona Enter para continuar..."
    read
}

stop_all_services() {
    print_header
    echo "🛑 DETENER TODOS LOS SERVICIOS"
    echo "============================================================================"
    
    echo "Esto detendrá:"
    echo "  • Jenkins (Docker)"
    echo "  • Minikube (Kubernetes)"
    echo "  • Túneles de monitoreo"
    echo "  • Port-forwards activos"
    echo ""
    
    read -p "¿Continuar? [y/N]: " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return 0
    fi
    
    echo "Deteniendo Jenkins..."
    docker stop jenkins-server 2>/dev/null || true
    
    echo "Deteniendo túneles de monitoreo..."
    pkill -f "minikube service" 2>/dev/null || true
    
    echo "Deteniendo port-forwards..."
    pkill -f "kubectl port-forward" 2>/dev/null || true
    
    echo "Deteniendo minikube..."
    minikube stop
    
    print_status "success" "Todos los servicios detenidos"
    
    echo ""
    echo "Presiona Enter para continuar..."
    read
}

# Función para detener solo port-forwards
stop_port_forwards() {
    print_header
    echo "🛑 DETENER PORT-FORWARDS"
    echo "============================================================================"
    
    echo "Deteniendo todos los port-forwards activos..."
    pkill -f "kubectl port-forward" 2>/dev/null || true
    sleep 2
    
    print_status "success" "Port-forwards detenidos"
    
    echo ""
    echo "Presiona Enter para continuar..."
    read
}

show_menu() {
    print_header
    echo "Selecciona una opción:"
    echo ""
    echo "📊 INFORMACIÓN Y ESTADO:"
    echo "  1) Ver estado de todos los servicios"
    echo "  2) Mostrar URLs de acceso"
    echo ""
    echo "🚀 DESPLIEGUE:"
    echo "  3) Despliegue completo (Todo)"
    echo "  4) Solo Jenkins"
    echo "  5) Solo Microservicios"
    echo "  6) Solo Monitoreo"
    echo ""
    echo "🌐 ACCESO EXTERNO:"
    echo "  7) Configurar Port-Forwarding externo"
    echo "  8) Detener Port-Forwarding"
    echo ""
    echo "⚡ OPERACIONES:"
    echo "  9) Generar datos de monitoreo"
    echo " 10) Ejecutar tests de performance"
    echo " 11) Exponer servicios de monitoreo (Legacy)"
    echo ""
    echo "🛠️  MANTENIMIENTO:"
    echo " 12) Limpiar y organizar proyecto"
    echo " 13) Detener todos los servicios"
    echo ""
    echo "  0) Salir"
    echo ""
    echo "============================================================================"
    printf "Opción [0-13]: "
}

main() {
    # Verificar prerequisitos básicos
    if ! check_prerequisites; then
        exit 1
    fi
    
    # Crear directorio pipeline si no existe
    mkdir -p "$PROJECT_ROOT/pipeline"
    
    while true; do
        show_menu
        read -n 1 -r option
        echo ""
        
        case $option in
            1) check_services_status ;;
            2) show_access_urls ;;
            3) deploy_complete ;;
            4) deploy_jenkins_only ;;
            5) deploy_microservices_only ;;
            6) deploy_monitoring_only ;;
            7) setup_external_port_forwarding ;;
            8) stop_port_forwards ;;
            9) generate_monitoring_data ;;
            10) run_performance_tests ;;
            11) expose_monitoring_services ;;
            12) clean_project ;;
            13) stop_all_services ;;
            0) 
                print_header
                echo "¡Hasta luego!"
                echo ""
                echo "📄 Logs disponibles en: $LOG_FILE"
                echo "📄 Acceso externo en: external-access-info.txt"
                echo ""
                exit 0
                ;;
            *)
                print_header
                print_status "error" "Opción inválida: $option"
                echo ""
                echo "Presiona Enter para continuar..."
                read
                ;;
        esac
    done
}

# Ejecutar aplicación
main "$@" 