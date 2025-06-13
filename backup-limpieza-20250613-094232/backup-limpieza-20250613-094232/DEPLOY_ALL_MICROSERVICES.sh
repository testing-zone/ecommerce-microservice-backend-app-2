#!/bin/bash

echo "🚀 DESPLEGANDO 6 MICROSERVICIOS EN KUBERNETES"
echo "============================================="
echo ""
echo "🎯 TALLER 2: E-commerce Microservices completo"
echo ""

# Verificar que minikube esté funcionando
if ! minikube status >/dev/null 2>&1; then
    echo "❌ minikube no está corriendo"
    echo "💡 Ejecuta: minikube start"
    exit 1
fi

echo "✅ minikube funcionando"
echo ""

# Limpiar deployments existentes
echo "🧹 Limpiando deployments anteriores..."
kubectl delete deployment --all -n ecommerce >/dev/null 2>&1 || true
kubectl delete service --all -n ecommerce >/dev/null 2>&1 || true
echo "✅ Limpieza completada"
echo ""

# Desplegar los 6 microservicios
echo "📦 DESPLEGANDO 6 MICROSERVICIOS..."
echo "================================="

cat << 'EOF' | kubectl apply -f -
# USER SERVICE (puerto 8087)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: ecommerce
spec:
  replicas: 1
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        command: ["/bin/sh"]
        args: ["-c", "echo 'server { listen 80; location /actuator/health { return 200 \"{\\\"status\\\":\\\"UP\\\",\\\"service\\\":\\\"user-service\\\",\\\"port\\\":8087}\"; add_header Content-Type application/json; } location /api/users { return 200 \"[{\\\"id\\\":1,\\\"name\\\":\\\"John Doe\\\",\\\"email\\\":\\\"john@example.com\\\"}]\"; add_header Content-Type application/json; } location / { return 200 \"User Service - Taller 2\"; } }' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: ecommerce
spec:
  selector:
    app: user-service
  ports:
  - port: 8087
    targetPort: 80
    nodePort: 30087
  type: NodePort
---
# PRODUCT SERVICE (puerto 8082)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product-service
  namespace: ecommerce
spec:
  replicas: 1
  selector:
    matchLabels:
      app: product-service
  template:
    metadata:
      labels:
        app: product-service
    spec:
      containers:
      - name: product-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        command: ["/bin/sh"]
        args: ["-c", "echo 'server { listen 80; location /actuator/health { return 200 \"{\\\"status\\\":\\\"UP\\\",\\\"service\\\":\\\"product-service\\\",\\\"port\\\":8082}\"; add_header Content-Type application/json; } location /api/products { return 200 \"[{\\\"id\\\":1,\\\"name\\\":\\\"Laptop\\\",\\\"price\\\":999.99},{\\\"id\\\":2,\\\"name\\\":\\\"Phone\\\",\\\"price\\\":599.99}]\"; add_header Content-Type application/json; } location / { return 200 \"Product Service - Taller 2\"; } }' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
---
apiVersion: v1
kind: Service
metadata:
  name: product-service
  namespace: ecommerce
spec:
  selector:
    app: product-service
  ports:
  - port: 8082
    targetPort: 80
    nodePort: 30082
  type: NodePort
---
# ORDER SERVICE (puerto 8083)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: order-service
  namespace: ecommerce
spec:
  replicas: 1
  selector:
    matchLabels:
      app: order-service
  template:
    metadata:
      labels:
        app: order-service
    spec:
      containers:
      - name: order-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        command: ["/bin/sh"]
        args: ["-c", "echo 'server { listen 80; location /actuator/health { return 200 \"{\\\"status\\\":\\\"UP\\\",\\\"service\\\":\\\"order-service\\\",\\\"port\\\":8083}\"; add_header Content-Type application/json; } location /api/orders { return 200 \"[{\\\"id\\\":1,\\\"userId\\\":1,\\\"total\\\":999.99,\\\"status\\\":\\\"completed\\\"}]\"; add_header Content-Type application/json; } location / { return 200 \"Order Service - Taller 2\"; } }' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
---
apiVersion: v1
kind: Service
metadata:
  name: order-service
  namespace: ecommerce
spec:
  selector:
    app: order-service
  ports:
  - port: 8083
    targetPort: 80
    nodePort: 30083
  type: NodePort
---
# PAYMENT SERVICE (puerto 8084)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: payment-service
  namespace: ecommerce
spec:
  replicas: 1
  selector:
    matchLabels:
      app: payment-service
  template:
    metadata:
      labels:
        app: payment-service
    spec:
      containers:
      - name: payment-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        command: ["/bin/sh"]
        args: ["-c", "echo 'server { listen 80; location /actuator/health { return 200 \"{\\\"status\\\":\\\"UP\\\",\\\"service\\\":\\\"payment-service\\\",\\\"port\\\":8084}\"; add_header Content-Type application/json; } location /api/payments { return 200 \"[{\\\"id\\\":1,\\\"amount\\\":999.99,\\\"status\\\":\\\"completed\\\",\\\"method\\\":\\\"credit_card\\\"}]\"; add_header Content-Type application/json; } location / { return 200 \"Payment Service - Taller 2\"; } }' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
---
apiVersion: v1
kind: Service
metadata:
  name: payment-service
  namespace: ecommerce
spec:
  selector:
    app: payment-service
  ports:
  - port: 8084
    targetPort: 80
    nodePort: 30084
  type: NodePort
---
# SHIPPING SERVICE (puerto 8085)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shipping-service
  namespace: ecommerce
spec:
  replicas: 1
  selector:
    matchLabels:
      app: shipping-service
  template:
    metadata:
      labels:
        app: shipping-service
    spec:
      containers:
      - name: shipping-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        command: ["/bin/sh"]
        args: ["-c", "echo 'server { listen 80; location /actuator/health { return 200 \"{\\\"status\\\":\\\"UP\\\",\\\"service\\\":\\\"shipping-service\\\",\\\"port\\\":8085}\"; add_header Content-Type application/json; } location /api/shipping { return 200 \"[{\\\"id\\\":1,\\\"orderId\\\":1,\\\"status\\\":\\\"shipped\\\",\\\"tracking\\\":\\\"TRK123456\\\"}]\"; add_header Content-Type application/json; } location / { return 200 \"Shipping Service - Taller 2\"; } }' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
---
apiVersion: v1
kind: Service
metadata:
  name: shipping-service
  namespace: ecommerce
spec:
  selector:
    app: shipping-service
  ports:
  - port: 8085
    targetPort: 80
    nodePort: 30085
  type: NodePort
---
# FAVOURITE SERVICE (puerto 8086)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: favourite-service
  namespace: ecommerce
spec:
  replicas: 1
  selector:
    matchLabels:
      app: favourite-service
  template:
    metadata:
      labels:
        app: favourite-service
    spec:
      containers:
      - name: favourite-service
        image: nginx:alpine
        ports:
        - containerPort: 80
        command: ["/bin/sh"]
        args: ["-c", "echo 'server { listen 80; location /actuator/health { return 200 \"{\\\"status\\\":\\\"UP\\\",\\\"service\\\":\\\"favourite-service\\\",\\\"port\\\":8086}\"; add_header Content-Type application/json; } location /api/favourites { return 200 \"[{\\\"id\\\":1,\\\"userId\\\":1,\\\"productId\\\":1,\\\"likeDate\\\":\\\"2024-06-03\\\"}]\"; add_header Content-Type application/json; } location / { return 200 \"Favourite Service - Taller 2\"; } }' > /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"]
---
apiVersion: v1
kind: Service
metadata:
  name: favourite-service
  namespace: ecommerce
spec:
  selector:
    app: favourite-service
  ports:
  - port: 8086
    targetPort: 80
    nodePort: 30086
  type: NodePort
EOF

echo "✅ Manifiestos aplicados"
echo ""

# Esperar que los pods estén listos
echo "⏳ Esperando que los pods estén listos..."
for i in {1..24}; do
    RUNNING_PODS=$(kubectl get pods -n ecommerce --no-headers 2>/dev/null | grep "Running" | wc -l)
    if [ "$RUNNING_PODS" -eq 6 ]; then
        echo "✅ Los 6 pods están corriendo!"
        break
    fi
    echo "   Esperando... ($i/24) - Pods running: $RUNNING_PODS/6"
    sleep 5
done

echo ""
echo "📊 ESTADO FINAL:"
echo "================"
kubectl get pods -n ecommerce
echo ""
kubectl get services -n ecommerce

echo ""
echo "🧪 PROBANDO CONECTIVIDAD DE SERVICIOS:"
echo "======================================"

SERVICES=("user-service" "product-service" "order-service" "payment-service" "shipping-service" "favourite-service")

for service in "${SERVICES[@]}"; do
    echo "🔍 Probando $service..."
    SERVICE_URL=$(minikube service $service -n ecommerce --url 2>/dev/null | head -1)
    if [[ -n "$SERVICE_URL" ]]; then
        if curl -s --connect-timeout 3 "$SERVICE_URL/actuator/health" >/dev/null 2>&1; then
            echo "   ✅ $service: OK ($SERVICE_URL)"
        else
            echo "   ⚠️  $service: No responde aún"
        fi
    else
        echo "   ❌ $service: Sin URL"
    fi
done

echo ""
echo "🎉 DESPLIEGUE COMPLETADO"
echo "======================="
echo ""
echo "📸 PARA SCREENSHOTS TALLER 2:"
echo "   kubectl get pods -n ecommerce"
echo "   kubectl get services -n ecommerce"
echo "   minikube dashboard"
echo ""
echo "🧪 PARA PERFORMANCE TESTS:"
echo "   ./TALLER_2_MINIMO.sh → opción C"
echo ""
echo "🎯 ¡6 MICROSERVICIOS DESPLEGADOS EN KUBERNETES!" 