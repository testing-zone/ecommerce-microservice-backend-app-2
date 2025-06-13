# 📊 Guía Completa ELK Stack - E-commerce Microservices

## 🎯 ¿Qué es ELK Stack y para qué sirve?

**ELK Stack** (Elasticsearch + Logstash + Kibana) es la implementación del **Patrón de Observability** para **LOGS CENTRALIZADOS**:

- **Elasticsearch**: Base de datos de búsqueda que almacena logs
- **Logstash**: Procesador que recolecta, transforma y envía logs
- **Kibana**: Dashboard visual para analizar logs

### 🔍 Métricas que muestra ELK Stack:

1. **📝 Logs por Servicio**: Todos los logs de cada microservicio
2. **⚠️ Errores y Excepciones**: Detección automática de problemas
3. **⏱️ Performance**: Tiempos de respuesta y latencia
4. **📊 Volumen de Logs**: Cantidad de logs por servicio/tiempo
5. **🔍 Búsquedas Avanzadas**: Filtros por servicio, nivel, tiempo
6. **📈 Tendencias**: Patrones de errores y uso

## 🚀 Despliegue Rápido

### 1. Desplegar ELK Stack
```bash
# Desplegar todo el stack
./monitoring/elk/deploy-elk-stack.sh

# Verificar despliegue
kubectl get pods -n monitoring
```

### 2. Configurar Microservicios
```bash
# Configurar logging en Spring Boot
./monitoring/elk/configure-spring-boot-logging.sh

# Recompilar servicios (ejemplo)
cd user-service && mvn clean package -DskipTests
```

### 3. Probar Sistema
```bash
# Enviar logs de prueba
./monitoring/elk/test-elk-logging.sh
```

## 🌐 URLs de Acceso

| Servicio | URL | Puerto | Descripción |
|----------|-----|--------|-------------|
| **Kibana** | http://localhost:30601 | 30601 | Dashboard principal |
| **Elasticsearch** | http://localhost:30920 | 30920 | API de búsqueda |
| **Logstash HTTP** | http://localhost:30580 | 30580 | Recepción HTTP |
| **Logstash TCP** | localhost:30500 | 30500 | Recepción TCP |

## 📋 Configuración en Kibana

### 1. Crear Index Pattern
1. Abrir Kibana: http://localhost:30601
2. Ir a **Stack Management** > **Index Patterns**
3. Crear patrón: `ecommerce-logs-*`
4. Seleccionar campo de tiempo: `@timestamp`
5. Guardar

### 2. Explorar Logs
1. Ir a **Discover**
2. Seleccionar index pattern: `ecommerce-logs-*`
3. Ver logs en tiempo real

### 3. Crear Dashboards
1. Ir a **Dashboard**
2. Crear nuevo dashboard
3. Agregar visualizaciones:
   - **Logs por Servicio**: Pie chart por `service_name`
   - **Errores**: Bar chart filtrado por `level:ERROR`
   - **Performance**: Line chart de `response_time_ms`
   - **Timeline**: Histogram por tiempo

## 🔍 Campos Disponibles

Los logs incluyen estos campos automáticamente:

```json
{
  "@timestamp": "2024-01-15T10:30:00.000Z",
  "service_name": "user-service",
  "service_type": "business",
  "service_category": "user_management",
  "level": "INFO",
  "log_message": "Usuario creado exitosamente",
  "response_time_ms": 150,
  "alert_level": "medium",
  "host": "pod-name",
  "environment": "production"
}
```

## 📊 Dashboards Recomendados

### 1. **Overview Dashboard**
- Total de logs por servicio
- Distribución de niveles (INFO, WARN, ERROR)
- Timeline de actividad
- Top errores

### 2. **Performance Dashboard**
- Tiempos de respuesta promedio
- Servicios más lentos
- Tendencias de performance
- Alertas de latencia

### 3. **Error Analysis Dashboard**
- Errores por servicio
- Tipos de excepciones
- Frecuencia de errores
- Stack traces

### 4. **Business Metrics Dashboard**
- Actividad por categoría de servicio
- Transacciones vs Catálogo
- Patrones de uso
- Métricas de negocio

## 🔧 Configuración Avanzada

### Filtros Útiles en Kibana

```bash
# Errores de un servicio específico
service_name:"user-service" AND level:"ERROR"

# Performance lenta
response_time_ms:>1000

# Errores de base de datos
log_message:"database" OR log_message:"connection"

# Servicios de negocio vs infraestructura
service_type:"business"
service_type:"infrastructure"

# Últimos 15 minutos
@timestamp:[now-15m TO now]
```

### Alertas Recomendadas

1. **Error Rate Alto**: >10 errores/minuto
2. **Performance Degradada**: response_time > 2000ms
3. **Servicio Caído**: Sin logs en 5 minutos
4. **Memoria Alta**: logs con "OutOfMemory"

## 🛠️ Troubleshooting

### Problemas Comunes

1. **No aparecen logs**:
   ```bash
   # Verificar Logstash
   kubectl logs -n monitoring deployment/logstash
   
   # Verificar conectividad
   curl http://localhost:30580
   ```

2. **Elasticsearch no responde**:
   ```bash
   # Verificar estado
   curl http://localhost:30920/_cluster/health
   
   # Ver logs
   kubectl logs -n monitoring deployment/elasticsearch
   ```

3. **Kibana no carga**:
   ```bash
   # Verificar conexión a Elasticsearch
   kubectl logs -n monitoring deployment/kibana
   ```

### Comandos de Diagnóstico

```bash
# Estado general
kubectl get pods -n monitoring

# Logs de componentes
kubectl logs -n monitoring -l app=elasticsearch
kubectl logs -n monitoring -l app=logstash
kubectl logs -n monitoring -l app=kibana

# Verificar índices
curl -s http://localhost:30920/_cat/indices?v

# Buscar logs recientes
curl -s "http://localhost:30920/ecommerce-logs-*/_search?size=5&sort=@timestamp:desc"
```

## 📈 Métricas de Ejemplo

### Logs que verás:

1. **Logs de Aplicación**:
   ```
   2024-01-15 10:30:00 INFO [user-service] Usuario creado: ID=123
   2024-01-15 10:30:01 ERROR [product-service] Error conectando BD
   2024-01-15 10:30:02 INFO [api-gateway] Request processed in 150ms
   ```

2. **Métricas de Performance**:
   - Tiempo promedio de respuesta por servicio
   - Percentiles P95, P99
   - Throughput (requests/segundo)

3. **Análisis de Errores**:
   - Stack traces completos
   - Frecuencia de errores
   - Servicios más problemáticos

## 🎯 Casos de Uso

### Para Desarrolladores:
- Debugging de errores específicos
- Análisis de performance
- Seguimiento de requests

### Para DevOps:
- Monitoreo de salud del sistema
- Alertas proactivas
- Análisis de capacidad

### Para Business:
- Métricas de uso
- Patrones de comportamiento
- KPIs operacionales

## 🔄 Integración con Otros Sistemas

ELK Stack se integra con:
- **Prometheus**: Métricas numéricas
- **Grafana**: Dashboards unificados
- **Jaeger**: Trazas distribuidas
- **Alertmanager**: Notificaciones

## 📚 Recursos Adicionales

- [Elasticsearch Query DSL](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html)
- [Kibana User Guide](https://www.elastic.co/guide/en/kibana/current/index.html)
- [Logstash Configuration](https://www.elastic.co/guide/en/logstash/current/configuration.html)

---

**¡ELK Stack te da visibilidad completa de todos los logs de tu sistema de microservicios!** 🚀 