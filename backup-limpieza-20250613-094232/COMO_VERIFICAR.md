# 🔍 CÓMO SABER QUE TODO ESTÁ FUNCIONANDO BIEN

## ⚠️ IMPORTANTE: Usar Terminal nativo de macOS (NO PowerShell)

---

## 🚀 MÉTODO 1: Script automático de verificación

```bash
# En Terminal nativo:
cd /Users/svak/Documents/ecommerce-microservice-backend-app-2
chmod +x VERIFICAR_FUNCIONAMIENTO.sh
./VERIFICAR_FUNCIONAMIENTO.sh
```

**Resultado esperado:**
```
✅ Verificaciones pasadas: 10/10
🎉 TODO FUNCIONA PERFECTAMENTE
```

---

## 🔍 MÉTODO 2: Verificación manual paso a paso

### **1. Verificar infraestructura básica:**
```bash
# Docker funcionando
docker --version
# Debería mostrar: Docker version 25.0.2

# minikube corriendo  
minikube status
# Debería mostrar: minikube: Running

# kubectl conectado
kubectl cluster-info
# Debería mostrar: Kubernetes control plane is running
```

### **2. Verificar namespace y pods:**
```bash
# Namespace existe
kubectl get namespace ecommerce
# Debería mostrar: ecommerce   Active   [edad]

# Pods funcionando
kubectl get pods -n ecommerce
# Debería mostrar algo como:
# NAME                               READY   STATUS    RESTARTS   AGE
# ecommerce-working-xxx-xxx          1/1     Running   0          5m
```

### **3. Verificar servicios:**
```bash
# Servicios expuestos
kubectl get services -n ecommerce
# Debería mostrar algo como:
# NAME                TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
# ecommerce-working   NodePort   10.x.x.x         <none>        8082:30082/TCP   5m
```

### **4. Verificar conectividad:**
```bash
# Obtener URL del servicio
minikube service ecommerce-working -n ecommerce --url

# Probar el servicio (usando la URL anterior)
curl [URL_DEL_SERVICIO]
# Debería mostrar: <h1>E-commerce API Working!</h1><p>Status: UP</p>
```

---

## ✅ SEÑALES DE QUE TODO FUNCIONA:

### **Estado de Pods:**
- ✅ **STATUS: Running** (no CrashLoopBackOff, no Pending)
- ✅ **READY: 1/1** (pod completamente listo)
- ✅ **RESTARTS: 0 o número bajo** (no está crasheando constantemente)

### **Estado de Servicios:**
- ✅ **TYPE: NodePort** (expuesto correctamente)
- ✅ **PORT(S): 8082:30082/TCP** (puerto configurado)
- ✅ **CLUSTER-IP asignada** (servicio tiene IP interna)

### **Conectividad:**
- ✅ **minikube service** devuelve URL (ej: http://192.168.x.x:30082)
- ✅ **curl** devuelve respuesta HTML (no error de conexión)
- ✅ **Respuesta contiene "E-commerce API Working!"**

---

## ❌ SEÑALES DE PROBLEMAS:

### **Pods con problemas:**
- ❌ **STATUS: CrashLoopBackOff** → Ejecutar `./FIX_POD.sh`
- ❌ **STATUS: Pending** → Revisar recursos de minikube
- ❌ **READY: 0/1** → Pod no está listo
- ❌ **RESTARTS: número alto** → Configuración incorrecta

### **Servicios con problemas:**
- ❌ **No hay servicios** → Necesita desplegar aplicación
- ❌ **No hay CLUSTER-IP** → Servicio mal configurado
- ❌ **Puerto incorrecto** → Configuración del servicio

### **Conectividad con problemas:**
- ❌ **minikube service** da error → Servicio no existe o mal configurado
- ❌ **curl** da "Connection refused" → Pod no está funcionando
- ❌ **curl** da timeout → Problemas de red o pod lento

---

## 🎯 RESULTADO FINAL ESPERADO:

Cuando todo funciona correctamente deberías ver:

```bash
kubectl get pods -n ecommerce
NAME                               READY   STATUS    RESTARTS   AGE
ecommerce-working-xxx-xxx          1/1     Running   0          5m

kubectl get services -n ecommerce  
NAME                TYPE       CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
ecommerce-working   NodePort   10.x.x.x         <none>        8082:30082/TCP   5m

curl $(minikube service ecommerce-working -n ecommerce --url)
<h1>E-commerce API Working!</h1><p>Status: UP</p><p>Taller 2 - 100% Functional</p>
```

---

## 📸 PARA SCREENSHOTS DEL TALLER:

Cuando tengas el resultado final esperado, estos comandos te darán las capturas perfectas:

```bash
# 1. Pods funcionando
kubectl get pods -n ecommerce

# 2. Servicios activos
kubectl get services -n ecommerce

# 3. Dashboard visual  
minikube dashboard

# 4. Performance test
./TALLER_2_MINIMO.sh → opción C

# 5. Respuesta del API
curl $(minikube service ecommerce-working -n ecommerce --url)
```

---

## 🎉 RESUMEN: 

**Sabes que funciona cuando:**
1. ✅ Pods en estado "Running" 
2. ✅ Servicios con CLUSTER-IP asignada
3. ✅ curl devuelve "E-commerce API Working!"
4. ✅ Script de verificación muestra 10/10 checks passed

**Si algo falla:** Ejecuta `./FIX_POD.sh` en Terminal nativo. 