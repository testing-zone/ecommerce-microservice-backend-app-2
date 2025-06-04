#!/bin/bash

echo "🔍 VERIFICACIÓN DE SERVICIOS - E-COMMERCE"
echo "========================================="

echo ""
echo "📊 1. ESTADO DE KUBERNETES..."
echo "-----------------------------"
kubectl cluster-info
echo ""

echo "📦 2. PODS EN NAMESPACE ECOMMERCE..."
echo "------------------------------------"
kubectl get pods -n ecommerce -o wide
echo ""

echo "🌐 3. SERVICIOS DISPONIBLES..."
echo "------------------------------"
kubectl get services -n ecommerce
echo ""

echo "🔗 4. PROBANDO CONECTIVIDAD..."
echo "------------------------------"

# Port forward services para testing
echo "Configurando port-forwarding..."
kubectl port-forward service/user-service 18081:8081 -n ecommerce > /dev/null 2>&1 &
PF1_PID=$!
kubectl port-forward service/product-service 18082:8082 -n ecommerce > /dev/null 2>&1 &
PF2_PID=$!
kubectl port-forward service/order-service 18083:8083 -n ecommerce > /dev/null 2>&1 &
PF3_PID=$!

# Esperar un momento para que se establezcan las conexiones
sleep 5

echo ""
echo "🧪 Testing User Service (puerto 18081)..."
if curl -s --max-time 10 http://localhost:18081/actuator/health > /dev/null; then
    echo "✅ User Service: FUNCIONANDO"
    curl -s http://localhost:18081/actuator/health | grep -o '"status":"[^"]*"' || echo "   Respuesta recibida"
else
    echo "❌ User Service: NO RESPONDE"
fi

echo ""
echo "🧪 Testing Product Service (puerto 18082)..."
if curl -s --max-time 10 http://localhost:18082/actuator/health > /dev/null; then
    echo "✅ Product Service: FUNCIONANDO"
    curl -s http://localhost:18082/actuator/health | grep -o '"status":"[^"]*"' || echo "   Respuesta recibida"
else
    echo "❌ Product Service: NO RESPONDE"
fi

echo ""
echo "🧪 Testing Order Service (puerto 18083)..."
if curl -s --max-time 10 http://localhost:18083/actuator/health > /dev/null; then
    echo "✅ Order Service: FUNCIONANDO"
    curl -s http://localhost:18083/actuator/health | grep -o '"status":"[^"]*"' || echo "   Respuesta recibida"
else
    echo "❌ Order Service: NO RESPONDE"
fi

# Cleanup port forwards
kill $PF1_PID $PF2_PID $PF3_PID 2>/dev/null

echo ""
echo "📋 5. RESUMEN DE LOGS..."
echo "-----------------------"
echo "Últimas 5 líneas de logs de cada servicio:"
echo ""

echo "📝 User Service logs:"
kubectl logs -n ecommerce deployment/user-service --tail=5 || echo "   No hay logs disponibles"
echo ""

echo "📝 Product Service logs:"
kubectl logs -n ecommerce deployment/product-service --tail=5 || echo "   No hay logs disponibles"
echo ""

echo "📝 Order Service logs:"
kubectl logs -n ecommerce deployment/order-service --tail=5 || echo "   No hay logs disponibles"

echo ""
echo "🎯 6. ESTADO DE JENKINS..."
echo "-------------------------"
if curl -s --max-time 5 http://localhost:8081 > /dev/null; then
    echo "✅ Jenkins: ACCESIBLE en http://localhost:8081"
    echo "🔑 Contraseña admin: $(docker exec ebd58506eb05 cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo 'No disponible')"
else
    echo "❌ Jenkins: NO ACCESIBLE"
    echo "💡 Ejecutar: docker ps | grep jenkins"
fi

echo ""
echo "🎉 VERIFICACIÓN COMPLETADA"
echo "=========================="
echo ""
echo "📋 COMANDOS ÚTILES:"
echo "kubectl get pods -n ecommerce        # Ver estado de pods"
echo "kubectl logs -f deployment/user-service -n ecommerce  # Ver logs en tiempo real"
echo "kubectl describe pod <pod-name> -n ecommerce         # Detalles de un pod"
echo ""
echo "🚀 SIGUIENTE PASO:"
echo "Ejecutar: ./3-pruebas-performance.sh" 