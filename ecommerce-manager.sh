#!/bin/bash

# ============================================================================
# GESTOR PRINCIPAL E-COMMERCE MICROSERVICES
# ============================================================================
# Script maestro con menú interactivo para gestionar todo el proyecto:
# - Despliegue completo
# - Componentes individuales  
# - Verificaciones y diagnósticos
# - Limpieza y organización
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
    local services=("user-service" "product-service" "order-service" "payment-service" "shipping-service" "favourite-service")
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
        echo "   user-service: http://$minikube_ip:30087"
        echo "   product-service: http://$minikube_ip:30082"
        echo "   order-service: http://$minikube_ip:30083"
        echo "   payment-service: http://$minikube_ip:30084"
        echo "   shipping-service: http://$minikube_ip:30085"
        echo "   favourite-service: http://$minikube_ip:30086"
    else
        echo "   ❌ Minikube no está corriendo"
    fi
    echo ""
    
    echo "📊 SERVICIOS DE MONITOREO:"
    if [[ $minikube_ip != "N/A" ]]; then
        echo "   Grafana: http://$minikube_ip:30030 (admin/admin123)"
        echo "   Prometheus: http://$minikube_ip:30090"
        echo "   Kibana: http://$minikube_ip:30601"
        echo "   Jaeger: http://$minikube_ip:30686"
        echo "   AlertManager: http://$minikube_ip:30093"
    else
        echo "   ❌ Minikube no está corriendo"
    fi
    echo ""
    
    if [ -f "$PROJECT_ROOT/monitoring-tunnels.log" ]; then
        echo "📋 URLs dinámicas de túneles: monitoring-tunnels.log"
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
    echo "  • Jenkins CI/CD"
    echo "  • 6 Microservicios de E-commerce"
    echo "  • Stack completo de Monitoreo"
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
    
    # Ejecutar pipeline completo
    if [ -f "$PROJECT_ROOT/pipeline/master-deployment-pipeline.sh" ]; then
        chmod +x "$PROJECT_ROOT/pipeline/master-deployment-pipeline.sh"
        bash "$PROJECT_ROOT/pipeline/master-deployment-pipeline.sh"
    else
        print_status "error" "Pipeline maestro no encontrado"
    fi
    
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
    
    if [ -f "$PROJECT_ROOT/pipeline/DEPLOY_ALL_MICROSERVICES.sh" ]; then
        chmod +x "$PROJECT_ROOT/pipeline/DEPLOY_ALL_MICROSERVICES.sh"
        bash "$PROJECT_ROOT/pipeline/DEPLOY_ALL_MICROSERVICES.sh"
        print_status "success" "Microservicios desplegados"
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
    
    if [ -f "$PROJECT_ROOT/pipeline/deploy-monitoring.sh" ]; then
        chmod +x "$PROJECT_ROOT/pipeline/deploy-monitoring.sh"
        bash "$PROJECT_ROOT/pipeline/deploy-monitoring.sh"
        
        # Aplicar NodePorts
        if [ -f "$PROJECT_ROOT/monitoring/monitoring-nodeports.yaml" ]; then
            kubectl apply -f "$PROJECT_ROOT/monitoring/monitoring-nodeports.yaml"
        fi
        
        print_status "success" "Stack de monitoreo desplegado"
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
    
    echo "Deteniendo minikube..."
    minikube stop
    
    print_status "success" "Todos los servicios detenidos"
    
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
    echo "⚡ OPERACIONES:"
    echo "  7) Generar datos de monitoreo"
    echo "  8) Ejecutar tests de performance"
    echo "  9) Exponer servicios de monitoreo"
    echo ""
    echo "🛠️  MANTENIMIENTO:"
    echo " 10) Limpiar y organizar proyecto"
    echo " 11) Detener todos los servicios"
    echo ""
    echo "  0) Salir"
    echo ""
    echo "============================================================================"
    printf "Opción [0-11]: "
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
            7) generate_monitoring_data ;;
            8) run_performance_tests ;;
            9) expose_monitoring_services ;;
            10) clean_project ;;
            11) stop_all_services ;;
            0) 
                print_header
                echo "¡Hasta luego!"
                echo ""
                echo "📄 Logs disponibles en: $LOG_FILE"
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