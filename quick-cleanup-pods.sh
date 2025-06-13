#!/bin/bash

echo "🧹 LIMPIEZA RÁPIDA DE PODS PROBLEMÁTICOS"
echo "======================================="
echo ""

# Lista de pods problemáticos basándose en la imagen proporcionada
PODS_TO_DELETE=(
    "api-gateway-dbcd6484c-fznc6"
    "api-gateway-dbcd6484c-pf6lp"
    "order-service-5fcb698c9b-gqzq9"
    "order-service-5fcb698c9b-xj4pd"
    "order-service-78474b6f4-d4ppr"
    "payment-service-59f9dd76bd-ck44j"
    "product-service-67f45bc9d5-gq9nk"
    "proxy-client-7f795f9d7c-wsw75"
    "service-discovery-6bb5bfbfbc-w8qnb"
    "shipping-service-6d74fd787b-fknmq"
    "user-service-56f889666c-p5knk"
    "user-service-57fd8b85-h5jsr"
)

echo "📋 Pods a eliminar:"
printf '%s\n' "${PODS_TO_DELETE[@]}"
echo ""

read -p "¿Proceder con la eliminación? [y/N]: " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🗑️ Eliminando pods problemáticos..."
    
    for pod in "${PODS_TO_DELETE[@]}"; do
        echo "🗑️ Eliminando pod: $pod"
        kubectl delete pod "$pod" -n ecommerce --force --grace-period=0 2>/dev/null || echo "   ⚠️ Pod $pod no encontrado o ya eliminado"
    done
    
    echo ""
    echo "⏳ Esperando que Kubernetes recree los pods..."
    sleep 15
    
    echo ""
    echo "📊 Estado después de la limpieza:"
    kubectl get pods -n ecommerce
    
    echo ""
    echo "📊 Estado de los servicios:"
    kubectl get svc -n ecommerce
    
    echo ""
    echo "🌐 URLs de acceso:"
    MINIKUBE_IP=$(minikube ip 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "  🖥️  Frontend: http://$MINIKUBE_IP:30900/swagger-ui.html"
        echo "  🌐 API Gateway: http://$MINIKUBE_IP:30080" 
        echo "  🔍 Service Discovery: http://$MINIKUBE_IP:30761"
    else
        echo "⚠️ No se pudo obtener la IP de Minikube"
    fi
    
else
    echo "🚫 Limpieza cancelada"
fi

echo ""
echo "💡 Si aún hay problemas, usa:"
echo "   ./force-cleanup-all.sh    # Para limpieza completa"
echo "   ./cleanup-duplicate-pods.sh    # Para limpieza interactiva" 