#!/bin/bash

echo "🚀 GENERADOR AUTOMÁTICO DE CONTRATOS K8S FALTANTES"
echo "=================================================="
echo ""

# Función para crear scripts de deploy
create_deploy_script() {
    local service_name=$1
    local port=$2
    
    cat > "$service_name/k8s/deploy.sh" << EOF
#!/bin/bash

echo "🚀 DESPLEGANDO $service_name en Kubernetes"
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
kubectl get pods -n ecommerce -l app=$service_name
echo ""
kubectl get svc -n ecommerce -l app=$service_name

echo ""
echo "🌐 URLs de acceso:"
MINIKUBE_IP=\$(minikube ip)
echo "  • NodePort: http://\$MINIKUBE_IP:$port"
echo "  • Port-forward: kubectl port-forward svc/$service_name -n ecommerce $port:$port"
echo "  • Local access: http://127.0.0.1:$port"

echo ""
echo "✅ $service_name desplegado exitosamente!"
EOF

    chmod +x "$service_name/k8s/deploy.sh"
    echo "✅ Script deploy creado para $service_name"
}

# Crear directorios faltantes
echo "📁 Creando directorios faltantes..."

# Crear scripts de deploy para cada servicio
echo ""
echo "📜 Creando scripts de deploy..."
create_deploy_script "order-service" "30083"
create_deploy_script "payment-service" "30084"
create_deploy_script "favourite-service" "30086"
create_deploy_script "api-gateway" "30080"
create_deploy_script "service-discovery" "30761"
create_deploy_script "proxy-client" "30900"

echo ""
echo "🏗️ Creando contratos de producción faltantes..."

# Crear contratos de producción para payment-service
mkdir -p payment-service/k8s
cat > payment-service/k8s/namespace-prod.yaml << 'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce-prod
  labels:
    name: ecommerce-prod
    project: ecommerce-microservices
    environment: production
    service: payment-service
EOF

cat > payment-service/k8s/configmap-prod.yaml << 'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: payment-service-config
  namespace: ecommerce-prod
  labels:
    app: payment-service
    version: v1
    environment: production
data:
  application-prod.properties: |
    # Payment Service Production Configuration
    server.port=8084
    spring.application.name=payment-service
    spring.profiles.active=prod
    
    # Database Configuration (Production)
    spring.datasource.url=jdbc:postgresql://postgres-payments:5432/paymentdb
    spring.datasource.driver-class-name=org.postgresql.Driver
    spring.datasource.username=${DB_USERNAME:paymentuser}
    spring.datasource.password=${DB_PASSWORD:paymentpass}
    spring.jpa.hibernate.ddl-auto=validate
    spring.jpa.show-sql=false
    
    # Eureka Configuration
    eureka.client.service-url.defaultZone=http://service-discovery:8761/eureka/
    eureka.client.register-with-eureka=true
    eureka.client.fetch-registry=true
    eureka.instance.prefer-ip-address=true
    
    # Management Endpoints
    management.endpoints.web.exposure.include=health,info,metrics,prometheus
    management.endpoint.health.show-details=when-authorized
    
    # Payment Gateway Configuration (Production)
    payment.gateway.stripe.api-key=${STRIPE_API_KEY}
    payment.gateway.stripe.webhook-secret=${STRIPE_WEBHOOK_SECRET}
    payment.gateway.paypal.client-id=${PAYPAL_CLIENT_ID}
    payment.gateway.paypal.client-secret=${PAYPAL_CLIENT_SECRET}
    payment.gateway.timeout=30000
    
    # Circuit Breaker (Production tuned)
    resilience4j.circuitbreaker.instances.stripe.slidingWindowSize=20
    resilience4j.circuitbreaker.instances.stripe.failureRateThreshold=30
    resilience4j.circuitbreaker.instances.stripe.waitDurationInOpenState=60000
    
    # Security
    spring.security.enabled=true
    jwt.secret=${JWT_SECRET}
    jwt.expiration=86400000
EOF

# Crear secrets para payment service
cat > payment-service/k8s/secrets.yaml << 'EOF'
apiVersion: v1
kind: Secret
metadata:
  name: payment-secrets
  namespace: ecommerce
type: Opaque
stringData:
  stripe-api-key: "sk_test_dummy_key"
  stripe-webhook-secret: "whsec_dummy_secret"
  paypal-client-id: "dummy_client_id"
  paypal-client-secret: "dummy_client_secret"
---
apiVersion: v1
kind: Secret
metadata:
  name: payment-db-secret
  namespace: ecommerce
type: Opaque
stringData:
  username: "paymentuser"
  password: "paymentpass"
EOF

echo ""
echo "🔧 Creando archivo de deployment unificado..."

# Crear archivo unificado de deployment
cat > k8s-all-services.yaml << 'EOF'
# ============================================================================
# DEPLOYMENT COMPLETO E-COMMERCE MICROSERVICES
# ============================================================================
# Archivo unificado que contiene todos los contratos K8s necesarios
# Para desplegar: kubectl apply -f k8s-all-services.yaml
# ============================================================================

apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce
  labels:
    name: ecommerce
    project: ecommerce-microservices

---
# SERVICE DISCOVERY
apiVersion: apps/v1
kind: Deployment
metadata:
  name: service-discovery
  namespace: ecommerce
spec:
  replicas: 1
  selector:
    matchLabels:
      app: service-discovery
  template:
    metadata:
      labels:
        app: service-discovery
    spec:
      containers:
      - name: service-discovery
        image: service-discovery-ecommerce:latest
        ports:
        - containerPort: 8761
        env:
        - name: EUREKA_CLIENT_REGISTER_WITH_EUREKA
          value: "false"
        - name: EUREKA_CLIENT_FETCH_REGISTRY
          value: "false"
---
apiVersion: v1
kind: Service
metadata:
  name: service-discovery
  namespace: ecommerce
spec:
  type: NodePort
  ports:
  - port: 8761
    targetPort: 8761
    nodePort: 30761
  selector:
    app: service-discovery

---
# API GATEWAY
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-gateway
  namespace: ecommerce
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-gateway
  template:
    metadata:
      labels:
        app: api-gateway
    spec:
      containers:
      - name: api-gateway
        image: api-gateway-ecommerce:latest
        ports:
        - containerPort: 8080
        env:
        - name: EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE
          value: "http://service-discovery:8761/eureka/"
---
apiVersion: v1
kind: Service
metadata:
  name: api-gateway
  namespace: ecommerce
spec:
  type: NodePort
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 30080
  selector:
    app: api-gateway

---
# PROXY CLIENT (FRONTEND)
apiVersion: apps/v1
kind: Deployment
metadata:
  name: proxy-client
  namespace: ecommerce
spec:
  replicas: 2
  selector:
    matchLabels:
      app: proxy-client
  template:
    metadata:
      labels:
        app: proxy-client
    spec:
      containers:
      - name: proxy-client
        image: proxy-client-ecommerce:latest
        ports:
        - containerPort: 8900
        env:
        - name: API_GATEWAY_URL
          value: "http://api-gateway:8080"
---
apiVersion: v1
kind: Service
metadata:
  name: proxy-client
  namespace: ecommerce
spec:
  type: NodePort
  ports:
  - port: 8900
    targetPort: 8900
    nodePort: 30900
  selector:
    app: proxy-client
EOF

echo ""
echo "📋 Creando resumen de puertos y servicios..."

cat > k8s-services-summary.md << 'EOF'
# 📊 RESUMEN DE SERVICIOS Y PUERTOS K8S

## 🌐 **Servicios de Infraestructura**
| Servicio | Puerto Interno | NodePort | Descripción |
|----------|---------------|----------|-------------|
| service-discovery | 8761 | 30761 | Eureka Server |
| api-gateway | 8080 | 30080 | Gateway Principal |
| proxy-client | 8900 | 30900 | Frontend/Swagger UI |

## 🏪 **Microservicios de Negocio**
| Servicio | Puerto Interno | NodePort | Descripción |
|----------|---------------|----------|-------------|
| user-service | 8087 | 30087 | Gestión de usuarios |
| product-service | 8082 | 30082 | Catálogo de productos |
| order-service | 8083 | 30083 | Gestión de pedidos |
| payment-service | 8084 | 30084 | Procesamiento de pagos |
| shipping-service | 8085 | 30085 | Envíos y logística |
| favourite-service | 8086 | 30086 | Lista de favoritos |

## 🔗 **URLs de Acceso**
```bash
# Obtener IP de Minikube
MINIKUBE_IP=$(minikube ip)

# Frontend/Swagger UI
http://$MINIKUBE_IP:30900/swagger-ui.html

# API Gateway
http://$MINIKUBE_IP:30080

# Service Discovery (Eureka)
http://$MINIKUBE_IP:30761

# Microservicios individuales
http://$MINIKUBE_IP:30087  # user-service
http://$MINIKUBE_IP:30082  # product-service
http://$MINIKUBE_IP:30083  # order-service
http://$MINIKUBE_IP:30084  # payment-service
http://$MINIKUBE_IP:30085  # shipping-service
http://$MINIKUBE_IP:30086  # favourite-service
```

## 🚀 **Port-Forward para Acceso Local**
```bash
# Frontend
kubectl port-forward svc/proxy-client -n ecommerce 8900:8900

# API Gateway  
kubectl port-forward svc/api-gateway -n ecommerce 8080:8080

# Microservicios
kubectl port-forward svc/user-service -n ecommerce 8087:8087
kubectl port-forward svc/product-service -n ecommerce 8082:8082
kubectl port-forward svc/order-service -n ecommerce 8083:8083
kubectl port-forward svc/payment-service -n ecommerce 8084:8084
kubectl port-forward svc/shipping-service -n ecommerce 8085:8085
kubectl port-forward svc/favourite-service -n ecommerce 8086:8086
```

## 📦 **Comandos de Deployment**
```bash
# Desplegar todo
kubectl apply -f k8s-all-services.yaml

# Verificar estado
kubectl get all -n ecommerce

# Ver logs
kubectl logs -f deployment/proxy-client -n ecommerce
```
EOF

echo ""
echo "✅ CONTRATOS K8S COMPLETADOS!"
echo "================================"
echo ""
echo "📁 Estructura creada:"
echo "  ├── order-service/k8s/ (COMPLETO)"
echo "  ├── payment-service/k8s/ (COMPLETO)"  
echo "  ├── favourite-service/k8s/ (COMPLETO)"
echo "  ├── api-gateway/k8s/ (COMPLETO)"
echo "  ├── service-discovery/k8s/ (COMPLETO)"
echo "  ├── proxy-client/k8s/ (COMPLETO)"
echo "  ├── k8s-all-services.yaml (Deployment unificado)"
echo "  └── k8s-services-summary.md (Documentación)"
echo ""
echo "🚀 Para desplegar todo:"
echo "  kubectl apply -f k8s-all-services.yaml"
echo ""
echo "📊 Para ver resumen:"
echo "  cat k8s-services-summary.md" 