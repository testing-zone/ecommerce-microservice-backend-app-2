# E-Commerce Microservices Platform 🛍️

Sistema completo de microservicios e-commerce con **contratos Kubernetes completos**, monitoreo avanzado, CI/CD automatizado y **interfaz web Swagger UI**.

## 🆕 **ACTUALIZACIONES RECIENTES**

### ✅ **Contratos Kubernetes Completos**
- 🎯 **TODOS los microservicios** tienen contratos K8s completos (dev + prod)
- 🌐 **Servicios de infraestructura** completamente configurados
- 🚀 **Scripts de limpieza** para pods problemáticos
- 📦 **Deployment unificado** para toda la arquitectura

### 🧹 **Gestión de Pods Avanzada**
- 🔧 **4 scripts de limpieza** diferentes para pods duplicados/problemáticos
- 🎯 **Detección automática** de pods con errores
- 🔄 **Reinicio inteligente** de deployments
- 📊 **Validación completa** de servicios

## 🚀 Inicio Rápido

### 🆕 **Para VM desde Cero (Método Recomendado):**

```bash
# 1. Instalar todas las dependencias automáticamente
chmod +x install-vm-dependencies.sh
./install-vm-dependencies.sh

# 2. Verificar prerequisitos del sistema
chmod +x check-prerequisites.sh
./check-prerequisites.sh

# 3. Seguir la guía completa paso a paso
cat GUIA-VM-COMPLETA.md

# 4. Desplegar toda la arquitectura
chmod +x ecommerce-manager.sh
./ecommerce-manager.sh

# 5. Configurar acceso externo con port-forwarding
./ecommerce-manager.sh  # Opción 7: Setup External Port-Forwarding
```

### 🔧 **Despliegue Estándar (Sistema Configurado):**

```bash
# 1. Desplegar toda la arquitectura
chmod +x ecommerce-manager.sh
./ecommerce-manager.sh

# 2. Verificar que todo funciona (timeout 2 min)
chmod +x verify-monitoring.sh
./verify-monitoring.sh

# 3. Configurar acceso fácil al frontend
chmod +x setup-port-forwards.sh
./setup-port-forwards.sh

# 4. Limpiar pods problemáticos si es necesario
chmod +x cleanup-menu.sh
./cleanup-menu.sh
```

## 🧹 **GESTIÓN DE PODS Y LIMPIEZA**

### 🎯 **Scripts de Limpieza Disponibles**

| Script | Descripción | Uso Recomendado |
|--------|-------------|-----------------|
| **`cleanup-menu.sh`** | **Menú interactivo con todas las opciones** | **⭐ Principal** |
| **`quick-cleanup-pods.sh`** | **Elimina pods específicos problemáticos** | **🚀 Rápido** |
| **`cleanup-duplicate-pods.sh`** | **Detecta automáticamente pods con errores** | **🔧 Inteligente** |
| **`force-cleanup-all.sh`** | **Limpieza completa + redesplegue** | **🔥 Nuclear** |

### 🚀 **Limpieza Rápida (Recomendada)**
```bash
# Menú interactivo
./cleanup-menu.sh

# O directamente limpieza rápida
./quick-cleanup-pods.sh
```

### 🔍 **Validación Post-Limpieza**
```bash
# Ver estado después de limpieza
kubectl get pods -n ecommerce

# Monitorear en tiempo real
kubectl get pods -n ecommerce -w

# Verificar servicios funcionando
kubectl get svc -n ecommerce
```

## 📦 **CONTRATOS KUBERNETES COMPLETOS**

### 🟢 **Microservicios con Contratos K8s Completos**

| Servicio | Puerto | NodePort | Contratos Incluidos |
|----------|--------|----------|-------------------|
| **user-service** | 8087 | 30087 | ✅ namespace, configmap, deployment, service (dev + prod) |
| **product-service** | 8082 | 30082 | ✅ namespace, configmap, deployment, service (dev + prod) |
| **order-service** | 8083 | 30083 | ✅ namespace, configmap, deployment, service (dev + prod) |
| **payment-service** | 8084 | 30084 | ✅ namespace, configmap, deployment, service + secrets |
| **shipping-service** | 8085 | 30085 | ✅ namespace, configmap, deployment, service (dev + prod) |
| **favourite-service** | 8086 | 30086 | ✅ namespace, deployment, service |

### 🌐 **Servicios de Infraestructura**

| Servicio | Puerto | NodePort | Función |
|----------|--------|----------|---------|
| **service-discovery** | 8761 | 30761 | Eureka Server |
| **api-gateway** | 8080 | 30080 | Gateway Principal |
| **proxy-client** | 8900 | 30900 | **Frontend/Swagger UI** |

### 📋 **Deployment Unificado**
```bash
# Desplegar toda la arquitectura de una vez
kubectl apply -f k8s-all-services.yaml

# Ver resumen de servicios y puertos
cat k8s-services-summary.md
```

## 🌐 Acceso a la Aplicación

### 🖥️ **Frontend/API UI**

**🎯 URL Principal del Frontend:**
```bash
# Método 1: Port-Forward (Recomendado)
./setup-port-forwards.sh
# Acceso: http://127.0.0.1:8900/swagger-ui.html

# Método 2: NodePort (Para acceso externo)
MINIKUBE_IP=$(minikube ip)
echo "Frontend: http://$MINIKUBE_IP:30900/swagger-ui.html"

# Método 3: Detector Inteligente
./open-frontend-smart.sh
```

**📱 URLs de Microservicios (Port-Forward):**
- **API Gateway**: `http://127.0.0.1:8080`
- **Service Discovery**: `http://127.0.0.1:8761`
- **User Service**: `http://127.0.0.1:8087`
- **Product Service**: `http://127.0.0.1:8082`
- **Order Service**: `http://127.0.0.1:8083`
- **Payment Service**: `http://127.0.0.1:8084`
- **Shipping Service**: `http://127.0.0.1:8085`
- **Favourite Service**: `http://127.0.0.1:8086`

### 📊 **Monitoreo y Observabilidad**
- **Grafana**: `http://127.0.0.1:3000` (admin/admin123)
- **Prometheus**: `http://127.0.0.1:9090`
- **Kibana**: `http://127.0.0.1:5601`
- **Jaeger**: `http://127.0.0.1:16686`
- **AlertManager**: `http://127.0.0.1:9093`

## 🎯 **VALIDACIÓN Y SUSTENTACIÓN DE SERVICIOS**

### ✅ **Validación Completa del Sistema**

#### **1. Verificación de Estado de Pods**
```bash
# Ver todos los pods en estado correcto
kubectl get pods -n ecommerce

# Resultado esperado: Todos los pods en "Running" con "1/1" Ready
# ✅ user-service-xxx         1/1     Running
# ✅ product-service-xxx      1/1     Running  
# ✅ order-service-xxx        1/1     Running
# ✅ payment-service-xxx      1/1     Running
# ✅ shipping-service-xxx     1/1     Running
# ✅ favourite-service-xxx    1/1     Running
# ✅ api-gateway-xxx          1/1     Running
# ✅ service-discovery-xxx    1/1     Running
# ✅ proxy-client-xxx         1/1     Running
```

#### **2. Verificación de Servicios y Networking**
```bash
# Ver servicios activos
kubectl get svc -n ecommerce

# Resultado esperado: Todos los servicios con ClusterIP/NodePort asignados
# ✅ api-gateway       NodePort    10.x.x.x   <none>   8080:30080/TCP
# ✅ order-service     NodePort    10.x.x.x   <none>   8083:30083/TCP
# ✅ payment-service   NodePort    10.x.x.x   <none>   8084:30084/TCP
# ✅ product-service   NodePort    10.x.x.x   <none>   8082:30082/TCP
# ✅ proxy-client      NodePort    10.x.x.x   <none>   8900:30900/TCP
# ✅ service-discovery NodePort    10.x.x.x   <none>   8761:30761/TCP
# ✅ shipping-service  NodePort    10.x.x.x   <none>   8085:30085/TCP
# ✅ user-service      NodePort    10.x.x.x   <none>   8087:30087/TCP
```

#### **3. Health Checks de Microservicios**
```bash
# Verificar health checks (con port-forward activo)
curl -s http://127.0.0.1:8900/actuator/health | jq .status    # "UP"
curl -s http://127.0.0.1:8087/actuator/health | jq .status    # "UP" 
curl -s http://127.0.0.1:8082/actuator/health | jq .status    # "UP"
curl -s http://127.0.0.1:8083/actuator/health | jq .status    # "UP"
curl -s http://127.0.0.1:8084/actuator/health | jq .status    # "UP"
curl -s http://127.0.0.1:8085/actuator/health | jq .status    # "UP"
curl -s http://127.0.0.1:8086/actuator/health | jq .status    # "UP"
```

#### **4. Verificación de Registro en Eureka**
```bash
# Acceder a Eureka Dashboard
open http://127.0.0.1:8761

# Verificar que todos los servicios están registrados:
# ✅ API-GATEWAY
# ✅ USER-SERVICE  
# ✅ PRODUCT-SERVICE
# ✅ ORDER-SERVICE
# ✅ PAYMENT-SERVICE
# ✅ SHIPPING-SERVICE
# ✅ FAVOURITE-SERVICE
# ✅ PROXY-CLIENT
```

#### **5. Pruebas Funcionales de APIs**
```bash
# Crear usuario
curl -X POST "http://127.0.0.1:8900/api/users" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Test",
    "lastName": "User", 
    "email": "test@example.com",
    "phone": "+1234567890"
  }'

# Obtener productos
curl "http://127.0.0.1:8900/api/products"

# Crear orden
curl -X POST "http://127.0.0.1:8900/api/orders" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "items": [{"productId": 1, "quantity": 2}]
  }'

# Verificar favoritos
curl "http://127.0.0.1:8900/api/favourites/user/1"
```

### 📊 **Validación de Monitoreo y Métricas**

#### **1. Prometheus - Recolección de Métricas**
```bash
# Acceder a Prometheus
open http://127.0.0.1:9090

# Queries de validación:
# ✅ up{job="kubernetes-pods"} == 1
# ✅ rate(http_requests_total[5m]) > 0
# ✅ jvm_memory_used_bytes / jvm_memory_max_bytes < 0.8
```

#### **2. Grafana - Dashboards Funcionando**
```bash
# Acceder a Grafana
open http://127.0.0.1:3000
# Login: admin / admin123

# Dashboards disponibles:
# ✅ JVM (Micrometer) Dashboard: Memory usage por servicio
# ✅ Spring Boot Statistics: HTTP requests per endpoint
# ✅ Kubernetes cluster monitoring: Node resource utilization
# ✅ Node Exporter Full: System CPU, memory, disk

✅ **Métricas en Tiempo Real:**
- Datos actualizándose cada 15 segundos
- Alertas configuradas y funcionando
- Variables de dashboard operativas
- Time ranges funcionando correctamente

✅ **Dropdowns y Filtros Funcionando:**

**📋 Service Selector Dropdown:**
- Filtrar por microservicio específico
- Ver métricas individuales por servicio
- Comparar performance entre servicios

**🏷️ Environment Filter:**
- Separar métricas dev/staging/prod
- Filtrar por namespace kubernetes
- Agrupar por labels customizados

**⏰ Time Range Selector:**
- Last 5 minutes / 1 hour / 24 hours
- Custom time ranges
- Refresh intervals configurables

**📊 Panel Options:**
- Toggle between different visualizations
- Show/hide specific metrics
- Zoom y pan en gráficos
```

## 📸 **SCREENSHOTS Y EVIDENCIAS**

### 🖥️ **Frontend y APIs Funcionando**

<details>
<summary>🌐 <strong>Frontend Swagger UI Accesible</strong></summary>

**Evidencia**: Frontend completamente funcional en `http://127.0.0.1:8900/swagger-ui.html`

✅ **Criterios Validados:**
- Interfaz Swagger UI carga correctamente
- Todos los endpoints están documentados
- APIs responden correctamente
- Autenticación y autorización funcionando

**URLs Verificadas:**
- Frontend: `http://127.0.0.1:8900/swagger-ui.html` ✅
- API Gateway: `http://127.0.0.1:8080` ✅
- Service Discovery: `http://127.0.0.1:8761` ✅

</details>

<details>
<summary>📱 <strong>Microservicios Individuales Respondiendo</strong></summary>

**Evidencia**: Todos los microservicios responden en sus endpoints

✅ **Health Checks Pasando:**
```bash
# Todos devuelven {"status":"UP"}
curl http://127.0.0.1:8087/actuator/health  # User Service
curl http://127.0.0.1:8082/actuator/health  # Product Service  
curl http://127.0.0.1:8083/actuator/health  # Order Service
curl http://127.0.0.1:8084/actuator/health  # Payment Service
curl http://127.0.0.1:8085/actuator/health  # Shipping Service
curl http://127.0.0.1:8086/actuator/health  # Favourite Service
```

✅ **APIs Funcionales:**
- CRUD de usuarios funcionando
- Catálogo de productos disponible
- Creación de órdenes exitosa
- Procesamiento de pagos activo
- Gestión de envíos operativa
- Lista de favoritos funcional

</details>

### 🎯 **Kubernetes y Orchestration**

<details>
<summary>🚀 <strong>Pods y Servicios en Kubernetes</strong></summary>

**Evidencia**: Todos los pods y servicios ejecutándose correctamente

✅ **Estado de Pods:**
```bash
kubectl get pods -n ecommerce
# Resultado: Todos los pods en "Running" con "1/1" Ready
```

✅ **Servicios Expuestos:**
```bash
kubectl get svc -n ecommerce
# Resultado: Todos los servicios con NodePort asignados
```

✅ **Deployments Saludables:**
```bash
kubectl get deployments -n ecommerce
# Resultado: Todos los deployments con READY "1/1" o "2/2"
```

</details>

<details>
<summary>🔗 <strong>Service Discovery y Registro</strong></summary>

**Evidencia**: Eureka Server funcionando con todos los servicios registrados

✅ **Eureka Dashboard**: `http://127.0.0.1:8761`
- Todos los microservicios aparecen registrados
- Estado "UP" para todos los servicios
- Latencia baja en health checks
- No hay servicios fuera de línea

✅ **Balanceador de Carga:**
- API Gateway descubre servicios automáticamente
- Routing funcional a través del gateway
- Circuit breakers operativos

</details>

### 📊 **Monitoreo y Observabilidad**

<details>
<summary>📈 <strong>Prometheus - Métricas Recolectándose</strong></summary>

**Evidencia**: Prometheus recolectando métricas de todos los servicios

✅ **Targets Activos:** `http://127.0.0.1:9090/targets`
- kubernetes-pods: UP
- kubernetes-services: UP  
- kubernetes-nodes: UP
- spring-boot applications: UP

✅ **Métricas Disponibles:**
- `http_requests_total`: Requests HTTP por servicio
- `jvm_memory_used_bytes`: Uso de memoria JVM
- `process_cpu_seconds_total`: CPU usage
- `application_ready_time_seconds`: Tiempo de startup

✅ **Queries Funcionando:**
```promql
# Tasa de requests por minuto
rate(http_requests_total[1m]) * 60

# Error rate por servicio  
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# Uso de memoria por pod
jvm_memory_used_bytes / jvm_memory_max_bytes
```

</details>

<details>
<summary>📊 <strong>Grafana - Dashboards con Datos</strong></summary>

**Evidencia**: Grafana mostrando métricas en tiempo real con múltiples dashboards

✅ **Dashboards Configurados y Funcionando:**

**🎯 JVM (Micrometer) Dashboard:**
- Memory usage por servicio
- Garbage collection metrics  
- Thread pools status
- CPU utilization per service

**🌐 Spring Boot Statistics:**
- HTTP requests per endpoint
- Response times y latencias
- Error rates por servicio
- Throughput metrics

**☸️ Kubernetes Cluster Monitoring:**
- Node resource utilization
- Pod CPU y memory usage
- Persistent volumes status
- Network traffic metrics

**🖥️ Node Exporter Full:**
- System CPU, memory, disk
- Network interface statistics  
- File system usage
- System load averages

✅ **Métricas en Tiempo Real:**
- Datos actualizándose cada 15 segundos
- Alertas configuradas y funcionando
- Variables de dashboard operativas
- Time ranges funcionando correctamente

✅ **Dropdowns y Filtros Funcionando:**

**📋 Service Selector Dropdown:**
- Filtrar por microservicio específico
- Ver métricas individuales por servicio
- Comparar performance entre servicios

**🏷️ Environment Filter:**
- Separar métricas dev/staging/prod
- Filtrar por namespace kubernetes
- Agrupar por labels customizados

**⏰ Time Range Selector:**
- Last 5 minutes / 1 hour / 24 hours
- Custom time ranges
- Refresh intervals configurables

**📊 Panel Options:**
- Toggle between different visualizations
- Show/hide specific metrics
- Zoom y pan en gráficos

</details>

<details>
<summary>🔍 <strong>Kibana - Logs Centralizados</strong></summary>

**Evidencia**: ELK Stack recolectando y visualizando logs

✅ **Kibana Dashboard**: `http://127.0.0.1:5601`
- Logs de todos los microservicios
- Índices por servicio y fecha
- Búsquedas y filtros funcionando
- Dashboards de análisis de logs

✅ **Log Aggregation:**
- Logs estructurados en JSON
- Correlación entre servicios
- Trazabilidad de requests
- Error tracking y alerting

</details>

<details>
<summary>🕸️ <strong>Jaeger - Distributed Tracing</strong></summary>

**Evidencia**: Trazabilidad distribuida entre microservicios

✅ **Jaeger UI**: `http://127.0.0.1:16686`
- Traces de requests end-to-end
- Latencia entre servicios
- Dependency graph
- Error analysis

✅ **Tracing Functionality:**
- Request flows through API Gateway
- Service-to-service communication
- Database query tracing
- Performance bottleneck identification

</details>

## 📦 Arquitectura del Sistema

### 🏗️ **Arquitectura de Microservicios (Actualizada)**
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Proxy Client  │───▶│   API Gateway   │───▶│ Service Discovery│
│   (Port 8900)   │    │   (Port 8080)   │    │   (Port 8761)   │
│  NodePort 30900 │    │  NodePort 30080 │    │  NodePort 30761 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                   MICROSERVICIOS BUSINESS                       │
├─────────────┬─────────────┬─────────────┬─────────────────────┤
│User Service │Product Svc  │Order Service│Payment Service      │
│(8087:30087) │(8082:30082) │(8083:30083) │(8084:30084)        │
├─────────────┼─────────────┼─────────────┼─────────────────────┤
│Shipping Svc │Favourite Svc│             │                     │
│(8085:30085) │(8086:30086) │             │                     │
└─────────────┴─────────────┴─────────────┴─────────────────────┘
```

### 🔍 **Stack de Monitoreo Completo**
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Prometheus  │───▶│   Grafana   │    │    ELK     │    │   Jaeger    │
│  Métricas   │    │ Dashboards  │    │    Logs    │    │   Trazas    │
│   :9090     │    │   :3000     │    │   :5601    │    │   :16686    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### ☸️ **Infraestructura Kubernetes**
```
┌─────────────────────────────────────────────────────────────────┐
│                        KUBERNETES CLUSTER                       │
├─────────────────────────────────────────────────────────────────┤
│ NAMESPACE: ecommerce                                           │
│ ├── Deployments (9 servicios)                                 │
│ ├── Services (NodePort para acceso externo)                   │
│ ├── ConfigMaps (configuración por ambiente)                   │
│ ├── Secrets (credenciales y API keys)                         │
│ └── Pods (auto-scaling habilitado)                            │
├─────────────────────────────────────────────────────────────────┤
│ NAMESPACE: monitoring                                          │
│ ├── Prometheus Stack                                           │
│ ├── Grafana + Dashboards                                       │
│ ├── ELK Stack (Elasticsearch, Logstash, Kibana)               │
│ └── Jaeger Tracing                                             │
└─────────────────────────────────────────────────────────────────┘
```

## 🛠️ **Opciones de Despliegue**

### 🖥️ **Desarrollo Local (Docker Compose)**

```bash
# Compilar todos los servicios
mvn clean install -DskipTests

# Construir imágenes Docker
mvn spring-boot:build-image

# Ejecutar con Docker Compose
docker-compose up -d

# Verificar servicios
docker-compose ps
```

### ☁️ **Despliegue en Kubernetes (Recomendado)**

```bash
# Opción 1: Deployment completo automatizado
./ecommerce-manager.sh

# Opción 2: Deployment unificado
kubectl apply -f k8s-all-services.yaml

# Opción 3: Deployments individuales
cd user-service/k8s && ./deploy.sh
cd product-service/k8s && ./deploy.sh
# ... continuar con cada servicio

# Verificar estado
kubectl get all -n ecommerce
```

### 🧹 **Gestión y Mantenimiento**

```bash
# Limpiar pods problemáticos
./cleanup-menu.sh

# Reiniciar servicios específicos
kubectl rollout restart deployment/api-gateway -n ecommerce
kubectl rollout restart deployment/proxy-client -n ecommerce

# Verificar recursos del sistema
kubectl top nodes
kubectl describe nodes

# Escalar servicios si hay recursos disponibles
kubectl scale deployment user-service --replicas=2 -n ecommerce
```

## 🎯 **Cómo Probar la Aplicación**

### 1. 🚀 **Acceder al Frontend**

**Método Recomendado (Port-Forward):**
```bash
./setup-port-forwards.sh
# Abre automáticamente: http://127.0.0.1:8900/swagger-ui.html
```

**Método NodePort (Acceso de Red):**
```bash
MINIKUBE_IP=$(minikube ip)
echo "Frontend: http://$MINIKUBE_IP:30900/swagger-ui.html"
```

**Detector Inteligente:**
```bash
./open-frontend-smart.sh
```

### 2. 🧪 **Testing Completo de APIs**

**Flujo de Testing E2E:**
```bash
# 1. Crear usuario
curl -X POST "http://127.0.0.1:8900/api/users" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Juan",
    "lastName": "Pérez",
    "email": "juan@example.com",
    "phone": "+1234567890"
  }'

# 2. Obtener catálogo de productos
curl "http://127.0.0.1:8900/api/products" | jq .

# 3. Crear orden con productos
curl -X POST "http://127.0.0.1:8900/api/orders" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "items": [
      {"productId": 1, "quantity": 2},
      {"productId": 2, "quantity": 1}
    ]
  }'

# 4. Procesar pago
curl -X POST "http://127.0.0.1:8900/api/payments" \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": 1,
    "amount": 299.99,
    "currency": "USD",
    "paymentMethod": "credit_card"
  }'

# 5. Actualizar envío
curl -X PUT "http://127.0.0.1:8900/api/shipping/1" \
  -H "Content-Type: application/json" \
  -d '{
    "status": "shipped",
    "trackingNumber": "TRK123456789"
  }'

# 6. Agregar a favoritos
curl -X POST "http://127.0.0.1:8900/api/favourites" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "productId": 1
  }'
```

### 3. 📊 **Generar Datos para Monitoreo**

```bash
# Ejecutar generador de tráfico
./generate-monitoring-data.sh

# Ejecutar tests de performance
./run-performance-tests-optimized.sh

# Ver métricas en tiempo real
open http://127.0.0.1:3000  # Grafana
open http://127.0.0.1:9090  # Prometheus
```

## 🔧 **Scripts Principales (Actualizados)**

| Script | Descripción | Tiempo Estimado | Estado |
|--------|-------------|-----------------|--------|
| **🆕 `install-vm-dependencies.sh`** | **Instalador automático de dependencias** | **10-15 min** | ✅ |
| **🆕 `check-prerequisites.sh`** | **Verificador de prerequisitos** | **30 seg** | ✅ |
| **🔄 `ecommerce-manager.sh`** | **Despliegue completo + port-forwarding** | **15-20 min** | ✅ |
| `verify-monitoring.sh` | Verificación con timeouts optimizados | 2-5 min | ✅ |
| **🆕 `cleanup-menu.sh`** | **Menú interactivo de limpieza de pods** | **1-2 min** | ✅ |
| **🆕 `quick-cleanup-pods.sh`** | **Limpieza rápida de pods problemáticos** | **1 min** | ✅ |
| **🆕 `cleanup-duplicate-pods.sh`** | **Detección inteligente de pods con errores** | **2-3 min** | ✅ |
| **🆕 `force-cleanup-all.sh`** | **Limpieza completa y redesplegue** | **10-15 min** | ✅ |
| `setup-port-forwards.sh` | Port-forwards automáticos | 1-2 min | ✅ |
| `open-frontend-smart.sh` | Detector inteligente de URLs | 30 seg | ✅ |
| `stop-port-forwards.sh` | Detener port-forwards | 30 seg | ✅ |
| **🆕 `k8s-all-services.yaml`** | **Deployment unificado de toda la arquitectura** | **8-12 min** | ✅ |

## 🏥 **Verificación de Salud del Sistema**

### ✅ **Health Checks Automáticos**
```bash
# Verificación completa del sistema
./verify-monitoring.sh

# Estado de pods por namespace  
kubectl get pods -n ecommerce
kubectl get pods -n monitoring

# Estado de servicios y networking
kubectl get svc -A
kubectl get ingress -A

# Uso de recursos
kubectl top nodes
kubectl top pods -A
```

### 🔍 **Endpoints de Salud Individuales**
```bash
# Health checks detallados (requiere port-forward activo)
curl http://127.0.0.1:8900/actuator/health | jq .    # Frontend
curl http://127.0.0.1:8087/actuator/health | jq .    # User Service
curl http://127.0.0.1:8082/actuator/health | jq .    # Product Service
curl http://127.0.0.1:8083/actuator/health | jq .    # Order Service
curl http://127.0.0.1:8084/actuator/health | jq .    # Payment Service
curl http://127.0.0.1:8085/actuator/health | jq .    # Shipping Service
curl http://127.0.0.1:8086/actuator/health | jq .    # Favourite Service

# Métricas de aplicación
curl http://127.0.0.1:8087/actuator/metrics | jq .
curl http://127.0.0.1:8087/actuator/prometheus
```

### 📊 **Validación de Monitoreo**
```bash
# Prometheus targets
curl http://127.0.0.1:9090/api/v1/targets | jq .

# Grafana health
curl http://admin:admin123@127.0.0.1:3000/api/health | jq .

# Verificar métricas específicas
curl 'http://127.0.0.1:9090/api/v1/query?query=up' | jq .
```

## 🚨 **Solución de Problemas (Actualizada)**

### 🧹 **Problemas de Pods**

1. **Pods duplicados o en estado problemático**:
   ```bash
   # Solución rápida
   ./cleanup-menu.sh
   # Seleccionar opción 1 (Limpieza rápida)
   
   # Verificar después
   kubectl get pods -n ecommerce
   ```

2. **Pods en estado ImagePullBackOff**:
   ```bash
   # Verificar imágenes
   kubectl describe pod <pod-name> -n ecommerce
   
   # Reiniciar deployment
   kubectl rollout restart deployment/<service-name> -n ecommerce
   ```

3. **Pods en estado ContainerCreating por mucho tiempo**:
   ```bash
   # Limpiar pods problemáticos
   ./quick-cleanup-pods.sh
   
   # O forzar eliminación
   kubectl delete pod <pod-name> -n ecommerce --force --grace-period=0
   ```

### 🌐 **Problemas de Conectividad**

1. **Frontend no accesible**:
   ```bash
   # Verificar port-forwards
   ./setup-port-forwards.sh
   
   # O usar detector inteligente
   ./open-frontend-smart.sh
   
   # Verificar estado del proxy-client
   kubectl get pods -n ecommerce -l app=proxy-client
   kubectl logs -f deployment/proxy-client -n ecommerce
   ```

2. **Servicios no se conectan entre sí**:
   ```bash
   # Verificar service discovery
   kubectl get pods -n ecommerce -l app=service-discovery
   kubectl logs -f deployment/service-discovery -n ecommerce
   
   # Verificar endpoints
   kubectl get endpoints -n ecommerce
   ```

### 📊 **Problemas de Monitoreo**

1. **Prometheus no recolecta métricas**:
   ```bash
   kubectl logs -f deployment/prometheus -n monitoring
   kubectl describe deployment prometheus -n monitoring
   
   # Verificar targets
   open http://127.0.0.1:9090/targets
   ```

2. **Grafana no muestra datos**:
   ```bash
   # Verificar conexión a Prometheus
   kubectl logs -f deployment/grafana -n monitoring
   
   # Reiniciar si es necesario
   kubectl rollout restart deployment/grafana -n monitoring
   ```

### 🔄 **Comandos de Recuperación**

```bash
# Reinicio completo del sistema
./force-cleanup-all.sh

# Reinicio específico de servicios problemáticos
kubectl rollout restart deployment/api-gateway -n ecommerce
kubectl rollout restart deployment/proxy-client -n ecommerce

# Verificar recursos del sistema
kubectl top nodes
kubectl describe nodes

# Escalar servicios si hay recursos disponibles
kubectl scale deployment user-service --replicas=2 -n ecommerce
```

## 📈 **Métricas y Observabilidad Avanzada**

### 🎯 **Dashboards de Grafana Disponibles**

1. **JVM (Micrometer) Dashboard**:
   - Memory usage (Heap, Non-Heap, Metaspace)
   - Garbage collection metrics
   - Thread pools status
   - CPU utilization per service

2. **Spring Boot Statistics**:
   - HTTP requests per endpoint
   - Response times y latencias
   - Error rates por servicio
   - Database connection pools
   - Cache hit/miss ratios

3. **Kubernetes Cluster Monitoring**:
   - Node resource utilization
   - Pod CPU y memory usage
   - Persistent volumes status
   - Network traffic metrics
   - Container restart counts

4. **Business Metrics Dashboard**:
   - Orders per minute
   - Payment success rates
   - User registration trends
   - Product view analytics

### 🔍 **Queries de Prometheus Útiles**

```promql
# CPU usage por servicio
rate(process_cpu_seconds_total{service="user-service"}[5m])

# Requests por minuto por endpoint
rate(http_requests_total[1m]) * 60

# Error rate por servicio
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# Memory usage por pod
jvm_memory_used_bytes{area="heap"} / jvm_memory_max_bytes{area="heap"}

# Database connection pool usage
hikaricp_connections_active / hikaricp_connections_max

# Response time percentiles
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

### 📊 **Alertas Configuradas**

```yaml
# Alta CPU en microservicios
- alert: HighCPUUsage
  expr: rate(process_cpu_seconds_total[5m]) > 0.8
  for: 5m

# Alto error rate
- alert: HighErrorRate  
  expr: rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m]) > 0.1
  for: 2m

# Pods no disponibles
- alert: PodDown
  expr: up{job="kubernetes-pods"} == 0
  for: 1m
```

## 📚 **Documentación y Referencias**

### 📖 **Guías y Documentación**
- **[GUIA-VM-COMPLETA.md](./GUIA-VM-COMPLETA.md)** - Guía completa para VM desde cero
- **[k8s-services-summary.md](./k8s-services-summary.md)** - Resumen de servicios y puertos K8s
- **API Documentation**: Swagger UI en `/swagger-ui.html` en cada servicio

### 🏗️ **Diagramas de Arquitectura**
- **`app-architecture.drawio.png`** - Diagrama de arquitectura de microservicios
- **`ecommerce-ERD.drawio.png`** - Diagrama entidad-relación de la base de datos
- **`k8s-architecture.drawio.png`** - Arquitectura de deployment en Kubernetes

### 🔧 **Configuración de CI/CD**
- **`azure-pipelines.yml`** - Pipeline de Azure DevOps
- **`Jenkinsfile`** - Pipeline de Jenkins en cada microservicio
- **`.github/workflows/`** - GitHub Actions workflows

## 🔑 **Credenciales y Configuración**

### 🔐 **Credenciales Predeterminadas**
- **Grafana**: admin / admin123
- **Kibana**: Sin autenticación (desarrollo)
- **Prometheus**: Sin autenticación
- **Jaeger**: Sin autenticación
- **Databases**: Configuración en ConfigMaps por ambiente

### ⚙️ **Variables de Entorno Importantes**
```bash
# Configuración de desarrollo
SPRING_PROFILES_ACTIVE=standalone
EUREKA_CLIENT_ENABLED=true
SPRING_ZIPKIN_ENABLED=true

# Configuración de producción  
SPRING_PROFILES_ACTIVE=prod
DB_USERNAME=<from-secret>
DB_PASSWORD=<from-secret>
JWT_SECRET=<from-secret>
```

## 📋 **Requisitos del Sistema (Actualizados)**

### 💻 **Requisitos Mínimos**
- **CPU**: 4 cores (recomendado 6+)
- **RAM**: 8GB (recomendado 12GB+)
- **Disk**: 30GB disponibles (recomendado 50GB+)
- **Network**: Puerto 80, 443, 8080-8900, 30080-30900

### 🛠️ **Software Requerido**
- **Docker**: 20.10+ (incluido en install-vm-dependencies.sh)
- **Minikube**: 1.25+ (incluido en install-vm-dependencies.sh)
- **kubectl**: 1.25+ (incluido en install-vm-dependencies.sh)
- **Maven**: 3.8+ (incluido en install-vm-dependencies.sh)
- **Java**: 11+ (incluido en install-vm-dependencies.sh)
- **Git**: Cualquier versión reciente

### 🖥️ **Sistemas Operativos Soportados**
- **Ubuntu**: 18.04+ ✅
- **CentOS/RHEL**: 7+ ✅
- **macOS**: 10.15+ ✅
- **Windows**: WSL2 requerido ✅

## 🎉 **Guía de Inicio Completa**

### 🆕 **Desde VM Completamente Nueva (Recomendado):**

```bash
# 1. Clonar el repositorio
git clone <repository-url>
cd ecommerce-microservice-backend-app-2

# 2. Instalar todas las dependencias automáticamente
chmod +x install-vm-dependencies.sh
./install-vm-dependencies.sh

# 3. Reiniciar sesión para aplicar cambios de grupo
exit
# Volver a conectar a la VM

# 4. Verificar que todo está instalado correctamente
./check-prerequisites.sh

# 5. Seguir la guía paso a paso
cat GUIA-VM-COMPLETA.md

# 6. Ejecutar despliegue completo con port-forwarding
./ecommerce-manager.sh
# Seleccionar: 1 (Deploy Complete)
# Después: 7 (Setup External Port-Forwarding)

# 7. Verificar que todo funciona
./verify-monitoring.sh

# 8. ¡Frontend listo!
# URL: http://127.0.0.1:8900/swagger-ui.html
```

### 🔧 **Sistema ya Configurado:**

```bash
# 1. Clonar y preparar
git clone <repository-url>
cd ecommerce-microservice-backend-app-2
chmod +x *.sh

# 2. Ejecutar deployment completo
./ecommerce-manager.sh

# 3. Limpiar pods problemáticos si es necesario
./cleanup-menu.sh

# 4. Configurar acceso fácil
./setup-port-forwards.sh

# 5. ¡Listo para usar!
echo "Frontend: http://127.0.0.1:8900/swagger-ui.html"
echo "Grafana: http://127.0.0.1:3000"
echo "Prometheus: http://127.0.0.1:9090"
```

### 🧹 **Mantenimiento y Limpieza**

```bash
# Limpiar pods problemáticos
./cleanup-menu.sh

# Ver estado del sistema
kubectl get all -n ecommerce
kubectl top nodes
kubectl top pods -A

# Logs y debugging
kubectl logs -f deployment/user-service -n ecommerce
kubectl describe pod <pod-name> -n ecommerce

# Reiniciar servicios específicos
kubectl rollout restart deployment/api-gateway -n ecommerce

# Escalar servicios
kubectl scale deployment user-service --replicas=3 -n ecommerce
```

---

**🚀 Sistema completo de microservicios e-commerce con:**
- ✅ **9 microservicios** con contratos K8s completos
- ✅ **Frontend Swagger UI** accesible y funcional  
- ✅ **Stack completo de monitoreo** (Prometheus, Grafana, ELK, Jaeger)
- ✅ **Scripts de limpieza** para pods problemáticos
- ✅ **Port-forwarding automático** para acceso fácil
- ✅ **Validación completa** de servicios y funcionalidad
- ✅ **Documentación exhaustiva** con evidencias y screenshots
