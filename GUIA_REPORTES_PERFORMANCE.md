# 📊 Guía de Reportes de Performance - Taller 2

## 🎯 Opciones de Generación de Reportes

### **Opción 1: Prueba Rápida (Recomendada para demostración)**
```bash
./quick-performance-test.sh
```
- ⏱️ **Duración**: 1 minuto
- 👥 **Usuarios**: 50 concurrentes
- 📊 **Ideal para**: Screenshots y demostración rápida

### **Opción 2: Prueba Completa (Análisis exhaustivo)**
```bash
./generate-performance-report.sh
```
- ⏱️ **Duración**: 5-10 minutos
- 👥 **Usuarios**: Hasta 200 concurrentes
- 📊 **Ideal para**: Análisis detallado y documentación completa

---

## 🚀 Paso a Paso: Generación de Reportes

### **Prerequisitos**
1. **Python 3** instalado
2. **Locust** (se instala automáticamente si no existe)
3. **Al menos un microservicio corriendo** (o usará servidor de prueba)

### **Ejecución**

#### **Para Prueba Rápida:**
```bash
# 1. Asegúrate de estar en el directorio del proyecto
cd /Users/svak/Documents/ecommerce-microservice-backend-app-2

# 2. Ejecutar prueba rápida
./quick-performance-test.sh

# 3. Ver resultados
open quick-performance-report/performance-report-*.html
```

#### **Para Prueba Completa:**
```bash
# 1. (Opcional) Iniciar algunos microservicios
# Ejemplo: iniciar product-service en puerto 8082

# 2. Ejecutar prueba completa
./generate-performance-report.sh

# 3. Ver reporte principal
open performance-reports/*/performance-summary.html
```

---

## 📁 Archivos Generados

### **Prueba Rápida** (`quick-performance-report/`)
```
📊 performance-report-[fecha].html    ← Reporte visual principal
📄 performance-stats-[fecha]_stats.csv ← Datos CSV
📝 performance-[fecha].log            ← Log detallado
📋 performance-summary-[fecha].txt    ← Resumen texto
```

### **Prueba Completa** (`performance-reports/[fecha]/`)
```
📊 performance-summary.html           ← Dashboard principal
📈 ecommerce-load-test-report.html   ← Usuarios normales
🔧 admin-load-test-report.html       ← Operaciones admin  
⚡ stress-test-report.html           ← Pruebas de estrés
📄 *.csv                             ← Datos raw CSV
📝 performance-analysis.txt          ← Análisis automático
📋 *.log                             ← Logs detallados
```

---

## 📊 Interpretación de Métricas

### **Métricas Clave en los Reportes:**

#### **1. Response Time (Tiempo de Respuesta)**
- 🟢 **< 200ms**: Excelente
- 🟡 **200-500ms**: Bueno
- 🟠 **500-1000ms**: Aceptable
- 🔴 **> 1000ms**: Necesita optimización

#### **2. Requests per Second (RPS)**
- **Medida**: Throughput del sistema
- **Interpretación**: Cuántas peticiones maneja por segundo

#### **3. Error Rate (Tasa de Errores)**
- 🟢 **0-1%**: Excelente
- 🟡 **1-5%**: Aceptable
- 🔴 **> 5%**: Problemático

#### **4. Concurrent Users (Usuarios Concurrentes)**
- **Medida**: Máximo número de usuarios simultáneos soportados
- **Objetivo**: Validar escalabilidad

---

## 🎯 Para la Sustentación del Taller 2

### **Screenshots Requeridos:**

#### **1. Dashboard Principal**
```bash
open performance-reports/*/performance-summary.html
# Screenshot: Configuración y métricas generales
```

#### **2. Gráficos de Performance**
```bash
open performance-reports/*/ecommerce-load-test-report.html
# Screenshot: Response time charts, RPS charts
```

#### **3. Métricas Específicas**
- **Response Time Distribution**
- **Requests per Second over Time**
- **Number of Users over Time**
- **Failures over Time**

### **Datos para Incluir en Documentación:**

#### **Ejemplo de Métricas a Reportar:**
```
✅ RESULTADOS DE PERFORMANCE:
- Usuarios Concurrentes Máximos: 100
- Tiempo de Respuesta Promedio: 245ms
- Requests por Segundo: 45.2 RPS
- Tasa de Éxito: 98.5%
- Duración de Prueba: 5 minutos
- Total de Requests: 13,560
```

---

## 🔧 Personalización de Pruebas

### **Modificar Configuración Rápida:**
```bash
# Editar quick-performance-test.sh
DURATION="120s"     # Cambiar duración
MAX_USERS="100"     # Cambiar usuarios máximos
SPAWN_RATE="10"     # Cambiar tasa de generación
BASE_URL="http://localhost:8083"  # Cambiar servicio objetivo
```

### **Modificar Configuración Completa:**
```bash
# Editar generate-performance-report.sh
DURATION="600s"     # 10 minutos
MAX_USERS="200"     # 200 usuarios
SPAWN_RATE="20"     # 20 usuarios/segundo
```

---

## 🚨 Solución de Problemas

### **Error: "Locust no encontrado"**
```bash
pip3 install locust
# o
python3 -m pip install locust
```

### **Error: "Connection refused"**
- ✅ Verificar que el microservicio esté corriendo
- ✅ El script automáticamente usa httpbin.org como fallback
- ✅ Cambiar BASE_URL en el script si es necesario

### **Error: "Permission denied"**
```bash
chmod +x quick-performance-test.sh
chmod +x generate-performance-report.sh
```

### **Sin datos en CSV**
- ✅ La prueba debe ejecutarse completamente
- ✅ Verificar que no haya errores en el log
- ✅ Asegurar que el servidor objetivo responde

---

## 📈 Análisis Avanzado

### **Comandos Útiles para Análisis:**

#### **Ver estadísticas rápidas:**
```bash
# Ver resumen de archivo CSV
head -5 quick-performance-report/performance-stats-*_stats.csv

# Contar total de requests
tail -1 quick-performance-report/performance-stats-*_stats.csv
```

#### **Análisis de logs:**
```bash
# Ver errores en el log
grep "ERROR" quick-performance-report/performance-*.log

# Ver requests exitosos
grep "200" quick-performance-report/performance-*.log | wc -l
```

---

## ✅ Checklist para Entrega Taller 2

### **Reportes de Performance Requeridos:**
- [ ] 📊 Reporte HTML principal generado
- [ ] 📄 Archivo CSV con métricas
- [ ] 📸 Screenshots de métricas clave
- [ ] 📝 Análisis de resultados incluido en documentación
- [ ] 🎯 Métricas específicas documentadas:
  - [ ] Usuarios concurrentes soportados
  - [ ] Tiempo de respuesta promedio
  - [ ] Throughput (requests/segundo)
  - [ ] Tasa de éxito
  - [ ] Performance bajo diferentes cargas

### **Para la Sustentación:**
- [ ] 🖥️ Demostración en vivo de generación de reporte
- [ ] 📊 Explicación de métricas obtenidas
- [ ] 📈 Análisis de comportamiento del sistema
- [ ] 🎯 Validación de requerimientos de performance
- [ ] 🔄 Comparación entre diferentes tipos de carga

---

## 🚀 Comando Rápido Final

**Para generar reporte rápido para demostración:**
```bash
./quick-performance-test.sh && open quick-performance-report/performance-report-*.html
```

**Para análisis completo:**
```bash
./generate-performance-report.sh && open performance-reports/*/performance-summary.html
```

---

**¡Listo para generar reportes profesionales de performance para tu Taller 2!** 🎯 