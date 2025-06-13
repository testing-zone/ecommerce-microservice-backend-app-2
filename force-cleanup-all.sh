#!/bin/bash

echo "🔥 LIMPIEZA COMPLETA Y REDESPLEGUE LIMPIO"
echo "========================================"
echo ""
echo "⚠️  ADVERTENCIA: Esto eliminará TODOS los pods del namespace ecommerce"
echo "     y los redesplegará desde cero."
echo ""

read -p "¿Estás seguro? Escribe 'SI' para continuar: " confirm

if [ "$confirm" != "SI" ]; then
    echo "🚫 Operación cancelada"
    exit 0
fi

echo ""
echo "🗑️ PASO 1: Eliminando todos los recursos del namespace ecommerce..."

# Eliminar todos los deployments
kubectl delete deployment --all -n ecommerce --force --grace-period=0

# Eliminar todos los pods (por si quedan algunos)
kubectl delete pods --all -n ecommerce --force --grace-period=0

# Eliminar todos los services (excepto los del sistema)
kubectl delete svc --all -n ecommerce

# Eliminar configmaps
kubectl delete configmap --all -n ecommerce

# Eliminar secrets
kubectl delete secret --all -n ecommerce

echo "✅ Limpieza completada"
echo ""
echo "⏳ Esperando que los recursos se eliminen completamente..."
sleep 10

echo ""
echo "🚀 PASO 2: Redesplegando servicios críticos..."

# Recrear namespace
kubectl create namespace ecommerce --dry-run=client -o yaml | kubectl apply -f -

echo ""
echo "📦 Desplegando service-discovery (Eureka)..."
kubectl apply -f service-discovery/k8s/deployment.yaml

echo "⏳ Esperando que service-discovery esté listo..."
kubectl wait --for=condition=ready pod -l app=service-discovery -n ecommerce --timeout=300s

echo ""
echo "📦 Desplegando api-gateway..."
kubectl apply -f api-gateway/k8s/deployment.yaml

echo "⏳ Esperando que api-gateway esté listo..."
kubectl wait --for=condition=ready pod -l app=api-gateway -n ecommerce --timeout=300s

echo ""
echo "📦 Desplegando proxy-client (Frontend)..."
kubectl apply -f proxy-client/k8s/deployment.yaml

echo "⏳ Esperando que proxy-client esté listo..."
kubectl wait --for=condition=ready pod -l app=proxy-client -n ecommerce --timeout=300s

echo ""
echo "📦 Desplegando microservicios..."

# Aplicar en orden específico para evitar dependencias
services=("user-service" "product-service" "order-service" "payment-service" "shipping-service" "favourite-service")

for service in "${services[@]}"; do
    echo "📦 Desplegando $service..."
    if [ -f "$service/k8s/configmap.yaml" ]; then
        kubectl apply -f "$service/k8s/configmap.yaml"
    fi
    kubectl apply -f "$service/k8s/deployment.yaml"
    kubectl apply -f "$service/k8s/service.yaml"
    
    # Esperar un poco entre servicios
    sleep 5
done

echo ""
echo "⏳ Esperando que todos los servicios estén listos..."
sleep 30

echo ""
echo "📊 ESTADO FINAL:"
echo "================"
kubectl get pods -n ecommerce
echo ""
kubectl get svc -n ecommerce

echo ""
echo "🌐 URLs DE ACCESO:"
echo "=================="
MINIKUBE_IP=$(minikube ip 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "  🖥️  Frontend (Swagger UI): http://$MINIKUBE_IP:30900/swagger-ui.html"
    echo "  🌐 API Gateway: http://$MINIKUBE_IP:30080"
    echo "  🔍 Service Discovery: http://$MINIKUBE_IP:30761"
    echo ""
    echo "  📱 Microservicios individuales:"
    echo "     • User Service: http://$MINIKUBE_IP:30087"
    echo "     • Product Service: http://$MINIKUBE_IP:30082"
    echo "     • Order Service: http://$MINIKUBE_IP:30083"
    echo "     • Payment Service: http://$MINIKUBE_IP:30084"
    echo "     • Shipping Service: http://$MINIKUBE_IP:30085"
    echo "     • Favourite Service: http://$MINIKUBE_IP:30086"
else
    echo "⚠️ No se pudo obtener la IP de Minikube"
    echo "💡 Usa port-forward para acceso local:"
    echo "   kubectl port-forward svc/proxy-client -n ecommerce 8900:8900"
fi

echo ""
echo "✅ REDESPLEGUE COMPLETADO!"
echo ""
echo "🔍 Para monitorear el estado:"
echo "   kubectl get pods -n ecommerce -w"
echo ""
echo "📋 Para ver logs:"
echo "   kubectl logs -f deployment/proxy-client -n ecommerce" 