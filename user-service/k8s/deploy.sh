#!/bin/bash

echo "🚀 Deploying user-service to Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl not found. Please install kubectl first."
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

echo "✅ Kubernetes cluster accessible"

# Apply namespace
echo "📁 Creating namespace..."
kubectl apply -f namespace.yaml

# Apply ConfigMap
echo "⚙️ Applying ConfigMap..."
kubectl apply -f configmap.yaml

# Apply deployment and service
echo "🚀 Deploying application..."
kubectl apply -f deployment.yaml

# Wait for deployment to be ready
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/user-service -n ecommerce

# Show deployment status
echo "📊 Deployment Status:"
kubectl get pods -n ecommerce -l app=user-service
kubectl get svc -n ecommerce -l app=user-service

echo ""
echo "✅ Deployment completed!"
echo ""
echo "🔍 Useful commands:"
echo "  kubectl get pods -n ecommerce"
echo "  kubectl logs -f deployment/user-service -n ecommerce"
echo "  kubectl port-forward svc/user-service 8700:8700 -n ecommerce"
echo ""
echo "🌐 To access the service locally:"
echo "  kubectl port-forward svc/user-service 8700:8700 -n ecommerce"
echo "  Then open: http://localhost:8700/actuator/health" 