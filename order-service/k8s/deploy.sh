#!/bin/bash

echo "🚀 DESPLEGANDO order-service en Kubernetes"
echo "=========================================="

# Verificar que minikube esté funcionando
if ! minikube status >/dev/null 2>&1; then
    echo "❌ minikube no está corriendo"
    echo "💡 Ejecuta: minikube start"
    exit 1
fi

# Crear namespace si no existe
kubectl apply -f namespace.yaml

# Aplicar ConfigMaps
if [ -f "configmap.yaml" ]; then
    kubectl apply -f configmap.yaml
    echo "✅ ConfigMap aplicado"
fi

# Aplicar Deployment
kubectl apply -f deployment.yaml
echo "✅ Deployment aplicado"

# Aplicar Service
kubectl apply -f service.yaml
echo "✅ Service aplicado"

# Verificar estado
echo ""
echo "📊 Estado del deployment:"
kubectl get pods -n ecommerce -l app=order-service
echo ""
kubectl get svc -n ecommerce -l app=order-service

echo ""
echo "🌐 URLs de acceso:"
MINIKUBE_IP=$(minikube ip)
echo "  • NodePort: http://$MINIKUBE_IP:30083"
echo "  • Port-forward: kubectl port-forward svc/order-service -n ecommerce 30083:30083"
echo "  • Local access: http://127.0.0.1:30083"

echo ""
echo "✅ order-service desplegado exitosamente!"
