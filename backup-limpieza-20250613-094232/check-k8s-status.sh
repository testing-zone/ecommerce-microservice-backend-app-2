#!/bin/bash

echo "=== KUBERNETES STATUS CHECK ==="
echo ""

echo "1. Cluster Info:"
kubectl cluster-info

echo ""
echo "2. Namespaces:"
kubectl get namespaces

echo ""
echo "3. All resources in ecommerce namespace:"
kubectl get all -n ecommerce

echo ""
echo "4. Docker images available:"
docker images | grep ecommerce

echo ""
echo "5. Services in ecommerce namespace:"
kubectl get svc -n ecommerce

echo ""
echo "6. Pods status:"
kubectl get pods -n ecommerce -o wide

echo ""
echo "=== STATUS CHECK COMPLETE ===" 