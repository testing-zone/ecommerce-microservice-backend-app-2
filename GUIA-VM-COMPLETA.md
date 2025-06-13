# 🚀 Guía Completa: E-Commerce desde Cero en VM

**Guía paso a paso para desplegar el sistema completo de microservicios e-commerce con monitoreo en una máquina virtual.**

---

## 📋 **PASO 1: Preparar la VM**

### 💻 **Requisitos Mínimos**
```bash
# Recursos recomendados
CPU: 4 cores (mínimo 2)
RAM: 8GB (mínimo 6GB)
Disk: 30GB libres
OS: Ubuntu 20.04+ / CentOS 8+ / MacOS / Windows con WSL2
```

### 🔧 **Configurar la VM**
```bash
# 1. Actualizar sistema
sudo apt update && sudo apt upgrade -y  # Ubuntu/Debian
# sudo yum update -y                    # CentOS/RHEL

# 2. Instalar herramientas básicas
sudo apt install -y curl wget git unzip vim htop
```

---

## 📦 **PASO 2: Instalar Docker**

```bash
# 1. Remover versiones antiguas
sudo apt remove docker docker-engine docker.io containerd runc

# 2. Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 3. Agregar usuario al grupo docker
sudo usermod -aG docker $USER

# 4. Reiniciar sesión o ejecutar
newgrp docker

# 5. Verificar instalación
docker --version
docker run hello-world
```

---

## ☸️ **PASO 3: Instalar Minikube y kubectl**

### 🔹 **Instalar kubectl**
```bash
# 1. Descargar kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# 2. Instalar kubectl
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# 3. Verificar
kubectl version --client
```

### 🔹 **Instalar Minikube**
```bash
# 1. Descargar Minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64

# 2. Instalar
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# 3. Verificar
minikube version
```

### 🔹 **Configurar Minikube**
```bash
# 1. Configurar recursos (IMPORTANTE)
minikube config set memory 8192    # 8GB RAM
minikube config set cpus 4         # 4 CPU cores
minikube config set disk-size 30g  # 30GB disk

# 2. Iniciar Minikube
minikube start --driver=docker

# 3. Verificar estado
minikube status
kubectl cluster-info
```

---

## ☕ **PASO 4: Instalar Java y Maven**

```bash
# 1. Instalar Java 11
sudo apt install -y openjdk-11-jdk

# 2. Configurar JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> ~/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
source ~/.bashrc

# 3. Verificar Java
java -version
javac -version

# 4. Instalar Maven
sudo apt install -y maven

# 5. Verificar Maven
mvn -version
```

---

## 📥 **PASO 5: Clonar y Configurar el Proyecto**

```bash
# 1. Clonar el repositorio (reemplaza con tu URL)
cd ~
git clone https://github.com/tu-usuario/ecommerce-microservice-backend-app-2.git
cd ecommerce-microservice-backend-app-2

# 2. Dar permisos a scripts
chmod +x *.sh

# 3. Verificar estructura
ls -la
```

---

## 🚀 **PASO 6: Ejecutar el Despliegue Completo**

### 🎯 **Opción A: Despliegue Automático (Recomendado)**

```bash
# 1. Ejecutar pipeline maestro
./ecommerce-manager.sh

# Esto incluye:
# - Despliegue de microservicios
# - Stack de monitoreo completo
# - Configuración de networking
# - Health checks automáticos
```

**⏰ Tiempo estimado: 15-20 minutos**

### 🎯 **Opción B: Despliegue Manual (Paso a Paso)**

```bash
# 1. Solo microservicios
./DEPLOY_ALL_MICROSERVICES.sh

# 2. Solo monitoreo
./deploy-monitoring.sh

# 3. Verificar todo
./verify-monitoring.sh
```

---

## 🔍 **PASO 7: Verificar el Despliegue**

```bash
# 1. Verificar con timeouts optimizados
./verify-monitoring.sh

# 2. Ver estado de pods
kubectl get pods -n ecommerce
kubectl get pods -n monitoring

# 3. Ver servicios
kubectl get svc -A

# 4. Ver IP de Minikube
minikube ip
```

---

## 🌐 **PASO 8: Acceder al Frontend**

### 🎯 **Método 1: Port-Forwards (Recomendado)**

```bash
# 1. Configurar port-forwards automáticamente
./setup-port-forwards.sh

# 2. Acceder al frontend
# Se abre automáticamente: http://127.0.0.1:8900/swagger-ui.html
```

### 🎯 **Método 2: NodePorts (Alternativo)**

```bash
# 1. Obtener IP de Minikube
MINIKUBE_IP=$(minikube ip)
echo "Frontend: http://$MINIKUBE_IP:8900/swagger-ui.html"

# 2. Abrir en navegador (desde la VM)
firefox "http://$MINIKUBE_IP:8900/swagger-ui.html"
```

### 🎯 **Método 3: Detector Inteligente**

```bash
# Detecta automáticamente la mejor opción
./open-frontend-smart.sh
```

---

## 🎮 **PASO 9: Probar la Aplicación**

### 🔹 **Acceder a Interfaces Web**

```bash
# Con port-forwards activos:
echo "🎯 Frontend:    http://127.0.0.1:8900/swagger-ui.html"
echo "📊 Grafana:     http://127.0.0.1:3000 (admin/admin123)"
echo "📈 Prometheus:  http://127.0.0.1:9090"
echo "🚪 API Gateway: http://127.0.0.1:8080"
echo "🔍 Discovery:   http://127.0.0.1:8761"
```

### 🔹 **Probar APIs desde Terminal**

```bash
# 1. Crear usuario
curl -X POST "http://127.0.0.1:8900/api/users" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Juan",
    "lastName": "Pérez", 
    "email": "juan@test.com",
    "phone": "+1234567890"
  }'

# 2. Listar usuarios
curl "http://127.0.0.1:8900/api/users"

# 3. Listar productos
curl "http://127.0.0.1:8900/api/products"

# 4. Crear producto
curl -X POST "http://127.0.0.1:8900/api/products" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Laptop Gaming",
    "description": "Laptop para gaming",
    "price": 999.99,
    "categoryId": 1
  }'
```

### 🔹 **Generar Datos de Prueba**

```bash
# 1. Generar tráfico para monitoreo
./generate-monitoring-data.sh

# 2. Ejecutar tests de performance
./run-performance-tests-optimized.sh
```

---

## 📊 **PASO 10: Verificar Monitoreo**

### 🎯 **Acceder a Dashboards**

1. **Grafana**: http://127.0.0.1:3000
   - Usuario: `admin`
   - Contraseña: `admin123`
   - Ver dashboards de microservicios

2. **Prometheus**: http://127.0.0.1:9090
   - Verificar targets activos
   - Ejecutar queries de métricas

3. **Kibana**: http://127.0.0.1:5601
   - Ver logs de microservicios
   - Configurar índices

4. **Jaeger**: http://127.0.0.1:16686
   - Ver trazas distribuidas
   - Analizar latencias

---

## 🚨 **PASO 11: Solución de Problemas Comunes**

### ❌ **Problema: Pods no inician**

```bash
# 1. Ver estado detallado
kubectl describe pod NOMBRE_POD -n NAMESPACE

# 2. Ver logs
kubectl logs -f deployment/NOMBRE_DEPLOYMENT -n NAMESPACE

# 3. Verificar recursos
kubectl top nodes
kubectl top pods -A
```

### ❌ **Problema: Frontend no accesible**

```bash
# 1. Verificar proxy-client
kubectl get pods -n ecommerce -l app=proxy-client

# 2. Usar port-forward
kubectl port-forward svc/proxy-client 8900:8900 -n ecommerce &

# 3. O usar script automático
./setup-port-forwards.sh
```

### ❌ **Problema: Minikube lento**

```bash
# 1. Aumentar recursos
minikube stop
minikube config set memory 10240  # 10GB
minikube config set cpus 6        # 6 cores
minikube start

# 2. Limpiar imágenes no usadas
docker system prune -f
```

### ❌ **Problema: Servicios no responden**

```bash
# 1. Verificar endpoints
kubectl get endpoints -n ecommerce
kubectl get endpoints -n monitoring

# 2. Reiniciar deployment
kubectl rollout restart deployment/NOMBRE -n NAMESPACE

# 3. Verificar conectividad
./verify-monitoring.sh
```

---

## 🛠️ **PASO 12: Comandos Útiles para Gestión**

### 🔹 **Port-Forwards**

```bash
# Configurar todos
./setup-port-forwards.sh

# Ver activos
ps aux | grep "kubectl.*port-forward"

# Detener todos
./stop-port-forwards.sh
```

### 🔹 **Logs y Debugging**

```bash
# Logs de un servicio específico
kubectl logs -f deployment/user-service -n ecommerce

# Logs de monitoreo
kubectl logs -f deployment/prometheus -n monitoring

# Ver eventos del cluster
kubectl get events -A --sort-by=.metadata.creationTimestamp
```

### 🔹 **Escalado**

```bash
# Escalar un deployment
kubectl scale deployment user-service --replicas=3 -n ecommerce

# Ver estado de escalado
kubectl get hpa -A
```

### 🔹 **Limpieza**

```bash
# Detener port-forwards
./stop-port-forwards.sh

# Limpiar deployments
kubectl delete namespace ecommerce
kubectl delete namespace monitoring

# Reiniciar Minikube
minikube stop
minikube start
```

---

## 🎉 **PASO 13: Verificación Final**

### ✅ **Checklist de Verificación**

```bash
# 1. ✅ Todos los pods ejecutándose
kubectl get pods -A | grep -v Running | grep -v Completed

# 2. ✅ Frontend accesible
curl -s http://127.0.0.1:8900/swagger-ui.html | grep -q "Swagger"

# 3. ✅ APIs funcionando
curl -s http://127.0.0.1:8900/api/users | jq .

# 4. ✅ Grafana accesible
curl -s http://127.0.0.1:3000/api/health | jq .

# 5. ✅ Prometheus recolectando métricas
curl -s http://127.0.0.1:9090/api/v1/targets | jq .
```

### 🎯 **URLs Finales**

```bash
echo "🎉 SISTEMA DESPLEGADO EXITOSAMENTE!"
echo ""
echo "🌐 ACCESO A SERVICIOS:"
echo "├─ 🎯 Frontend:     http://127.0.0.1:8900/swagger-ui.html"
echo "├─ 📊 Grafana:      http://127.0.0.1:3000 (admin/admin123)"
echo "├─ 📈 Prometheus:   http://127.0.0.1:9090"
echo "├─ 🚪 API Gateway:  http://127.0.0.1:8080"
echo "├─ 🔍 Discovery:    http://127.0.0.1:8761"
echo "├─ 📋 Kibana:       http://127.0.0.1:5601"
echo "└─ 🔍 Jaeger:       http://127.0.0.1:16686"
```

---

## 📚 **Recursos Adicionales**

### 🔍 **Documentación**
- **APIs**: Swagger UI en http://127.0.0.1:8900/swagger-ui.html
- **Arquitectura**: Ver `app-architecture.drawio.png`
- **Base de Datos**: Ver `ecommerce-ERD.drawio.png`

### 🛠️ **Scripts Disponibles**
- `ecommerce-manager.sh` - Despliegue completo
- `verify-monitoring.sh` - Verificación con timeouts
- `setup-port-forwards.sh` - Port-forwards automáticos
- `open-frontend-smart.sh` - Detector inteligente
- `stop-port-forwards.sh` - Detener port-forwards
- `generate-monitoring-data.sh` - Datos de prueba

### 📞 **Soporte**
```bash
# Ver logs del sistema
tail -f ecommerce-manager.log

# Estado general
./verify-monitoring.sh

# Troubleshooting específico
kubectl describe pod NOMBRE_POD -n NAMESPACE
```

---

**🚀 ¡Felicidades! Tienes un sistema completo de microservicios e-commerce con monitoreo avanzado ejecutándose en tu VM.** 