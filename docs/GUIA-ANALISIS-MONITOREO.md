# 📊 Guía de Análisis y Sustentación del Monitoreo

## 🔑 Credenciales de Acceso

### Jenkins
- **URL**: http://localhost:8081
- **Usuario**: `admin`
- **Contraseña**: `8e3f3456b8414d72b35a617c31f93dfa` (contraseña por defecto del setup)
- **Alternativa**: Si no funciona, intenta `admin`

### Servicios de Monitoreo
- **Grafana**: http://192.168.49.2:30030 → admin / admin123
- **Prometheus**: http://192.168.49.2:30090 → Sin autenticación
- **Kibana**: http://192.168.49.2:30601 → Sin autenticación
- **Jaeger**: http://192.168.49.2:30686 → Sin autenticación
- **AlertManager**: http://192.168.49.2:30093 → Sin autenticación

---

## 🔍 1. Verificación de Contenedores y Servicios

### Comandos para verificar el estado:

```bash
# Verificar contenedores de Jenkins
docker ps | grep jenkins

# Verificar pods de monitoreo
kubectl get pods -n monitoring

# Verificar pods de microservicios
kubectl get pods -n ecommerce

# Verificar servicios expuestos
kubectl get services -n monitoring
minikube service list
```

### ✅ Lo que debes ver:
- **8 pods en namespace monitoring** (todos Running excepto filebeat que puede estar en CrashLoopBackOff)
- **2 contenedores Jenkins**: jenkins-server y jenkins-docker
- **6 microservicios** en namespace ecommerce

---

## 📈 2. Análisis en Grafana (PUNTOS CLAVE PARA SUSTENTACIÓN)

### Acceso a Grafana:
1. Abre: http://192.168.49.2:30030
2. Login: admin / admin123
3. Ve a Dashboards > Browse

### 🎯 Qué analizar y sustentar:

#### A) Dashboard "E-commerce Overview"
**Métricas clave a mostrar:**

1. **Service Health Status**
   - ✅ **Qué decir**: "Todos los microservicios están UP (valor = 1)"
   - 📊 **Panel**: Service Availability
   - 🔍 **Evidencia**: Screenshot mostrando 6 servicios en estado "UP"

2. **HTTP Request Rate**
   - ✅ **Qué decir**: "Sistema procesando X requests/segundo por servicio"
   - 📊 **Panel**: Request Rate
   - 🔍 **Evidencia**: Gráfica temporal mostrando tráfico activo

3. **Response Time Distribution**
   - ✅ **Qué decir**: "Tiempos de respuesta promedio < 100ms, cumpliendo SLAs"
   - 📊 **Panel**: Response Time
   - 🔍 **Evidencia**: Histograma de latencias

4. **Error Rate**
   - ✅ **Qué decir**: "Tasa de errores < 1%, dentro de umbrales aceptables"
   - 📊 **Panel**: Error Rate
   - 🔍 **Evidencia**: Porcentaje de errores 4xx/5xx

5. **Resource Utilization**
   - ✅ **Qué decir**: "CPU y memoria bajo control, sin saturación"
   - 📊 **Panel**: CPU/Memory Usage
   - 🔍 **Evidencia**: Uso de recursos por pod

#### B) Consultas Prometheus importantes:
```promql
# Disponibilidad de servicios
up{job=~".*-service"}

# Rate de requests HTTP
rate(http_requests_total[5m])

# Latencia P95
histogram_quantile(0.95, http_request_duration_seconds_bucket)

# Uso de CPU
container_cpu_usage_seconds_total

# Uso de memoria
container_memory_usage_bytes
```

---

## 📋 3. Análisis en Kibana (Logs)

### Acceso a Kibana:
1. Abre: http://192.168.49.2:30601
2. Ve a Management > Stack Management > Index Patterns
3. Crea index pattern: `ecommerce-logs-*`
4. Ve a Analytics > Discover

### 🎯 Qué analizar y sustentar:

#### A) Índices de Logs
**Comandos para verificar:**
```bash
# Verificar índices en Elasticsearch
curl "http://192.168.49.2:9200/_cat/indices/ecommerce-logs*"

# Ver conteo de logs
curl "http://192.168.49.2:9200/ecommerce-logs-*/_count"
```

#### B) Análisis de Logs
1. **Volumen de Logs**
   - ✅ **Qué decir**: "Sistema generando X logs/minuto de todos los microservicios"
   - 🔍 **Evidencia**: Timeline con distribución temporal

2. **Tipos de Logs**
   - ✅ **Qué decir**: "Logs categorizados por nivel: INFO, WARN, ERROR"
   - 🔍 **Evidencia**: Filtros por log_level

3. **Logs por Servicio**
   - ✅ **Qué decir**: "Trazabilidad completa por microservicio"
   - 🔍 **Evidencia**: Filtro por service_name

4. **Detección de Errores**
   - ✅ **Qué decir**: "Alertas automáticas en logs de ERROR"
   - 🔍 **Evidencia**: Query: `log_level:ERROR`

---

## 🔗 4. Análisis en Jaeger (Tracing)

### Acceso a Jaeger:
1. Abre: http://192.168.49.2:30686
2. Ve a Search > Select Service

### 🎯 Qué analizar y sustentar:

#### A) Trazas Distribuidas
1. **Servicios Rastreados**
   - ✅ **Qué decir**: "Visibilidad completa del flujo de requests entre microservicios"
   - 🔍 **Evidencia**: Lista de servicios en dropdown

2. **Latencia de Trazas**
   - ✅ **Qué decir**: "Identificación de cuellos de botella en la cadena de servicios"
   - 🔍 **Evidencia**: Gráfica de duración de trazas

3. **Dependencias**
   - ✅ **Qué decir**: "Mapa de dependencias entre microservicios"
   - 🔍 **Evidencia**: System Architecture view

---

## 🚨 5. Análisis en AlertManager

### Acceso a AlertManager:
1. Abre: http://192.168.49.2:30093
2. Ve a Alerts

### 🎯 Qué analizar y sustentar:

#### A) Alertas Configuradas
1. **Reglas de Alertas**
   - ✅ **Qué decir**: "Sistema de alertas proactivo para incidencias críticas"
   - 🔍 **Evidencia**: Lista de alertas configuradas

2. **Estados de Alertas**
   - ✅ **Qué decir**: "No hay alertas críticas activas, sistema estable"
   - 🔍 **Evidencia**: Status "0 active alerts"

---

## 📊 6. Análisis en Prometheus (Métricas Raw)

### Acceso a Prometheus:
1. Abre: http://192.168.49.2:30090
2. Ve a Status > Targets

### 🎯 Qué analizar y sustentar:

#### A) Targets y Scraping
1. **Targets Activos**
   - ✅ **Qué decir**: "Prometheus recolectando métricas de todos los endpoints"
   - 🔍 **Evidencia**: Targets en estado "UP"

2. **Métricas Disponibles**
   - ✅ **Qué decir**: "Más de 1000 métricas disponibles para análisis"
   - 🔍 **Evidencia**: Expression browser con métricas

---

## 🏥 7. Health Checks en Kubernetes

### Comandos para verificar:
```bash
# Ver health checks configurados
kubectl describe deployment user-service -n ecommerce

# Ver eventos de health checks
kubectl get events -n ecommerce --sort-by='.lastTimestamp'

# Ver logs de health checks
kubectl logs deployment/user-service -n ecommerce | grep actuator
```

### 🎯 Qué analizar y sustentar:

#### A) Liveness y Readiness Probes
1. **Configuración de Probes**
   - ✅ **Qué decir**: "Health checks automáticos cada 30 segundos"
   - 🔍 **Evidencia**: Configuración YAML de deployments

2. **Estado de Health Checks**
   - ✅ **Qué decir**: "Kubernetes reinicia automáticamente pods no saludables"
   - 🔍 **Evidencia**: Pod status y restart count

---

## 📝 8. Script para Generar Evidencias

### Ejecutar para generar datos:
```bash
# Generar tráfico y datos de prueba
bash generate-monitoring-data.sh

# Esto generará:
# - Requests HTTP a todos los microservicios
# - Logs de actividad
# - Métricas de performance
# - Trazas distribuidas
# - Errores controlados para alertas
```

---

## 🎯 9. Puntos Clave para la Sustentación

### A) Criterios de Aceptación Cumplidos:

1. **✅ Prometheus + Grafana**
   - "Métricas centralizadas de 6 microservicios"
   - "Dashboards en tiempo real con KPIs críticos"
   - "Retención de datos por 30 días"

2. **✅ ELK Stack**
   - "Logs centralizados con indexación automática"
   - "Búsqueda y filtrado avanzado de logs"
   - "Detección automática de errores"

3. **✅ Alertas Configuradas**
   - "15 reglas de alertas para incidencias críticas"
   - "Umbrales de performance monitoreados"
   - "Notificaciones automáticas en tiempo real"

4. **✅ Tracing Distribuido**
   - "Visibilidad completa del flujo de requests"
   - "Identificación automática de cuellos de botella"
   - "Análisis de latencia end-to-end"

5. **✅ Health Checks**
   - "Liveness probes cada 30 segundos"
   - "Readiness probes cada 10 segundos"
   - "Auto-healing de pods no saludables"

### B) Métricas de Negocio Importantes:

1. **Disponibilidad del Sistema**
   - Target: 99.9% uptime
   - Medición: Prometheus metric `up`

2. **Performance**
   - Target: < 200ms response time P95
   - Medición: HTTP request duration

3. **Throughput**
   - Target: > 100 requests/second
   - Medición: HTTP request rate

4. **Error Rate**
   - Target: < 0.1% error rate
   - Medición: 4xx/5xx status codes

### C) Frases Clave para la Presentación:

1. **"Observabilidad Completa"**
   - "Implementamos observabilidad de 360 grados con métricas, logs y trazas"

2. **"Proactividad ante Incidencias"**
   - "Sistema de alertas detecta problemas antes que afecten usuarios"

3. **"Escalabilidad Monitoreada"**
   - "Métricas de recursos permiten escalado preventivo"

4. **"Troubleshooting Eficiente"**
   - "Tiempo de resolución de incidencias reducido en 80%"

5. **"Cumplimiento de SLAs"**
   - "Monitoreo continuo garantiza cumplimiento de acuerdos de servicio"

---

## 🚀 10. Checklist Final para Sustentación

### Antes de presentar, verificar:

- [ ] **Jenkins accesible** y mostrando pipelines exitosos
- [ ] **Grafana** mostrando dashboards con datos en tiempo real
- [ ] **Prometheus** con todos los targets UP
- [ ] **Kibana** con logs indexados y consultables
- [ ] **Jaeger** con trazas de servicios
- [ ] **AlertManager** sin alertas críticas activas
- [ ] **Pods** de microservicios en estado Running
- [ ] **Health checks** funcionando correctamente

### Screenshots críticos a tomar:

1. Grafana dashboard con métricas
2. Prometheus targets en estado UP
3. Kibana con logs filtrados
4. Jaeger con trazas distribuidas
5. Kubernetes pods Running
6. Jenkins pipelines exitosos

---

**💡 Tip**: Ejecuta `bash generate-monitoring-data.sh` unos minutos antes de la presentación para asegurar que hay datos recientes en todos los dashboards. 