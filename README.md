# E-Commerce Microservices Platform 🛍️

Sistema completo de microservicios e-commerce con monitoreo, CI/CD, observabilidad y **interfaz web Swagger UI**.

## 🚀 Inicio Rápido

### 🆕 **Para VM desde Cero:**

```bash
# 1. Instalar todas las dependencias automáticamente
chmod +x install-vm-dependencies.sh
./install-vm-dependencies.sh

# 2. Verificar prerequisitos
chmod +x check-prerequisites.sh
./check-prerequisites.sh

# 3. Seguir la guía completa
cat GUIA-VM-COMPLETA.md
```

### 🔧 **Despliegue Estándar:**

```bash
# 1. Desplegar todo
chmod +x ecommerce-manager.sh
./ecommerce-manager.sh

# 2. Verificar que todo funciona
chmod +x verify-monitoring.sh
./verify-monitoring.sh

# 3. Acceder al frontend
chmod +x setup-port-forwards.sh
./setup-port-forwards.sh
```

**Acceder al frontend (soluciona problemas de conectividad):**

```bash
# Opción 1: Detector inteligente
chmod +x open-frontend-smart.sh
./open-frontend-smart.sh

# Opción 2: Configurar port-forwards
chmod +x setup-port-forwards.sh
./setup-port-forwards.sh
```

## 📚 **Documentación Completa**

### 📖 **Guías Principales**
- **[GUIA-VM-COMPLETA.md](./GUIA-VM-COMPLETA.md)** - 🆕 Guía paso a paso para desplegar desde cero en VM
- **[README.md](./README.md)** - Documentación principal (este archivo)

### 🛠️ **Scripts de Configuración**
- **`install-vm-dependencies.sh`** - 🆕 Instalador automático de todas las dependencias
- **`check-prerequisites.sh`** - 🆕 Verificador de prerequisitos del sistema

### 🔧 **Scripts de Despliegue**
- **`ecommerce-manager.sh`** - Despliegue completo automatizado
- **`verify-monitoring.sh`** - Verificación con timeouts optimizados
- **`DEPLOY_ALL_MICROSERVICES.sh`** - Solo microservicios

### 🌐 **Scripts de Acceso**
- **`setup-port-forwards.sh`** - 🆕 Port-forwards automáticos
- **`open-frontend-smart.sh`** - 🆕 Detector inteligente de URLs
- **`stop-port-forwards.sh`** - 🆕 Detener port-forwards

## 🌐 Acceso a la Aplicación

### 🖥️ Frontend/API UI

**🎯 URLs Principales (automáticamente detectadas):**
- **Swagger UI**: Detectado automáticamente (NodePort o Port-Forward)
- **API Gateway**: `http://MINIKUBE_IP:8080` o `http://127.0.0.1:8080`
- **Service Discovery**: `http://MINIKUBE_IP:8761` o `http://127.0.0.1:8761`

**📋 Port-Forward (Recomendado para acceso local):**
```bash
./setup-port-forwards.sh
# Frontend: http://127.0.0.1:8900/swagger-ui.html
```

**🌐 NodePort (Para acceso desde red):**
```bash
# Obtener IP: minikube ip
# Frontend: http://MINIKUBE_IP:8900/swagger-ui.html
```

### 📊 Monitoreo y Observabilidad
- **Grafana**: `http://MINIKUBE_IP:30030` o `http://127.0.0.1:3000` (admin/admin123)
- **Prometheus**: `http://MINIKUBE_IP:30090` o `http://127.0.0.1:9090`
- **Kibana**: `http://MINIKUBE_IP:30601` or `http://127.0.0.1:5601`
- **Jaeger**: `http://MINIKUBE_IP:30686` or `http://127.0.0.1:16686`
- **AlertManager**: `http://MINIKUBE_IP:30093`

> **Nota**: Los scripts detectan automáticamente la mejor forma de acceso

## 📦 Arquitectura del Sistema

### 🏗️ Microservicios
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Proxy Client  │───▶│   API Gateway   │───▶│ Service Discovery│
│   (Port 8900)   │    │   (Port 8080)   │    │   (Port 8761)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                   MICROSERVICIOS                                │
├─────────────┬─────────────┬─────────────┬─────────────────────┤
│User Service │Product Svc  │Order Service│Payment Service      │
│(Port 8700)  │(Port 8500)  │(Port 8300)  │(Port 8400)         │
├─────────────┼─────────────┼─────────────┼─────────────────────┤
│Shipping Svc │Favourite Svc│Config Server│Zipkin Tracing      │
│(Port 8600)  │(Port 8800)  │(Port 9296)  │(Port 9411)         │
└─────────────┴─────────────┴─────────────┴─────────────────────┘
```

### 🔍 Stack de Monitoreo
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Prometheus  │───▶│   Grafana   │    │    ELK     │    │   Jaeger    │
│  Métricas   │    │ Dashboards  │    │    Logs    │    │   Trazas    │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## 🛠️ Opciones de Despliegue

### 🖥️ Desarrollo Local (Docker Compose)

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

**URLs Locales:**
- Proxy Client (Frontend): http://localhost:8900/swagger-ui.html
- API Gateway: http://localhost:8080
- Service Discovery: http://localhost:8761
- Zipkin: http://localhost:9411

### ☁️ Despliegue en Nube (Kubernetes)

```bash
# Ejecutar pipeline completo
./ecommerce-manager.sh

# Solo microservicios
./DEPLOY_ALL_MICROSERVICES.sh

# Solo monitoreo
./deploy-monitoring.sh

# Verificar estado
./verify-monitoring.sh
```

## 🎯 Cómo Probar la Aplicación

### 1. 🚀 Acceder al Frontend

**Método Recomendado (Port-Forward):**
```bash
./setup-port-forwards.sh
# Abre automáticamente: http://127.0.0.1:8900/swagger-ui.html
```

**Método Alternativo (NodePort):**
```bash
# Obtener IP de Minikube
MINIKUBE_IP=$(minikube ip)
echo "Frontend: http://$MINIKUBE_IP:8900/swagger-ui.html"
```

**Detector Inteligente:**
```bash
# Detecta automáticamente la mejor opción
./open-frontend-smart.sh
```

### 2. 🧪 Testing de APIs

**Crear Usuario:**
```bash
curl -X POST "http://127.0.0.1:8900/api/users" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Juan",
    "lastName": "Pérez",
    "email": "juan@example.com",
    "phone": "+1234567890"
  }'
```

**Obtener Productos:**
```bash
curl "http://127.0.0.1:8900/api/products"
```

**Crear Orden:**
```bash
curl -X POST "http://127.0.0.1:8900/api/orders" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "items": [
      {"productId": 1, "quantity": 2}
    ]
  }'
```

### 3. 📊 Generar Datos de Prueba

```bash
# Ejecutar generador de tráfico
./generate-monitoring-data.sh

# Ejecutar tests de performance
./run-performance-tests-optimized.sh
```

## 🔧 Scripts Principales

| Script | Descripción | Tiempo Estimado |
|--------|-------------|-----------------|
| **🆕 `install-vm-dependencies.sh`** | **Instalador automático de dependencias** | **10-15 min** |
| **🆕 `check-prerequisites.sh`** | **Verificador de prerequisitos** | **30 seg** |
| `ecommerce-manager.sh` | Despliegue completo | 15-20 min |
| `verify-monitoring.sh` | Verificación con timeouts | 2-5 min |
| `setup-port-forwards.sh` | **🆕 Port-forwards automáticos** | 1-2 min |
| `open-frontend-smart.sh` | **🆕 Detector inteligente de URLs** | 30 seg |
| `stop-port-forwards.sh` | **🆕 Detener port-forwards** | 30 seg |
| `deploy-monitoring.sh` | Solo stack de monitoreo | 10-15 min |
| `DEPLOY_ALL_MICROSERVICES.sh` | Solo microservicios | 8-12 min |
| `generate-monitoring-data.sh` | Datos de prueba | 2-3 min |

## 🏥 Verificación de Salud

### ✅ Health Checks Automáticos
```bash
# Verificar estado completo
./verify-monitoring.sh

# Ver pods de microservicios
kubectl get pods -n ecommerce

# Ver pods de monitoreo
kubectl get pods -n monitoring

# Ver servicios
kubectl get svc -A
```

### 🔍 Endpoints de Salud
```bash
# Health checks individuales (con port-forward)
curl http://127.0.0.1:8900/actuator/health
curl http://127.0.0.1:8700/actuator/health  # User Service
curl http://127.0.0.1:8500/actuator/health  # Product Service
```

## 🚨 Solución de Problemas

### 🔧 Comandos de Diagnóstico
```bash
# Ver recursos del cluster
kubectl top nodes
kubectl top pods -A

# Ver eventos
kubectl get events -n ecommerce --sort-by=.metadata.creationTimestamp
kubectl get events -n monitoring --sort-by=.metadata.creationTimestamp

# Logs de servicios
kubectl logs -f deployment/user-service -n ecommerce
kubectl logs -f deployment/prometheus -n monitoring

# Reiniciar deployment
kubectl rollout restart deployment/user-service -n ecommerce
```

### ⚠️ Problemas Comunes

1. **Frontend no accesible**:
   ```bash
   # Usar port-forward en lugar de NodePort
   ./setup-port-forwards.sh
   # O verificar estado del proxy-client
   kubectl get pods -n ecommerce -l app=proxy-client
   ```

2. **Timeout en Prometheus**: 
   ```bash
   kubectl describe deployment prometheus -n monitoring
   kubectl logs -f deployment/prometheus -n monitoring
   ```

3. **Servicios no responden**:
   ```bash
   kubectl get endpoints -n ecommerce
   minikube service list
   # Usar port-forward como alternativa
   ./setup-port-forwards.sh
   ```

4. **Falta de recursos**:
   ```bash
   kubectl top nodes
   minikube config set memory 8192
   minikube config set cpus 4
   minikube delete && minikube start
   ```

## 📈 Métricas y Observabilidad

### 🎯 Dashboards de Grafana
- **Microservices Overview**: Métricas generales
- **JVM Metrics**: Memoria, GC, threads
- **HTTP Requests**: Latencia, throughput, errores
- **Database Metrics**: Conexiones, queries

### 🔍 Queries de Prometheus Útiles
```promql
# CPU usage por servicio
rate(process_cpu_seconds_total[5m])

# Requests por minuto
rate(http_requests_total[1m]) * 60

# Error rate
rate(http_requests_total{status=~"5.."}[5m]) / rate(http_requests_total[5m])

# Memory usage
jvm_memory_used_bytes / jvm_memory_max_bytes
```

## 📚 Documentación Adicional

- **APIs**: Swagger UI en cada servicio `/swagger-ui.html`
- **Arquitectura**: Diagramas en `app-architecture.drawio.png`
- **Base de Datos**: ERD en `ecommerce-ERD.drawio.png`
- **Pipeline**: Configuración en `azure-pipelines.yml`

## 🔑 Credenciales Predeterminadas

- **Grafana**: admin / admin123
- **Kibana**: Sin autenticación
- **Prometheus**: Sin autenticación
- **Jaeger**: Sin autenticación

## 📋 Requisitos del Sistema

### 💻 Mínimos
- **CPU**: 4 cores
- **RAM**: 8GB
- **Disk**: 20GB disponibles

### 🛠️ Software
- Docker 20.10+
- Minikube 1.25+
- kubectl 1.25+
- Maven 3.8+
- Java 11+

## 🎉 Para Empezar Ahora

### 🆕 **Desde VM Completamente Nueva:**

```bash
# 1. Clonar proyecto
git clone <repository>
cd ecommerce-microservice-backend-app-2

# 2. Instalar todas las dependencias automáticamente
chmod +x install-vm-dependencies.sh
./install-vm-dependencies.sh

# 3. Reiniciar sesión y verificar
./check-prerequisites.sh

# 4. Seguir guía paso a paso
cat GUIA-VM-COMPLETA.md

# 5. Ejecutar despliegue
./ecommerce-manager.sh

# 6. Configurar acceso fácil
./setup-port-forwards.sh
```

### 🔧 **Sistema ya Configurado:**

```bash
# 1. Clonar y configurar
git clone <repository>
cd ecommerce-microservice-backend-app-2

# 2. Ejecutar todo
chmod +x ecommerce-manager.sh verify-monitoring.sh
./ecommerce-manager.sh

# 3. Verificar (esperar 2 min max por servicio)
./verify-monitoring.sh

# 4. Configurar acceso fácil al frontend
chmod +x setup-port-forwards.sh
./setup-port-forwards.sh

# 5. ¡Frontend listo!
# URL: http://127.0.0.1:8900/swagger-ui.html
```

## 🔄 Gestión de Port-Forwards

```bash
# Configurar todos los port-forwards
./setup-port-forwards.sh

# Verificar estado y abrir frontend
./open-frontend-smart.sh

# Detener todos los port-forwards
./stop-port-forwards.sh

# Ver port-forwards activos
ps aux | grep "kubectl.*port-forward"
```

---

**🚀 Sistema completo de microservicios con interfaz web, monitoreo avanzado y CI/CD automatizado.**
