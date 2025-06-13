#!/bin/bash

echo "🧹 LIMPIEZA DE PODS DUPLICADOS Y PROBLEMÁTICOS"
echo "=============================================="
echo ""

# Verificar que minikube esté funcionando
if ! minikube status >/dev/null 2>&1; then
    echo "❌ minikube no está corriendo"
    echo "💡 Ejecuta: minikube start"
    exit 1
fi

echo "📊 Estado actual de pods en namespace ecommerce:"
kubectl get pods -n ecommerce
echo ""

echo "🔍 Identificando pods problemáticos..."

# Obtener pods que NO están en estado Running o que tienen 0/1 ready
FAILED_PODS=$(kubectl get pods -n ecommerce --no-headers | grep -E "(ContainerCreating|ImagePullBackOff|Terminating|Error|CrashLoopBackOff|Pending)" | awk '{print $1}')
NOT_READY_PODS=$(kubectl get pods -n ecommerce --no-headers | grep "0/1" | awk '{print $1}')

echo "❌ Pods con problemas encontrados:"
if [ -n "$FAILED_PODS" ]; then
    echo "$FAILED_PODS"
else
    echo "  Ningún pod con errores detectado"
fi

if [ -n "$NOT_READY_PODS" ]; then
    echo ""
    echo "⚠️ Pods no listos (0/1):"
    echo "$NOT_READY_PODS"
fi

echo ""
echo "🗑️ ¿Quieres eliminar todos los pods problemáticos? [y/N]:"
read -p "Respuesta: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🧹 Eliminando pods problemáticos..."
    
    # Eliminar pods con problemas
    if [ -n "$FAILED_PODS" ]; then
        echo "$FAILED_PODS" | xargs -I {} kubectl delete pod {} -n ecommerce --force --grace-period=0
    fi
    
    if [ -n "$NOT_READY_PODS" ]; then
        echo "$NOT_READY_PODS" | xargs -I {} kubectl delete pod {} -n ecommerce --force --grace-period=0
    fi
    
    echo ""
    echo "⏳ Esperando que Kubernetes recree los pods..."
    sleep 10
    
    echo ""
    echo "📊 Estado después de la limpieza:"
    kubectl get pods -n ecommerce
    
else
    echo "🚫 Limpieza cancelada"
fi

echo ""
echo "🔄 Alternativa: Reiniciar deployments para pods problemáticos"
echo "=================================================="

# Función para reiniciar deployment
restart_deployment() {
    local deployment=$1
    echo "🔄 Reiniciando deployment: $deployment"
    kubectl rollout restart deployment/$deployment -n ecommerce
    kubectl rollout status deployment/$deployment -n ecommerce --timeout=300s
}

echo ""
echo "¿Quieres reiniciar los deployments problemáticos? [y/N]:"
read -p "Respuesta: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🔄 Reiniciando deployments..."
    
    # Lista de deployments a reiniciar basándose en los pods problemáticos
    DEPLOYMENTS_TO_RESTART=(
        "api-gateway"
        "order-service" 
        "payment-service"
        "proxy-client"
        "service-discovery"
    )
    
    for deployment in "${DEPLOYMENTS_TO_RESTART[@]}"; do
        if kubectl get deployment $deployment -n ecommerce >/dev/null 2>&1; then
            restart_deployment $deployment
        else
            echo "⚠️ Deployment $deployment no encontrado"
        fi
    done
    
    echo ""
    echo "✅ Reinicio de deployments completado"
    echo ""
    echo "📊 Estado final:"
    kubectl get pods -n ecommerce
    echo ""
    kubectl get svc -n ecommerce
    
else
    echo "🚫 Reinicio cancelado"
fi

echo ""
echo "🌐 URLs de acceso (una vez que los pods estén listos):"
MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "MINIKUBE_IP")
echo "  • Frontend: http://$MINIKUBE_IP:30900/swagger-ui.html"
echo "  • API Gateway: http://$MINIKUBE_IP:30080"
echo "  • Service Discovery: http://$MINIKUBE_IP:30761"

echo ""
echo "🔍 Para monitorear el progreso:"
echo "  kubectl get pods -n ecommerce -w" 