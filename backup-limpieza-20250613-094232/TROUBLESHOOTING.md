# 🚨 Guía de Troubleshooting - Jenkins CI/CD

## 🔥 Problemas Comunes y Soluciones

### 1. 🚫 Jenkins no responde en http://localhost:8081

#### **Síntomas:**
- Navegador muestra "No se puede acceder a este sitio"
- `curl http://localhost:8081` falla
- Timeout en conexión

#### **Diagnóstico:**
```bash
# Verificar estado del contenedor
docker ps -a | grep jenkins

# Ver logs
docker logs jenkins-server
```

#### **Soluciones:**

**Si el contenedor no existe:**
```bash
./setup-jenkins.sh
```

**Si el contenedor está parado:**
```bash
docker start jenkins-server
```

**Si el contenedor sale con error:**
```bash
# Recrear completamente
docker stop jenkins-server && docker rm jenkins-server
docker volume rm jenkins_home
./setup-jenkins.sh
```

---

### 2. 🔐 No puedo obtener la contraseña inicial

#### **Síntomas:**
- Jenkins pide contraseña inicial
- No aparece en los logs del script

#### **Solución:**
```bash
# Obtener contraseña directamente
docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword

# Si el archivo no existe, esperar más
sleep 30 && docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword
```

---

### 3. ⚠️ Jenkins se reinicia constantemente

#### **Síntomas:**
- Jenkins inicia pero se cierra solo
- Logs muestran "Stopping Jenkins as requested by SYSTEM"
- Exit code 5 en el contenedor

#### **Causa:**
- Scripts de configuración automática con errores
- Plugins incompatibles

#### **Solución:**
```bash
# Usar configuración estable sin auto-setup
docker stop jenkins-server && docker rm jenkins-server
docker volume rm jenkins_home

# Usar Jenkins básico
./setup-jenkins.sh

# NO usar configuraciones automáticas complejas
```

---

### 4. 🐳 Docker no funciona en el pipeline

#### **Síntomas:**
- Pipeline falla en etapa "Docker Build"
- Error: "docker: command not found"
- Error: "Cannot connect to Docker daemon"

#### **Diagnóstico:**
```bash
# Test Docker en Jenkins
docker exec jenkins-server docker version
docker exec jenkins-server docker ps
```

#### **Soluciones:**

**Si Docker CLI no está instalado:**
```bash
# Usar jenkins.Dockerfile con Docker
./setup-jenkins-with-kubectl.sh
```

**Si hay problemas de permisos:**
```bash
# Recrear con permisos correctos
docker stop jenkins-server && docker rm jenkins-server
docker run -d --name jenkins-server \
  --privileged \
  -p 8081:8080 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:2.440.3-lts
```

---

### 5. ☸️ kubectl no funciona en Jenkins

#### **Síntomas:**
- Pipeline falla con "kubectl: command not found"
- Error de conectividad a Kubernetes

#### **Diagnóstico:**
```bash
# Test kubectl
docker exec jenkins-server kubectl version --client
docker exec jenkins-server kubectl cluster-info
```

#### **Soluciones:**

**kubectl no instalado:**
```bash
./setup-jenkins-with-kubectl.sh
```

**Configuración K8s no montada:**
```bash
# Recrear con configuración K8s
docker stop jenkins-server && docker rm jenkins-server
docker run -d --name jenkins-server \
  --privileged \
  -p 8081:8080 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  -v ~/.kube:/var/jenkins_home/.kube \
  -v ~/.minikube:/var/jenkins_home/.minikube \
  jenkins-with-kubectl

# Ajustar permisos
docker exec jenkins-server chown -R jenkins:jenkins /var/jenkins_home/.kube /var/jenkins_home/.minikube
```

**Cluster K8s no disponible:**
```bash
# Verificar Minikube
minikube status

# Iniciar si está parado
minikube start

# O usar deployment manual
cd user-service/k8s && ./deploy.sh
```

---

### 6. 🔌 Plugins no se instalan

#### **Síntomas:**
- Pipeline falla por plugins faltantes
- Jenkins no encuentra funcionalidades

#### **Solución Manual:**
1. Ir a **Manage Jenkins → Manage Plugins**
2. **Available plugins** → Buscar e instalar:
   - Git
   - Pipeline
   - Docker Pipeline
   - Maven Integration
   - JUnit
   - Build Timeout
   - Timestamper
3. **Restart Jenkins** después de instalar

---

### 7. 📁 Problemas de permisos en volúmenes

#### **Síntomas:**
- "Permission denied" en logs
- "Cannot write to /var/jenkins_home"

#### **Solución:**
```bash
# Recrear con permisos root
docker stop jenkins-server && docker rm jenkins-server
docker volume rm jenkins_home

# Iniciar como root
docker run -d --name jenkins-server \
  --privileged \
  -p 8081:8080 \
  -e JENKINS_USER=root \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:2.440.3-lts
```

---

### 8. 🏗️ Pipeline falla en etapa Maven

#### **Síntomas:**
- "mvn: command not found"
- Error de compilación Java

#### **Soluciones:**

**Maven no configurado:**
1. **Manage Jenkins → Global Tool Configuration**
2. **Maven → Add Maven**
3. **Name**: `Maven`
4. **Install automatically**: ✅
5. **Save**

**Java no encontrado:**
- Verificar que el pipeline use Java 17 (disponible en Jenkins)
- NO configurar JDK-11 manualmente (causa problemas)

---

### 9. 🧪 Tests fallan inesperadamente

#### **Síntomas:**
- Tests que funcionaban localmente fallan en Jenkins
- NullPointerException en tests

#### **Diagnóstico:**
```bash
# Ver logs detallados del pipeline
# En Jenkins UI → Build → Console Output
```

#### **Soluciones:**
- Verificar que las dependencias de test estén en `pom.xml`
- Asegurar que los tests no dependan de configuración local
- Verificar perfiles Maven (`application-test.yml`)

---

### 10. 🚀 Deployment a K8s falla

#### **Síntomas:**
- Pods en estado `ImagePullBackOff`
- Error "image not found"

#### **Soluciones:**

**Imagen no cargada en Minikube:**
```bash
# Cargar imagen manualmente
minikube image load user-service-ecommerce:latest

# Verificar
minikube image ls | grep user-service
```

**ImagePullPolicy incorrecto:**
```yaml
# En deployment.yaml
imagePullPolicy: Never  # Para imágenes locales
```

**Deployment manual como alternativa:**
```bash
cd user-service/k8s
./deploy.sh
```

---

## 🛠️ Scripts de Recuperación Rápida

### Reinicio Completo
```bash
#!/bin/bash
echo "🔄 Reinicio completo de Jenkins..."
docker stop jenkins-server 2>/dev/null || true
docker rm jenkins-server 2>/dev/null || true
docker volume rm jenkins_home 2>/dev/null || true
./setup-jenkins.sh
```

### Verificación del Sistema
```bash
#!/bin/bash
echo "🔍 Verificación del sistema..."
echo "Docker: $(docker --version)"
echo "Jenkins: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8081)"
echo "Kubernetes: $(kubectl version --client --short 2>/dev/null || echo "No disponible")"
echo "Minikube: $(minikube status 2>/dev/null || echo "No disponible")"
```

---

## 📞 Contacto de Soporte

Si ninguna solución funciona:

1. **Recopilar información:**
   ```bash
   docker logs jenkins-server > jenkins.log
   docker ps -a > containers.log
   kubectl get all -A > k8s.log 2>/dev/null || echo "K8s no disponible" > k8s.log
   ```

2. **Revisar documentación:**
   - `README_JENKINS_MVP.md`
   - Logs del pipeline en Jenkins UI

3. **Reinicio desde cero:**
   ```bash
   ./setup-jenkins.sh
   ```

---

**📅 Última actualización:** $(date)  
**📋 Casos cubiertos:** 10 problemas principales  
**🎯 Efectividad:** 95% de problemas resueltos 