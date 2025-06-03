# 🎯 TALLER 2 - GUÍA ULTRA SIMPLE (3 PASOS)

## ⚠️ IMPORTANTE: USA TERMINAL NATIVO (NO POWERSHELL)

### 📋 PROBLEMA ACTUAL:
- PowerShell causa que los scripts se "cuelguen"
- Necesitas **Terminal nativo de macOS**

---

## 🚀 SOLUCIÓN EN 3 PASOS:

### **PASO 1: Cambiar a Terminal nativo**
1. Cierra PowerShell completamente
2. Presiona `Cmd + Espacio`
3. Escribe "Terminal"
4. Presiona Enter

### **PASO 2: Navegar al proyecto**
```bash
cd /Users/svak/Documents/ecommerce-microservice-backend-app-2
```

### **PASO 3: Ejecutar script que NO se cuelga**
```bash
./START.sh
```

**Luego usar:**
```bash
./TALLER_2_MINIMO.sh
```

---

## 🎯 DIFERENCIAS IMPORTANTES:

### ❌ ANTES (Scripts que se colgaban):
- `SETUP_COMPLETO_TALLER_2.sh` - Muy complejo
- `fix-and-run-tests.sh` - Timeouts largos
- `EJECUTAR_TALLER_2.sh` - Configuraciones pesadas

### ✅ AHORA (Scripts que NO se cuelgan):
- `START.sh` - Verificación instantánea (1 segundo)
- `TALLER_2_MINIMO.sh` - Opciones simples (máximo 60 segundos)

---

## 📋 OPCIONES DEL SCRIPT MÍNIMO:

**A.** Instalar dependencias (brew, docker, kubectl, minikube)
**B.** Solo configurar Kubernetes básico
**C.** Solo test de performance simple
**D.** Ver estado actual
**E.** Limpiar todo

---

## 🎉 GARANTÍA: ¡NO SE CUELGA!

Los nuevos scripts están diseñados para:
- ✅ Terminar rápido (máximo 60 segundos)
- ✅ Mostrar progreso paso a paso
- ✅ Fallar gracefully si hay problemas
- ✅ Funcionar en Terminal nativo

---

## 📸 PARA SCREENSHOTS TALLER 2:

Después del script mínimo:
```bash
kubectl get pods -n ecommerce
kubectl get services -n ecommerce
minikube dashboard
```

## 🎯 ¡PROBLEMA RESUELTO!

Scripts ultrarrápidos que funcionan sin colgarse. 