# 🔍 Sistema de Monitoreo E-commerce Microservices

## 📋 Descripción

Implementación completa de monitoreo, logs y trazas centralizadas para el sistema de microservicios e-commerce con:

- ✅ **Prometheus + Grafana** para métricas y dashboards
- ✅ **ELK Stack** (Elasticsearch, Logstash, Kibana) para logs centralizados  
- ✅ **Jaeger** para tracing distribuido
- ✅ **AlertManager** para alertas críticas
- ✅ **Health checks** (readiness/liveness probes) en Kubernetes

---

## 🚀 Inicio Rápido

### 1. Setup Completo (Prerequisitos)
```bash
# Asegúrate de tener el setup base funcionando
./1-setup-completo.sh
./2-verificar-servicios.sh
```

### 2. Desplegar Monitoreo
```bash
# Hacer ejecutables los scripts
chmod +x deploy-monitoring.sh verify-monitoring.sh generate-monitoring-data.sh

# Desplegar toda la pila de monitoreo
./deploy-monitoring.sh

# Verificar que todo esté funcionando
./verify-monitoring.sh

# Generar datos de prueba
./generate-monitoring-data.sh
```

---

## 🎯 Componentes Desplegados

### 📊 Prometheus (Métricas)
- **Puerto**: 30090
- **URL**: http://minikube-ip:30090
- **Funcionalidad**: Recolección de métricas de todos los microservicios
- **Configuración**: Scraping cada 15 segundos
- **Targets**: user-service, product-service, order-service, payment-service, shipping-service, favourite-service

### 📈 Grafana (Dashboards)
- **Puerto**: 30030  
- **URL**: http://minikube-ip:30030
- **Credenciales**: admin / admin123
- **Dashboards**: E-commerce Overview con métricas por servicio
- **Datasource**: Prometheus configurado automáticamente

### 🔍 ELK Stack (Logs)

#### Elasticsearch
- **Puerto**: 9200
- **Funcionalidad**: Almacenamiento de logs indexados
- **Índices**: ecommerce-logs-YYYY.MM.dd

#### Logstash  
- **Puerto**: 5044 (beats), 8080 (http)
- **Funcionalidad**: Procesamiento y transformación de logs
- **Filtros**: Detección automática de ERROR y WARN

#### Kibana
- **Puerto**: 30601
- **URL**: http://minikube-ip:30601  
- **Funcionalidad**: Visualización y análisis de logs
- **Sin autenticación**

### 🔍 Jaeger (Tracing Distribuido)
- **Puerto**: 30686
- **URL**: http://minikube-ip:30686
- **Funcionalidad**: Trazabilidad de requests entre microservicios
- **Collector**: Puerto 14268
- **Agent UDP**: Puerto 6831

### 🚨 AlertManager (Alertas)
- **Puerto**: 30093
- **URL**: http://minikube-ip:30093
- **Funcionalidad**: Gestión de alertas de Prometheus
- **Configuración**: Webhook para notificaciones

### 📋 Filebeat (Recolección de Logs)
- **Tipo**: DaemonSet
- **Funcionalidad**: Recolección automática de logs de todos los pods
- **Output**: Logstash para procesamiento

---

## 🏥 Health Checks Configurados

Todos los microservicios incluyen:

### Liveness Probe
```yaml
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8081
  initialDelaySeconds: 60
  periodSeconds: 30
  timeoutSeconds: 10
  failureThreshold: 3
```

### Readiness Probe  
```yaml
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8081
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3
```

---

## 📊 Métricas Monitoreadas

### Métricas de Sistema
- **CPU Usage**: Por pod y servicio
- **Memory Usage**: Utilización de memoria
- **Network I/O**: Tráfico de red
- **Disk I/O**: Operaciones de disco

### Métricas de Aplicación
- **HTTP Requests**: Total, rate, duración
- **HTTP Status Codes**: 2xx, 4xx, 5xx
- **Response Time**: P50, P95, P99
- **Error Rate**: Porcentaje de errores

### Métricas de Kubernetes
- **Pod Status**: Running, Pending, Failed
- **Node Health**: Estado de nodos
- **Resource Utilization**: CPU/Memory por namespace

---

## 🚨 Alertas Configuradas

### Alertas Críticas
- **ServiceDown**: Servicio no disponible por >2 minutos
- **HighErrorRate**: Tasa de errores >5% por 5 minutos  
- **HighResponseTime**: Tiempo de respuesta >1s por 5 minutos
- **PodCrashLooping**: Pod reiniciando constantemente
- **NodeDown**: Nodo de Kubernetes no disponible

### Alertas de Warning
- **HighMemoryUsage**: Uso de memoria >80%
- **HighCPUUsage**: Uso de CPU >80%
- **DiskSpaceLow**: Espacio en disco <20%

---

## 📈 Dashboards Incluidos

### E-commerce Overview Dashboard
- **Service Health**: Estado de todos los microservicios
- **Request Rate**: Requests por segundo por servicio
- **Response Time**: Tiempo de respuesta promedio
- **Error Rate**: Porcentaje de errores por servicio
- **Resource Usage**: CPU y memoria por servicio

### Panels Específicos
- **HTTP Request Volume**: Volumen de requests HTTP
- **HTTP Duration**: Duración de requests HTTP  
- **HTTP Status Codes**: Distribución de códigos de estado
- **JVM Metrics**: Métricas de la JVM (si aplica)
- **Pod Status**: Estado de pods por servicio

---

## 🔧 Comandos Útiles

### Verificación de Estado
```bash
# Ver todos los pods de monitoreo
kubectl get pods -n monitoring

# Ver servicios de monitoreo  
kubectl get services -n monitoring

# Ver logs de componentes
kubectl logs -f deployment/prometheus -n monitoring
kubectl logs -f deployment/grafana -n monitoring
kubectl logs -f deployment/elasticsearch -n monitoring
```

### Port-Forward para Acceso Local
```bash
# Grafana
kubectl port-forward svc/grafana 3000:3000 -n monitoring

# Prometheus  
kubectl port-forward svc/prometheus 9090:9090 -n monitoring

# Kibana
kubectl port-forward svc/kibana 5601:5601 -n monitoring

# Jaeger
kubectl port-forward svc/jaeger 16686:16686 -n monitoring
```

### Consultas de Prometheus
```bash
# Verificar targets
curl http://minikube-ip:30090/api/v1/targets

# Métricas de disponibilidad
curl http://minikube-ip:30090/api/v1/query?query=up

# Rate de requests HTTP
curl http://minikube-ip:30090/api/v1/query?query=rate(http_requests_total[5m])
```

### Consultas de Elasticsearch  
```bash
# Salud del cluster
curl http://minikube-ip:9200/_cluster/health

# Índices disponibles
curl http://minikube-ip:9200/_cat/indices

# Buscar logs de errores
curl -X GET "http://minikube-ip:9200/ecommerce-logs-*/_search" \
  -H 'Content-Type: application/json' \
  -d '{"query": {"match": {"log_level": "ERROR"}}}'
```

---

## 🔍 Troubleshooting

### Prometheus no recolecta métricas
```bash
# Verificar configuración
kubectl get configmap prometheus-config -n monitoring -o yaml

# Verificar targets en Prometheus UI
# http://minikube-ip:30090/targets

# Verificar anotaciones en pods
kubectl get pods -n ecommerce -o yaml | grep prometheus.io
```

### Grafana no muestra datos
```bash
# Verificar datasource
kubectl logs deployment/grafana -n monitoring

# Verificar conectividad con Prometheus
kubectl exec -it deployment/grafana -n monitoring -- \
  curl http://prometheus:9090/-/healthy
```

### ELK Stack no recibe logs
```bash
# Verificar Filebeat
kubectl get daemonset filebeat -n monitoring
kubectl logs daemonset/filebeat -n monitoring

# Verificar Logstash
kubectl logs deployment/logstash -n monitoring

# Verificar conectividad Logstash->Elasticsearch
kubectl exec -it deployment/logstash -n monitoring -- \
  curl http://elasticsearch:9200/_cluster/health
```

### Jaeger no muestra trazas
```bash
# Verificar configuración de tracing en microservicios
kubectl get deployment user-service -n ecommerce -o yaml | grep JAEGER

# Verificar conectividad
kubectl exec -it deployment/user-service -n ecommerce -- \
  nc -zv jaeger.monitoring.svc.cluster.local 6831
```

---

## 📚 URLs de Acceso

Obtén la IP de minikube: `minikube ip`

| Servicio | URL | Credenciales |
|----------|-----|--------------|
| Prometheus | http://minikube-ip:30090 | N/A |
| Grafana | http://minikube-ip:30030 | admin/admin123 |
| Kibana | http://minikube-ip:30601 | N/A |  
| Jaeger | http://minikube-ip:30686 | N/A |
| AlertManager | http://minikube-ip:30093 | N/A |

---

## 🎯 Criterios de Aceptación ✅

- ✅ **Prometheus + Grafana** instalados con dashboards por servicio
- ✅ **ELK Stack** recibiendo logs de todos los microservicios  
- ✅ **Alertas configuradas** para errores críticos y performance
- ✅ **Tracing distribuido** habilitado con Jaeger
- ✅ **Health checks** (readiness/liveness probes) en Kubernetes

---

## 🚀 Próximos Pasos

1. **Personalizar Dashboards**: Adaptar dashboards en Grafana según necesidades específicas
2. **Configurar Notificaciones**: Agregar Slack/Email a AlertManager  
3. **Optimizar Retención**: Ajustar retención de métricas y logs
4. **Seguridad**: Implementar autenticación y autorización
5. **Backup**: Configurar backup de configuraciones y datos

---

## 📖 Documentación Adicional

- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)  
- [Elastic Stack Documentation](https://www.elastic.co/guide/)
- [Jaeger Documentation](https://www.jaegertracing.io/docs/)
- [Kubernetes Monitoring Best Practices](https://kubernetes.io/docs/concepts/cluster-administration/monitoring/) 