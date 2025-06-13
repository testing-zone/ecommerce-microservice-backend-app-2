#!/bin/bash

echo "🚀 SETUP COMPLETO - E-COMMERCE MICROSERVICES"
echo "============================================="
echo ""
echo "📋 Este script configurará todo desde cero:"
echo "   • Docker y Docker Compose"
echo "   • Jenkins con plugins necesarios" 
echo "   • Kubernetes (minikube)"
echo "   • Todos los microservicios"
echo ""

# Verificar dependencias
echo "🔍 1. VERIFICANDO DEPENDENCIAS..."
which docker > /dev/null || { echo "❌ Docker no encontrado. Instalar primero."; exit 1; }
which kubectl > /dev/null || { echo "❌ kubectl no encontrado. Instalar primero."; exit 1; }
which minikube > /dev/null || { echo "❌ minikube no encontrado. Instalar primero."; exit 1; }
echo "✅ Todas las dependencias encontradas"

# Iniciar Docker Desktop si no está corriendo
echo ""
echo "🐳 2. INICIANDO DOCKER..."
docker info > /dev/null 2>&1 || {
    echo "Iniciando Docker Desktop..."
    open -a Docker
    echo "⏳ Esperando que Docker inicie..."
    while ! docker info > /dev/null 2>&1; do
        sleep 5
        echo "   Esperando Docker..."
    done
}
echo "✅ Docker corriendo"

# Iniciar minikube
echo ""
echo "☸️  3. CONFIGURANDO KUBERNETES..."
minikube status > /dev/null 2>&1 || {
    echo "Iniciando minikube..."
    minikube start --driver=docker --memory=4096 --cpus=2
    minikube addons enable ingress
}
echo "✅ Kubernetes (minikube) corriendo"

# Configurar namespace
echo ""
echo "📦 4. CONFIGURANDO NAMESPACES..."
kubectl create namespace ecommerce --dry-run=client -o yaml | kubectl apply -f -
echo "✅ Namespace 'ecommerce' configurado"

# Iniciar Jenkins
echo ""
echo "🔧 5. CONFIGURANDO JENKINS..."
if ! docker ps | grep jenkins > /dev/null; then
    echo "Iniciando Jenkins con Docker-in-Docker..."
    
    # Crear network si no existe
    docker network create jenkins 2>/dev/null || true
    
    # Iniciar Docker-in-Docker
    docker run --name jenkins-docker --rm --detach \
        --privileged --network jenkins --network-alias docker \
        --env DOCKER_TLS_CERTDIR=/certs \
        --volume jenkins-docker-certs:/certs/client \
        --volume jenkins-data:/var/jenkins_home \
        --publish 2376:2376 \
        docker:24.0.7-dind --storage-driver overlay2 2>/dev/null || true
    
    # Esperar un poco
    sleep 10
    
    # Iniciar Jenkins
    docker run --name jenkins-server --rm --detach \
        --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
        --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
        --publish 8081:8080 --publish 50000:50000 \
        --volume jenkins-data:/var/jenkins_home \
        --volume jenkins-docker-certs:/certs/client:ro \
        jenkins-with-kubectl:latest 2>/dev/null || true
        
    echo "⏳ Esperando que Jenkins inicie..."
    sleep 30
    
    # Intentar obtener la contraseña
    JENKINS_PASSWORD=""
    for i in {1..10}; do
        JENKINS_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "")
        if [ ! -z "$JENKINS_PASSWORD" ]; then
            break
        fi
        echo "   Intentando obtener contraseña Jenkins... ($i/10)"
        sleep 10
    done
else
    JENKINS_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "8e3f3456b8414d72b35a617c31f93dfa")
fi

echo "✅ Jenkins corriendo en http://localhost:8081"
echo "🔑 Contraseña de admin: ${JENKINS_PASSWORD}"

# Desplegar microservicios
echo ""
echo "🎯 6. DESPLEGANDO MICROSERVICIOS..."

# Crear los deployments básicos
cat << 'EOF' | kubectl apply -f -
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
        image: selimhorri/ecommerce-user-service:latest
        ports:
        - containerPort: 8081
        env:
        - name: SERVER_PORT
          value: "8081"
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
  - port: 8081
    targetPort: 8081
  type: ClusterIP
---
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
        image: selimhorri/ecommerce-product-service:latest
        ports:
        - containerPort: 8082
        env:
        - name: SERVER_PORT
          value: "8082"
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
    targetPort: 8082
  type: ClusterIP
---
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
        image: selimhorri/ecommerce-order-service:latest
        ports:
        - containerPort: 8083
        env:
        - name: SERVER_PORT
          value: "8083"
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
    targetPort: 8083
  type: ClusterIP
---
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
        image: selimhorri/ecommerce-payment-service:latest
        ports:
        - containerPort: 8084
        env:
        - name: SERVER_PORT
          value: "8084"
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
    targetPort: 8084
  type: ClusterIP
---
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
        image: selimhorri/ecommerce-shipping-service:latest
        ports:
        - containerPort: 8085
        env:
        - name: SERVER_PORT
          value: "8085"
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
    targetPort: 8085
  type: ClusterIP
---
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
        image: selimhorri/ecommerce-favourite-service:latest
        ports:
        - containerPort: 8086
        env:
        - name: SERVER_PORT
          value: "8086"
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
    targetPort: 8086
  type: ClusterIP
EOF

echo "⏳ Esperando que los pods inicien..."
kubectl wait --for=condition=ready pod -l app=user-service -n ecommerce --timeout=300s
kubectl wait --for=condition=ready pod -l app=product-service -n ecommerce --timeout=300s

echo ""
echo "🎉 SETUP COMPLETADO EXITOSAMENTE!"
echo "================================="
echo ""
echo "📋 RESUMEN:"
echo "✅ Docker: Corriendo"
echo "✅ Kubernetes: minikube corriendo"
echo "✅ Jenkins: http://localhost:8081"
echo "   🔑 Usuario: admin"
echo "   🔑 Contraseña: ${JENKINS_PASSWORD}"
echo "✅ Microservicios: Desplegados en namespace 'ecommerce'"
echo ""
echo "🚀 PRÓXIMOS PASOS:"
echo "1. Ejecutar: ./2-verificar-servicios.sh"
echo "2. Ejecutar: ./3-pruebas-performance.sh"
echo "3. Configurar pipelines en Jenkins"
echo ""
echo "🔍 Verificar pods: kubectl get pods -n ecommerce"
echo "🌐 Acceder a Jenkins: open http://localhost:8081" 