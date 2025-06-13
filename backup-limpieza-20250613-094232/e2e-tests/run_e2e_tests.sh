#!/bin/bash

echo "🧪 EJECUTANDO PRUEBAS E2E..."
echo "============================"

# Instalar pytest si no está disponible
if ! command -v pytest &> /dev/null; then
    echo "Instalando pytest..."
    pip3 install pytest requests
fi

# Configurar port-forwarding para pruebas
echo "Configurando port-forwarding..."
kubectl port-forward service/user-service 18081:8081 -n ecommerce > /dev/null 2>&1 &
PF1_PID=$!
kubectl port-forward service/product-service 18082:8082 -n ecommerce > /dev/null 2>&1 &
PF2_PID=$!
kubectl port-forward service/order-service 18083:8083 -n ecommerce > /dev/null 2>&1 &
PF3_PID=$!

# Esperar conexiones
sleep 10

# Ejecutar pruebas E2E
echo "Ejecutando pruebas E2E..."
pytest test_e2e.py -v --tb=short

# Cleanup
kill $PF1_PID $PF2_PID $PF3_PID 2>/dev/null

echo "✅ Pruebas E2E completadas"
