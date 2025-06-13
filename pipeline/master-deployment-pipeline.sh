#!/bin/bash

# ============================================================================
# PIPELINE MAESTRO DE DESPLIEGUE E-COMMERCE MICROSERVICES
# ============================================================================
# Este script orquesta todo el proceso de despliegue:
# 1. Verificación de prerequisitos
# 2. Despliegue de Jenkins + Microservicios
# 3. Despliegue de Stack de Monitoreo
# 4. Tests de Performance
# 5. Exposición de Servicios de Monitoreo
# 6. Generación de Datos de Prueba
# 7. Validación Final
# ============================================================================

# Configuración global
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="$PROJECT_ROOT/pipeline-deployment.log"
RETRY_ATTEMPTS=3
RETRY_DELAY=10

# ASCII Art para estados
ASCII_SUCCESS="⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡤⠶⠚⠉⢉⣩⠽⠟⠛⠛⠛⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⠉⠀⢀⣠⠞⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡞⠁⠀⠀⣰⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⠀⠀⠀⡼⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣠⡤⠤⠄⢤⣄⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⢰⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⠴⠒⠋⠉⠀⠀⠀⣀⣤⠴⠒⠋⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀"

ASCII_ERROR="⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣀⣤⣤⣤⣤⣄⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣤⠶⣻⠝⠋⠠⠔⠛⠁⡀⠀⠈⢉⡙⠓⠶⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⠞⢋⣴⡮⠓⠋⠀⠀⢄⠀⠀⠉⠢⣄⠀⠈⠁⠀⡀⠙⢶⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀"

# Funciones de utilidad
print_header() {
    echo ""
    echo "============================================================================"
    echo " $1"
    echo "============================================================================"
}

print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "success")
            echo "$ASCII_SUCCESS"
            echo "SUCCESS: $message"
            ;;
        "error")
            echo "$ASCII_ERROR"  
            echo "ERROR: $message"
            ;;
        "info")
            echo "INFO: $message"
            ;;
        "retry")
            echo "🔄 RETRY: $message"
            ;;
    esac
}

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_prerequisites() {
    print_header "FASE 1: VERIFICACIÓN DE PREREQUISITOS"
    
    local failed=0
    
    # Verificar herramientas necesarias
    for tool in kubectl minikube docker curl; do
        if ! command -v $tool &> /dev/null; then
            print_status "error" "$tool no está instalado"
            failed=1
        else
            print_status "success" "$tool disponible"
        fi
    done
    
    # Verificar minikube status
    if ! minikube status &> /dev/null; then
        print_status "error" "minikube no está corriendo. Iniciando..."
        minikube start || { print_status "error" "No se pudo iniciar minikube"; return 1; }
    fi
    
    print_status "success" "minikube está corriendo"
    
    if [ $failed -eq 1 ]; then
        print_status "error" "Prerequisitos no cumplidos"
        return 1
    fi
    
    print_status "success" "Todos los prerequisitos verificados"
    return 0
}

deploy_jenkins() {
    print_header "FASE 2: DESPLIEGUE DE JENKINS"
    
    local attempt=1
    while [ $attempt -le $RETRY_ATTEMPTS ]; do
        print_status "info" "Intento $attempt de $RETRY_ATTEMPTS"
        
        if [ -f "$PROJECT_ROOT/setup-jenkins.sh" ]; then
            chmod +x "$PROJECT_ROOT/setup-jenkins.sh"
            if bash "$PROJECT_ROOT/setup-jenkins.sh"; then
                print_status "success" "Jenkins desplegado correctamente"
                return 0
            fi
        else
            print_status "error" "Script setup-jenkins.sh no encontrado"
        fi
        
        print_status "retry" "Reintentando en $RETRY_DELAY segundos..."
        sleep $RETRY_DELAY
        ((attempt++))
    done
    
    print_status "error" "Falló el despliegue de Jenkins después de $RETRY_ATTEMPTS intentos"
    return 1
}

deploy_microservices() {
    print_header "FASE 3: DESPLIEGUE DE MICROSERVICIOS"
    
    local attempt=1
    while [ $attempt -le $RETRY_ATTEMPTS ]; do
        print_status "info" "Intento $attempt de $RETRY_ATTEMPTS"
        
        if [ -f "$PROJECT_ROOT/DEPLOY_ALL_MICROSERVICES.sh" ]; then
            chmod +x "$PROJECT_ROOT/DEPLOY_ALL_MICROSERVICES.sh"
            if bash "$PROJECT_ROOT/DEPLOY_ALL_MICROSERVICES.sh"; then
                print_status "success" "Microservicios desplegados correctamente"
                return 0
            fi
        else
            print_status "error" "Script DEPLOY_ALL_MICROSERVICES.sh no encontrado"
        fi
        
        print_status "retry" "Reintentando en $RETRY_DELAY segundos..."
        sleep $RETRY_DELAY
        ((attempt++))
    done
    
    print_status "error" "Falló el despliegue de microservicios después de $RETRY_ATTEMPTS intentos"
    return 1
}

deploy_monitoring() {
    print_header "FASE 4: DESPLIEGUE DE STACK DE MONITOREO"
    
    local attempt=1
    while [ $attempt -le $RETRY_ATTEMPTS ]; do
        print_status "info" "Intento $attempt de $RETRY_ATTEMPTS"
        
        if [ -f "$PROJECT_ROOT/deploy-monitoring.sh" ]; then
            chmod +x "$PROJECT_ROOT/deploy-monitoring.sh"
            if bash "$PROJECT_ROOT/deploy-monitoring.sh"; then
                print_status "success" "Stack de monitoreo desplegado correctamente"
                
                # Aplicar NodePorts para servicios de monitoreo
                if [ -f "$PROJECT_ROOT/monitoring/monitoring-nodeports.yaml" ]; then
                    kubectl apply -f "$PROJECT_ROOT/monitoring/monitoring-nodeports.yaml"
                    print_status "success" "NodePorts de monitoreo configurados"
                fi
                
                return 0
            fi
        else
            print_status "error" "Script deploy-monitoring.sh no encontrado"
        fi
        
        print_status "retry" "Reintentando en $RETRY_DELAY segundos..."
        sleep $RETRY_DELAY
        ((attempt++))
    done
    
    print_status "error" "Falló el despliegue de monitoreo después de $RETRY_ATTEMPTS intentos"
    return 1
}

run_performance_tests() {
    print_header "FASE 5: TESTS DE PERFORMANCE"
    
    if [ -f "$PROJECT_ROOT/run-performance-tests-optimized.sh" ]; then
        chmod +x "$PROJECT_ROOT/run-performance-tests-optimized.sh"
        if bash "$PROJECT_ROOT/run-performance-tests-optimized.sh"; then
            print_status "success" "Tests de performance completados"
            return 0
        else
            print_status "error" "Tests de performance fallaron (continuando...)"
            return 0  # No crítico, continuar
        fi
    else
        print_status "error" "Script run-performance-tests-optimized.sh no encontrado"
        return 0  # No crítico
    fi
}

expose_monitoring_services() {
    print_header "FASE 6: EXPOSICIÓN DE SERVICIOS DE MONITOREO"
    
    # Crear script temporal para exposición
    cat > "$PROJECT_ROOT/pipeline/expose-all-monitoring.sh" << 'EOF'
#!/bin/bash

SERVICES=("grafana" "prometheus" "kibana" "jaeger" "alertmanager")
NAMESPACE="monitoring"

echo "Exponiendo servicios de monitoreo..."
echo "IMPORTANTE: Mantén estas ventanas abiertas para acceder a los dashboards"

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
    
    chmod +x "$PROJECT_ROOT/pipeline/expose-all-monitoring.sh"
    
    # Ejecutar en background
    nohup bash "$PROJECT_ROOT/pipeline/expose-all-monitoring.sh" > "$PROJECT_ROOT/monitoring-tunnels.log" 2>&1 &
    
    print_status "success" "Servicios de monitoreo expuestos"
    print_status "info" "Ver monitoring-tunnels.log para URLs de acceso"
    
    sleep 5  # Dar tiempo para que se establezcan los túneles
    return 0
}

generate_monitoring_data() {
    print_header "FASE 7: GENERACIÓN DE DATOS DE MONITOREO"
    
    if [ -f "$PROJECT_ROOT/generate-monitoring-data.sh" ]; then
        chmod +x "$PROJECT_ROOT/generate-monitoring-data.sh"
        # Ejecutar automáticamente (sin prompt)
        echo "y" | bash "$PROJECT_ROOT/generate-monitoring-data.sh"
        print_status "success" "Datos de monitoreo generados"
        return 0
    else
        print_status "error" "Script generate-monitoring-data.sh no encontrado"
        return 1
    fi
}

final_validation() {
    print_header "FASE 8: VALIDACIÓN FINAL"
    
    local failed=0
    
    # Verificar Jenkins
    if curl -s http://localhost:8081 &> /dev/null; then
        print_status "success" "Jenkins accesible en http://localhost:8081"
    else
        print_status "error" "Jenkins no accesible"
        failed=1
    fi
    
    # Verificar microservicios
    local services_up=0
    for service in user-service product-service order-service payment-service shipping-service favourite-service; do
        if kubectl get pod -l app=$service -n ecommerce --no-headers 2>/dev/null | grep -q Running; then
            ((services_up++))
        fi
    done
    
    if [ $services_up -eq 6 ]; then
        print_status "success" "Todos los microservicios están corriendo"
    else
        print_status "error" "Solo $services_up de 6 microservicios están corriendo"
        failed=1
    fi
    
    # Verificar monitoreo
    local monitoring_up=0
    for service in prometheus grafana kibana jaeger alertmanager; do
        if kubectl get pod -l app=$service -n monitoring --no-headers 2>/dev/null | grep -q Running; then
            ((monitoring_up++))
        fi
    done
    
    if [ $monitoring_up -eq 5 ]; then
        print_status "success" "Stack de monitoreo completo está corriendo"
    else
        print_status "error" "Solo $monitoring_up de 5 servicios de monitoreo están corriendo"
        failed=1
    fi
    
    if [ $failed -eq 0 ]; then
        print_status "success" "VALIDACIÓN FINAL EXITOSA"
        return 0
    else
        print_status "error" "VALIDACIÓN FINAL FALLÓ"
        return 1
    fi
}

cleanup_on_failure() {
    print_header "LIMPIEZA EN CASO DE FALLO"
    
    print_status "info" "Deteniendo procesos en background..."
    pkill -f "minikube service" || true
    
    print_status "info" "Para reintentar el despliegue, ejecuta:"
    print_status "info" "bash pipeline/master-deployment-pipeline.sh"
}

main() {
    print_header "INICIANDO PIPELINE DE DESPLIEGUE E-COMMERCE MICROSERVICES"
    
    # Crear directorio pipeline si no existe
    mkdir -p "$PROJECT_ROOT/pipeline"
    
    # Crear log file
    echo "Pipeline iniciado: $(date)" > "$LOG_FILE"
    
    # Ejecutar fases del pipeline
    check_prerequisites || { cleanup_on_failure; exit 1; }
    deploy_jenkins || { cleanup_on_failure; exit 1; }
    deploy_microservices || { cleanup_on_failure; exit 1; }
    deploy_monitoring || { cleanup_on_failure; exit 1; }
    run_performance_tests  # No crítico
    expose_monitoring_services || { cleanup_on_failure; exit 1; }
    generate_monitoring_data || { cleanup_on_failure; exit 1; }
    final_validation || { cleanup_on_failure; exit 1; }
    
    print_header "PIPELINE COMPLETADO EXITOSAMENTE"
    print_status "success" "Todos los componentes desplegados y funcionando"
    
    echo ""
    echo "URLS DE ACCESO:"
    echo "- Jenkins: http://localhost:8081"
    echo "- Monitoreo: Ver monitoring-tunnels.log para URLs específicas"
    echo ""
    echo "PRÓXIMOS PASOS:"
    echo "1. Abre Jenkins y configura los pipelines"
    echo "2. Accede a Grafana para ver dashboards de métricas"
    echo "3. Revisa Kibana para análisis de logs"
    echo "4. Explora Jaeger para trazas distribuidas"
    echo ""
    echo "Log completo en: $LOG_FILE"
}

# Trap para limpieza en caso de interrupción
trap cleanup_on_failure INT TERM

# Ejecutar pipeline
main "$@" 