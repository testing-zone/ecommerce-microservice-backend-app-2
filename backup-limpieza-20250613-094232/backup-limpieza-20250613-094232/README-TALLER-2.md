# 🚀 TALLER 2 - PRUEBAS Y LANZAMIENTO
## E-commerce Microservices Backend

---

## 📋 **QUÉ ES ESTO?**

Este es el proyecto completo del **Taller 2** con:
- ✅ **6 microservicios** funcionando en Kubernetes
- ✅ **Jenkins** con pipelines automatizados
- ✅ **Pruebas de performance** reales con Locust
- ✅ **Evidencias verificables** de todas las pruebas

---

## 🎯 **PARA USUARIOS NUEVOS - SETUP COMPLETO**

### **Paso 1: Setup inicial (todo desde cero)**
```bash
chmod +x 1-setup-completo.sh
./1-setup-completo.sh
```
**Esto configura:** Docker, Kubernetes, Jenkins, y todos los microservicios

### **Paso 2: Verificar que todo funciona**
```bash
chmod +x 2-verificar-servicios.sh  
./2-verificar-servicios.sh
```

### **Paso 3: Generar evidencias de pruebas reales**
```bash
chmod +x 3-pruebas-performance.sh
./3-pruebas-performance.sh
```

### **Paso 4: Configurar Jenkins (opcional)**
```bash
chmod +x 4-configurar-jenkins.sh
./4-configurar-jenkins.sh
```

---

## 🔑 **CREDENCIALES**

### **Jenkins:**
- **URL:** http://localhost:8081
- **Usuario:** admin  
- **Contraseña:** `8e3f3456b8414d72b35a617c31f93dfa`

---

## 📊 **EVIDENCIAS REALES GENERADAS**

### **Después de ejecutar los scripts tendrás:**

1. **📁 performance-reports/** - Reportes HTML de Locust con métricas reales
2. **🧪 Jenkins builds** - Logs verificables de pipelines
3. **☸️ kubectl outputs** - Estado real de pods y servicios
4. **📈 CSV files** - Datos de performance exportables

---

## 🔍 **COMANDOS ÚTILES**

```bash
# Ver estado de todos los pods
kubectl get pods -n ecommerce

# Ver logs de un servicio
kubectl logs -f deployment/user-service -n ecommerce

# Acceder a Jenkins
open http://localhost:8081

# Ver reportes de performance
open performance-reports/
```

---

## 🏗️ **ARQUITECTURA**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   user-service  │    │ product-service │    │  order-service  │
│     :8081       │    │     :8082       │    │     :8083       │
└─────────────────┘    └─────────────────┘    └─────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│payment-service  │    │shipping-service │    │favourite-service│
│     :8084       │    │     :8085       │    │     :8086       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Todo corriendo en Kubernetes namespace: `ecommerce`**

---

## ✅ **CUMPLIMIENTO TALLER 2**

- ✅ **5 Pruebas Unitarias:** 15+ implementadas  
- ✅ **5 Pruebas Integración:** 8+ implementadas
- ✅ **5 Pruebas E2E:** 5+ implementadas
- ✅ **Pruebas Performance:** Locust con reportes HTML
- ✅ **Jenkins Pipelines:** 3 pipelines configurados
- ✅ **Kubernetes:** 6 microservicios desplegados
- ✅ **Documentación:** Esta guía + reportes

---

## 🎉 **RESULTADO FINAL**

**📋 Estado:** ✅ **TALLER 2 COMPLETADO AL 100%**

**🏆 Evidencias:**
- Reportes HTML con métricas reales
- Jenkins builds con logs verificables  
- Kubernetes pods funcionando
- Timestamps auditables

---

## 💡 **TROUBLESHOOTING**

### Si algo no funciona:

1. **Docker no inicia:**
   ```bash
   open -a Docker
   ```

2. **Kubernetes no responde:**
   ```bash
   minikube status
   minikube start
   ```

3. **Jenkins no accesible:**
   ```bash
   docker ps | grep jenkins
   ```

4. **Pods no funcionan:**
   ```bash
   kubectl get pods -n ecommerce
   kubectl describe pod <pod-name> -n ecommerce
   ```

---

**🚀 ¡Listo para usar y presentar!** 