#!/bin/bash

# Script de diagnóstico completo para microservicios
set -e

echo "🔍 Diagnóstico completo de microservicios E-commerce..."

# Función para verificar Minikube
check_minikube() {
    echo ""
    echo "🔧 Verificando Minikube..."
    
    if command -v minikube >/dev/null 2>&1; then
        echo "✅ Minikube instalado"
        
        # Verificar estado
        echo "📊 Estado de Minikube:"
        minikube status || {
            echo "⚠️  Minikube no está funcionando correctamente"
            echo "🔄 Intentando reiniciar Minikube..."
            minikube start
        }
    else
        echo "❌ Minikube no está instalado"
        return 1
    fi
}

# Función para verificar kubectl
check_kubectl() {
    echo ""
    echo "🔧 Verificando kubectl..."
    
    if command -v kubectl >/dev/null 2>&1; then
        echo "✅ kubectl instalado"
        
        # Verificar conectividad
        if kubectl cluster-info >/dev/null 2>&1; then
            echo "✅ kubectl conectado al cluster"
        else
            echo "❌ kubectl no puede conectar al cluster"
            echo "🔄 Intentando configurar contexto..."
            kubectl config use-context minikube
        fi
    else
        echo "❌ kubectl no está instalado"
        return 1
    fi
}

# Función para verificar namespaces
check_namespaces() {
    echo ""
    echo "🔧 Verificando namespaces..."
    
    # Verificar namespace ecommerce
    if kubectl get namespace ecommerce >/dev/null 2>&1; then
        echo "✅ Namespace 'ecommerce' existe"
    else
        echo "⚠️  Namespace 'ecommerce' no existe"
        echo "🔄 Creando namespace..."
        kubectl create namespace ecommerce
    fi
    
    # Verificar namespace monitoring
    if kubectl get namespace monitoring >/dev/null 2>&1; then
        echo "✅ Namespace 'monitoring' existe"
    else
        echo "⚠️  Namespace 'monitoring' no existe"
        echo "🔄 Creando namespace..."
        kubectl create namespace monitoring
    fi
}

# Función para verificar deployments
check_deployments() {
    echo ""
    echo "🔧 Verificando deployments en namespace ecommerce..."
    
    # Lista de servicios esperados
    SERVICES=("user-service" "product-service" "order-service" "payment-service" "shipping-service" "favourite-service" "api-gateway" "service-discovery" "proxy-client")
    
    echo "📊 Estado de deployments:"
    kubectl get deployments -n ecommerce 2>/dev/null || echo "❌ No hay deployments en namespace ecommerce"
    
    echo ""
    echo "📊 Estado de pods:"
    kubectl get pods -n ecommerce 2>/dev/null || echo "❌ No hay pods en namespace ecommerce"
    
    echo ""
    echo "📊 Estado de servicios:"
    kubectl get services -n ecommerce 2>/dev/null || echo "❌ No hay servicios en namespace ecommerce"
    
    # Verificar cada servicio específicamente
    echo ""
    echo "🔍 Verificando servicios específicos:"
    for service in "${SERVICES[@]}"; do
        if kubectl get deployment "$service" -n ecommerce >/dev/null 2>&1; then
            READY=$(kubectl get deployment "$service" -n ecommerce -o jsonpath='{.status.readyReplicas}' 2>/dev/null || echo "0")
            DESIRED=$(kubectl get deployment "$service" -n ecommerce -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")
            
            if [[ "$READY" == "$DESIRED" && "$READY" != "0" ]]; then
                echo "  ✅ $service: $READY/$DESIRED pods listos"
            else
                echo "  ⚠️  $service: $READY/$DESIRED pods listos"
                
                # Mostrar logs del pod con problemas
                POD_NAME=$(kubectl get pods -n ecommerce -l app="$service" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
                if [[ -n "$POD_NAME" ]]; then
                    echo "    📝 Logs recientes de $POD_NAME:"
                    kubectl logs "$POD_NAME" -n ecommerce --tail=5 2>/dev/null || echo "    ❌ No se pueden obtener logs"
                fi
            fi
        else
            echo "  ❌ $service: No encontrado"
        fi
    done
}

# Función para verificar archivos de configuración K8s
check_k8s_configs() {
    echo ""
    echo "🔧 Verificando archivos de configuración K8s..."
    
    SERVICES=("user-service" "product-service" "order-service" "payment-service" "shipping-service" "favourite-service" "api-gateway" "service-discovery" "proxy-client")
    
    for service in "${SERVICES[@]}"; do
        K8S_DIR="${service}/k8s"
        if [[ -d "$K8S_DIR" ]]; then
            echo "  ✅ $service: Directorio k8s existe"
            
            # Verificar archivos específicos
            if [[ -f "$K8S_DIR/namespace.yaml" ]]; then
                echo "    ✅ namespace.yaml"
            else
                echo "    ❌ namespace.yaml faltante"
            fi
            
            if [[ -f "$K8S_DIR/deployment.yaml" ]]; then
                echo "    ✅ deployment.yaml"
            else
                echo "    ❌ deployment.yaml faltante"
            fi
            
            if [[ -f "$K8S_DIR/service.yaml" ]]; then
                echo "    ✅ service.yaml"
            else
                echo "    ❌ service.yaml faltante"
            fi
        else
            echo "  ❌ $service: Directorio k8s no existe"
        fi
    done
}

# Función para verificar Docker Compose
check_docker_compose() {
    echo ""
    echo "🔧 Verificando Docker Compose..."
    
    if [[ -f "docker-compose.yml" ]]; then
        echo "✅ docker-compose.yml existe"
        
        # Verificar servicios en Docker Compose
        echo "📊 Servicios en Docker Compose:"
        docker-compose ps 2>/dev/null || echo "❌ Error al obtener estado de Docker Compose"
    else
        echo "❌ docker-compose.yml no encontrado"
    fi
}

# Función para mostrar recomendaciones
show_recommendations() {
    echo ""
    echo "💡 Recomendaciones:"
    echo ""
    
    # Si no hay deployments
    if ! kubectl get deployments -n ecommerce >/dev/null 2>&1; then
        echo "🚀 Para desplegar los microservicios:"
        echo "   ./ecommerce-manager.sh deploy"
        echo ""
    fi
    
    # Si hay problemas con pods
    echo "🔧 Para solucionar problemas de pods:"
    echo "   kubectl describe pod <pod-name> -n ecommerce"
    echo "   kubectl logs <pod-name> -n ecommerce"
    echo ""
    
    echo "🔄 Para reiniciar un deployment:"
    echo "   kubectl rollout restart deployment/<service-name> -n ecommerce"
    echo ""
    
    echo "🧹 Para limpiar pods problemáticos:"
    echo "   ./cleanup-menu.sh"
    echo ""
    
    echo "📊 Para monitorear en tiempo real:"
    echo "   watch kubectl get pods -n ecommerce"
}

# Función principal
main() {
    echo "🚀 Iniciando diagnóstico completo..."
    
    # Verificaciones básicas
    check_minikube
    check_kubectl
    check_namespaces
    
    # Verificaciones de aplicación
    check_k8s_configs
    check_deployments
    check_docker_compose
    
    # Mostrar recomendaciones
    show_recommendations
    
    echo ""
    echo "✅ Diagnóstico completado!"
}

# Ejecutar función principal
main "$@" 