# 🚀 Jenkins CI/CD - Configuración Estable y Funcional

## ✅ Estado Actual - FUNCIONANDO

- **🌐 Jenkins URL**: http://localhost:8081
- **🐳 Docker**: ✅ Integrado y funcionando
- **🔧 Maven**: ✅ Disponible
- **☸️ Kubernetes**: ✅ Opcional con kubectl
- **🔌 Plugins**: Instalación manual durante setup

## 🎯 Dos Opciones de Configuración

### 🟢 Opción 1: Jenkins Básico (Recomendado)
**Para CI/CD con deployment manual a Kubernetes**

```bash
./setup-jenkins.sh
```

**Características:**
- ✅ Jenkins estable sin configuraciones automáticas
- ✅ Docker CLI integrado
- ✅ Setup wizard manual (más confiable)
- ✅ Perfecto para pipelines CI (Build, Test, Docker)
- ⚠️ Deployment a K8s manual (común en empresas)

### 🔵 Opción 2: Jenkins + kubectl (Avanzado)
**Para CI/CD con deployment automático a Kubernetes**

```bash
./setup-jenkins-with-kubectl.sh
```

**Características:**
- ✅ Todo lo de la Opción 1
- ✅ kubectl instalado en Jenkins
- ✅ Acceso a cluster Minikube
- ✅ Deployment automático desde pipeline
- ⚠️ Más complejo, puede requerir ajustes

## 🚀 Cómo Usar

### 1. **Configuración Inicial**
```bash
# Opción básica (recomendada)
./setup-jenkins.sh

# O con kubectl (avanzada)
./setup-jenkins-with-kubectl.sh
```

### 2. **Setup de Jenkins**
1. Abrir http://localhost:8081
2. Usar la contraseña que muestra el script
3. **Instalar plugins sugeridos**
4. Crear usuario admin
5. Configurar URL

### 3. **Plugins Esenciales**
Los siguientes plugins son necesarios para el pipeline:
- **Git** - Control de versiones
- **Pipeline** - Workflow de CI/CD
- **Docker Pipeline** - Builds de Docker
- **Maven Integration** - Builds de Java
- **JUnit** - Reportes de tests
- **Build Timeout** - Timeouts
- **Timestamper** - Timestamps en logs

### 4. **Crear Pipeline Job**
1. **New Item** → `user-service-pipeline` → **Pipeline**
2. **Pipeline → Definition**: Pipeline script from SCM
3. **SCM**: Git
4. **Repository URL**: `https://github.com/Svak-in-ML/ecommerce-microservice-backend-app-2.git`
5. **Script Path**: `user-service/Jenkinsfile`
6. **Save**

### 5. **Ejecutar Pipeline**
- Hacer clic en **"Build Now"**
- Ver progreso en **Build History**

## 📋 Pipeline Completo

### ✅ Etapas que Funcionan:
1. **Verify Java Version** - Diagnóstico del entorno
2. **Checkout** - Descarga código del repositorio
3. **Build** - Compilación con Maven
4. **Test** - Tests unitarios (6/6 pasando) + JaCoCo
5. **Package** - Creación de JAR
6. **Docker Build** - Construcción de imagen Docker
7. **Deploy to Kubernetes** - Deployment a K8s (según opción)
8. **Archive Artifacts** - Archivado de artefactos

### 🎯 Resultados Esperados:
- ✅ **Build**: Compilación exitosa
- ✅ **Tests**: 6/6 tests pasando
- ✅ **Docker**: Imagen `user-service-ecommerce:X` creada
- ✅ **Artifacts**: JAR archivado
- ✅ **K8s**: Deployment (manual u automático)

## ☸️ Deployment a Kubernetes

### Con Opción 1 (Manual):
```bash
# Después del pipeline Jenkins
cd user-service/k8s
minikube image load user-service-ecommerce:latest
./deploy.sh
```

### Con Opción 2 (Automático):
- El pipeline incluye etapa de deployment automático
- Maneja graciosamente la falta de cluster K8s
- Marca build como UNSTABLE si K8s no disponible

## 🔧 Comandos Útiles

```bash
# Estado de Jenkins
docker ps | grep jenkins

# Logs de Jenkins
docker logs jenkins-server

# Obtener contraseña inicial
docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword

# Reiniciar Jenkins
docker restart jenkins-server

# Parar Jenkins
docker stop jenkins-server

# Test kubectl (solo Opción 2)
docker exec jenkins-server kubectl version --client

# Estado de Kubernetes
kubectl get pods -n ecommerce
kubectl get all -n ecommerce
```

## 🏆 Lecciones Aprendidas

### ✅ **Lo que Funciona:**
1. **Jenkins estable** sin configuraciones automáticas complejas
2. **Setup wizard manual** es más confiable que scripts automáticos
3. **Docker CLI** integrado funciona perfectamente
4. **Separación CI/CD** es una práctica real y común
5. **Volúmenes Docker** simples son más estables

### ❌ **Lo que Causa Problemas:**
1. **Configuraciones automáticas** con Groovy scripts
2. **Permisos complejos** en volúmenes
3. **Auto-restart** de Jenkins durante setup
4. **Montaje complejo** de certificados K8s
5. **Scripts init.groovy.d** con dependencias

### 🎯 **Mejores Prácticas:**
1. **Usar setup manual** para configuración inicial
2. **Separar CI de CD** cuando sea apropiado
3. **Dockerfiles simples** sin configuraciones complejas
4. **Scripts de troubleshooting** siempre disponibles
5. **Documentación clara** de los pasos manuales

## 🚨 Troubleshooting

### Jenkins no responde:
```bash
docker logs jenkins-server
docker restart jenkins-server
```

### Problemas de permisos:
```bash
# Recrear con permisos correctos
docker stop jenkins-server && docker rm jenkins-server
docker volume rm jenkins_home
./setup-jenkins.sh
```

### kubectl no funciona:
```bash
# Usar setup con kubectl
./setup-jenkins-with-kubectl.sh
# O hacer deployment manual
cd user-service/k8s && ./deploy.sh
```

### Pipeline falla en Docker:
```bash
# Verificar Docker en Jenkins
docker exec jenkins-server docker ps
docker exec jenkins-server docker version
```

## 🎉 ¡Configuración Lista!

Tu Jenkins MVP está configurado y listo para:

- **✅ CI completo**: Build, Test, Package, Docker
- **✅ Deployment**: Manual confiable o automático opcional
- **✅ Escalabilidad**: Fácil expansión a más microservicios
- **✅ Estabilidad**: Sin configuraciones frágiles
- **✅ Troubleshooting**: Scripts y comandos disponibles

---

**🏁 Fecha**: $(date)  
**📊 Estado**: ✅ FUNCIONANDO Y DOCUMENTADO  
**🔧 Configuración**: ESTABLE Y REPRODUCIBLE 