# Guía de Troubleshooting - Sistema de Monitoreo

## Resumen Ejecutivo

Esta guía proporciona procedimientos sistemáticos para diagnosticar y resolver problemas comunes en el stack de monitoreo del sistema de microservicios E-commerce. Incluye soluciones para Prometheus, Grafana, ELK Stack, Zipkin y componentes de observabilidad.

## Tabla de Contenidos

1. [Diagnóstico General](#diagnóstico-general)
2. [Problemas de Prometheus](#problemas-de-prometheus)
3. [Problemas de Grafana](#problemas-de-grafana)
4. [Problemas de ELK Stack](#problemas-de-elk-stack)
5. [Problemas de Zipkin](#problemas-de-zipkin)
6. [Problemas de Conectividad](#problemas-de-conectividad)
7. [Problemas de Performance](#problemas-de-performance)
8. [Herramientas de Diagnóstico](#herramientas-de-diagnóstico)

## Diagnóstico General

### Verificación Inicial del Sistema

```bash
# Verificar estado de todos los pods de monitoreo
kubectl get pods -n monitoring

# Verificar servicios de monitoreo
kubectl get services -n monitoring

# Verificar estado de Kubernetes
kubectl cluster-info

# Verificar recursos del sistema
kubectl top nodes
kubectl top pods -n monitoring
```

### Comandos de Diagnóstico Rápido

```bash
# Script de verificación completa
./diagnose-microservices.sh

# Verificar conectividad de servicios
curl -f http://localhost:30090/api/v1/query?query=up
curl -f http://localhost:30030/api/health
curl -f http://localhost:30601/api/status
curl -f http://localhost:30920/_cluster/health
```

### Indicadores de Problemas Comunes

| Síntoma | Posible Causa | Acción Inmediata |
|---------|---------------|------------------|
| Pods en estado CrashLoopBackOff | Configuración incorrecta | Revisar logs del pod |
| Servicios no accesibles | Problemas de red/puerto | Verificar NodePorts |
| Métricas faltantes | Scraping fallido | Verificar targets Prometheus |
| Dashboards vacíos | Fuente de datos desconectada | Verificar conexión Grafana-Prometheus |
| Logs no aparecen | Pipeline ELK roto | Verificar Logstash y Elasticsearch |

## Problemas de Prometheus

### Problema: Prometheus no inicia

**Síntomas**:
- Pod prometheus en estado CrashLoopBackOff
- Error "permission denied" en logs
- Configuración inválida

**Diagnóstico**:
```bash
# Verificar logs del pod
kubectl logs -n monitoring deployment/prometheus

# Verificar configuración
kubectl get configmap prometheus-config -n monitoring -o yaml

# Verificar permisos de volumen
kubectl describe pod -n monitoring -l app=prometheus
```

**Soluciones**:

1. **Problema de permisos**:
```bash
# Verificar y corregir permisos de volumen
kubectl patch deployment prometheus -n monitoring -p '{"spec":{"template":{"spec":{"securityContext":{"fsGroup":65534}}}}}'
```

2. **Configuración inválida**:
```bash
# Validar configuración de Prometheus
kubectl exec -n monitoring deployment/prometheus -- promtool check config /etc/prometheus/prometheus.yml

# Actualizar configuración si es necesario
kubectl apply -f monitoring/prometheus/prometheus-config.yaml
```

3. **Recursos insuficientes**:
```bash
# Aumentar límites de recursos
kubectl patch deployment prometheus -n monitoring -p '{"spec":{"template":{"spec":{"containers":[{"name":"prometheus","resources":{"limits":{"memory":"2Gi","cpu":"1000m"}}}]}}}}'
```

### Problema: Targets no se descubren

**Síntomas**:
- Targets aparecen como "down" en Prometheus UI
- Métricas de servicios faltantes
- Errores de scraping en logs

**Diagnóstico**:
```bash
# Verificar targets en Prometheus UI
open http://localhost:30090/targets

# Verificar configuración de service discovery
kubectl get servicemonitor -n monitoring

# Verificar endpoints de servicios
kubectl get endpoints -n ecommerce
```

**Soluciones**:

1. **Servicios no exponen métricas**:
```bash
# Verificar que los servicios expongan /actuator/prometheus
curl http://localhost:30082/actuator/prometheus
curl http://localhost:30083/actuator/prometheus
```

2. **Configuración de ServiceMonitor incorrecta**:
```yaml
# Ejemplo de ServiceMonitor correcto
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: microservices-monitor
  namespace: monitoring
spec:
  selector:
    matchLabels:
      monitoring: enabled
  endpoints:
  - port: http
    path: /actuator/prometheus
```

3. **Problemas de red**:
```bash
# Verificar conectividad desde Prometheus
kubectl exec -n monitoring deployment/prometheus -- wget -qO- http://user-service.ecommerce:8081/actuator/prometheus
```

### Problema: Alto uso de memoria en Prometheus

**Síntomas**:
- Pod Prometheus reiniciándose por OOMKilled
- Consultas lentas
- Alto uso de memoria en métricas

**Diagnóstico**:
```bash
# Verificar uso de memoria
kubectl top pod -n monitoring prometheus-*

# Verificar métricas de Prometheus sobre sí mismo
curl "http://localhost:30090/api/v1/query?query=prometheus_tsdb_symbol_table_size_bytes"
```

**Soluciones**:

1. **Ajustar retención de datos**:
```yaml
# En deployment de Prometheus
args:
  - '--storage.tsdb.retention.time=7d'
  - '--storage.tsdb.retention.size=5GB'
```

2. **Optimizar configuración de scraping**:
```yaml
# Reducir frecuencia de scraping
scrape_configs:
  - job_name: 'microservices'
    scrape_interval: 30s  # Aumentar de 15s a 30s
```

3. **Aumentar recursos**:
```yaml
resources:
  limits:
    memory: "4Gi"
    cpu: "2000m"
  requests:
    memory: "2Gi"
    cpu: "1000m"
```

## Problemas de Grafana

### Problema: Grafana no puede conectar a Prometheus

**Síntomas**:
- Dashboards muestran "No data"
- Error de conexión en data source
- Timeout en consultas

**Diagnóstico**:
```bash
# Verificar logs de Grafana
kubectl logs -n monitoring deployment/grafana

# Verificar configuración de data source
curl -u admin:admin http://localhost:30030/api/datasources
```

**Soluciones**:

1. **URL de Prometheus incorrecta**:
```bash
# Verificar que la URL sea correcta
# Debe ser: http://prometheus:9090 (interno) o http://localhost:30090 (externo)

# Actualizar data source
curl -X PUT -H "Content-Type: application/json" -u admin:admin \
  http://localhost:30030/api/datasources/1 \
  -d '{"url":"http://prometheus:9090","access":"proxy"}'
```

2. **Problemas de DNS interno**:
```bash
# Verificar resolución DNS desde Grafana
kubectl exec -n monitoring deployment/grafana -- nslookup prometheus
```

3. **Configuración de red**:
```bash
# Verificar conectividad
kubectl exec -n monitoring deployment/grafana -- wget -qO- http://prometheus:9090/api/v1/label/__name__/values
```

### Problema: Dashboards no cargan datos

**Síntomas**:
- Paneles vacíos en dashboards
- Errores de consulta PromQL
- Timeouts en queries

**Diagnóstico**:
```bash
# Verificar consultas directamente en Prometheus
curl "http://localhost:30090/api/v1/query?query=up"

# Verificar logs de Grafana para errores de query
kubectl logs -n monitoring deployment/grafana | grep -i error
```

**Soluciones**:

1. **Consultas PromQL incorrectas**:
```promql
# Verificar que las métricas existan
up{job="microservices"}

# Ajustar time range en dashboard
# Usar relative time: "Last 1 hour" en lugar de absolute
```

2. **Problemas de tiempo**:
```bash
# Verificar sincronización de tiempo
kubectl exec -n monitoring deployment/grafana -- date
kubectl exec -n monitoring deployment/prometheus -- date
```

## Problemas de ELK Stack

### Problema: Elasticsearch no inicia

**Síntomas**:
- Pod elasticsearch en CrashLoopBackOff
- Errores de memoria virtual en logs
- Cluster health en estado red

**Diagnóstico**:
```bash
# Verificar logs de Elasticsearch
kubectl logs -n monitoring deployment/elasticsearch

# Verificar estado del cluster
curl http://localhost:30920/_cluster/health

# Verificar configuración
kubectl get configmap elasticsearch-config -n monitoring -o yaml
```

**Soluciones**:

1. **Problema de memoria virtual**:
```bash
# En el host (para desarrollo local)
sudo sysctl -w vm.max_map_count=262144

# Para persistir el cambio
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
```

2. **Recursos insuficientes**:
```yaml
# Aumentar recursos en deployment
resources:
  limits:
    memory: "2Gi"
    cpu: "1000m"
  requests:
    memory: "1Gi"
    cpu: "500m"
```

3. **Configuración de heap**:
```yaml
env:
- name: ES_JAVA_OPTS
  value: "-Xms1g -Xmx1g"
```

### Problema: Logstash no procesa logs

**Síntomas**:
- No aparecen logs en Elasticsearch
- Errores de parsing en Logstash
- Pipeline bloqueado

**Diagnóstico**:
```bash
# Verificar logs de Logstash
kubectl logs -n monitoring deployment/logstash

# Verificar configuración del pipeline
kubectl get configmap logstash-config -n monitoring -o yaml

# Verificar conectividad a Elasticsearch
kubectl exec -n monitoring deployment/logstash -- curl http://elasticsearch:9200/_cluster/health
```

**Soluciones**:

1. **Configuración de pipeline incorrecta**:
```ruby
# Verificar sintaxis de configuración Logstash
input {
  tcp {
    port => 5000
    codec => json_lines
  }
}

filter {
  # Validar filtros grok
  if [message] =~ /^\d{4}-\d{2}-\d{2}/ {
    grok {
      match => { 
        "message" => "%{TIMESTAMP_ISO8601:timestamp} %{LOGLEVEL:level}" 
      }
    }
  }
}

output {
  elasticsearch {
    hosts => ["elasticsearch:9200"]
    index => "ecommerce-logs-%{+YYYY.MM.dd}"
  }
}
```

2. **Problemas de conectividad**:
```bash
# Verificar que Elasticsearch esté accesible
kubectl exec -n monitoring deployment/logstash -- telnet elasticsearch 9200
```

3. **Problemas de parsing**:
```bash
# Habilitar debug en Logstash
kubectl patch deployment logstash -n monitoring -p '{"spec":{"template":{"spec":{"containers":[{"name":"logstash","env":[{"name":"LOG_LEVEL","value":"DEBUG"}]}]}}}}'
```

### Problema: Kibana no puede conectar a Elasticsearch

**Síntomas**:
- Kibana muestra "Kibana server is not ready yet"
- Error de conexión a Elasticsearch
- Timeout en inicialización

**Diagnóstico**:
```bash
# Verificar logs de Kibana
kubectl logs -n monitoring deployment/kibana

# Verificar configuración
kubectl get configmap kibana-config -n monitoring -o yaml

# Verificar estado de Elasticsearch
curl http://localhost:30920/_cluster/health
```

**Soluciones**:

1. **URL de Elasticsearch incorrecta**:
```yaml
# En configuración de Kibana
elasticsearch.hosts: ["http://elasticsearch:9200"]
```

2. **Elasticsearch no está listo**:
```bash
# Esperar a que Elasticsearch esté en estado green
kubectl wait --for=condition=ready pod -l app=elasticsearch -n monitoring --timeout=300s
```

3. **Problemas de índices**:
```bash
# Verificar índices en Elasticsearch
curl http://localhost:30920/_cat/indices?v

# Crear index pattern manualmente si es necesario
curl -X POST "http://localhost:30601/api/saved_objects/index-pattern/ecommerce-logs" \
  -H "Content-Type: application/json" \
  -H "kbn-xsrf: true" \
  -d '{"attributes":{"title":"ecommerce-logs-*","timeFieldName":"@timestamp"}}'
```

## Problemas de Zipkin

### Problema: Zipkin no recibe trazas

**Síntomas**:
- No aparecen trazas en Zipkin UI
- Servicios no reportan spans
- Errores de conectividad en logs de aplicación

**Diagnóstico**:
```bash
# Verificar logs de Zipkin
kubectl logs -n monitoring deployment/zipkin

# Verificar configuración de tracing en servicios
kubectl exec -n ecommerce deployment/user-service -- curl http://localhost:8081/actuator/health

# Verificar conectividad a Zipkin
curl http://localhost:30411/api/v2/services
```

**Soluciones**:

1. **Configuración de tracing incorrecta en servicios**:
```yaml
# En application.yml de cada servicio
management:
  tracing:
    sampling:
      probability: 1.0
  zipkin:
    tracing:
      endpoint: http://zipkin:9411/api/v2/spans
```

2. **Zipkin no accesible desde servicios**:
```bash
# Verificar conectividad desde servicios
kubectl exec -n ecommerce deployment/user-service -- telnet zipkin.monitoring 9411
```

3. **Problemas de sampling**:
```yaml
# Aumentar probabilidad de sampling
spring:
  sleuth:
    sampler:
      probability: 1.0  # 100% para desarrollo
```

## Problemas de Conectividad

### Problema: NodePorts no accesibles

**Síntomas**:
- Servicios no responden en puertos NodePort
- Connection refused en localhost
- Timeouts en conexiones

**Diagnóstico**:
```bash
# Verificar servicios NodePort
kubectl get services -n monitoring -o wide

# Verificar que Minikube esté funcionando
minikube status

# Verificar IP de Minikube
minikube ip
```

**Soluciones**:

1. **Minikube no está funcionando**:
```bash
# Reiniciar Minikube
minikube stop
minikube start

# Verificar túnel (si es necesario)
minikube tunnel
```

2. **Puertos no configurados correctamente**:
```bash
# Verificar configuración de NodePort
kubectl get service prometheus -n monitoring -o yaml

# Reconfigurar si es necesario
kubectl patch service prometheus -n monitoring -p '{"spec":{"type":"NodePort","ports":[{"port":9090,"nodePort":30090}]}}'
```

3. **Firewall bloqueando puertos**:
```bash
# En macOS, verificar que no haya restricciones
sudo pfctl -sr | grep 30090

# En Linux, verificar iptables
sudo iptables -L | grep 30090
```

### Problema: Comunicación inter-servicios falla

**Síntomas**:
- Servicios no pueden comunicarse entre sí
- Errores de DNS resolution
- Timeouts en llamadas internas

**Diagnóstico**:
```bash
# Verificar DNS interno
kubectl exec -n ecommerce deployment/user-service -- nslookup product-service

# Verificar conectividad entre servicios
kubectl exec -n ecommerce deployment/user-service -- curl http://product-service:8082/actuator/health

# Verificar políticas de red
kubectl get networkpolicies -A
```

**Soluciones**:

1. **Problemas de DNS**:
```bash
# Verificar CoreDNS
kubectl get pods -n kube-system | grep coredns

# Reiniciar CoreDNS si es necesario
kubectl rollout restart deployment/coredns -n kube-system
```

2. **Servicios mal configurados**:
```bash
# Verificar que los servicios tengan los selectores correctos
kubectl get service user-service -n ecommerce -o yaml
```

## Problemas de Performance

### Problema: Consultas lentas en Prometheus

**Síntomas**:
- Dashboards tardan en cargar
- Timeouts en queries complejas
- Alto uso de CPU en Prometheus

**Diagnóstico**:
```bash
# Verificar métricas de performance de Prometheus
curl "http://localhost:30090/api/v1/query?query=prometheus_engine_query_duration_seconds"

# Verificar número de series temporales
curl "http://localhost:30090/api/v1/query?query=prometheus_tsdb_symbol_table_size_bytes"
```

**Soluciones**:

1. **Optimizar consultas PromQL**:
```promql
# Evitar consultas muy amplias
# Malo: rate(http_requests_total[5m])
# Bueno: rate(http_requests_total{job="user-service"}[5m])

# Usar recording rules para consultas complejas
groups:
  - name: microservices.rules
    rules:
    - record: microservices:request_rate
      expr: sum(rate(http_requests_total[5m])) by (service)
```

2. **Ajustar configuración de Prometheus**:
```yaml
# Aumentar timeout de queries
global:
  evaluation_interval: 30s
  scrape_timeout: 10s
```

### Problema: Alto uso de recursos en ELK Stack

**Síntomas**:
- Pods de ELK consumiendo mucha memoria/CPU
- Elasticsearch lento en consultas
- Logstash con backlog de eventos

**Diagnóstico**:
```bash
# Verificar uso de recursos
kubectl top pods -n monitoring

# Verificar estado de Elasticsearch
curl "http://localhost:30920/_cluster/stats"

# Verificar throughput de Logstash
curl "http://localhost:30580/_node/stats"
```

**Soluciones**:

1. **Optimizar configuración de Elasticsearch**:
```yaml
# Ajustar heap size
env:
- name: ES_JAVA_OPTS
  value: "-Xms2g -Xmx2g"

# Configurar índices con menos réplicas
template:
  settings:
    number_of_replicas: 0
    number_of_shards: 1
```

2. **Optimizar Logstash**:
```ruby
# Aumentar workers y batch size
pipeline:
  workers: 4
  batch:
    size: 1000
    delay: 50
```

## Herramientas de Diagnóstico

### Scripts de Diagnóstico Automatizado

```bash
# Script principal de diagnóstico
./diagnose-microservices.sh

# Verificación específica de monitoreo
./monitoring/verify-monitoring.sh

# Pruebas de conectividad
./monitoring/test-connectivity.sh
```

### Comandos de Verificación Rápida

```bash
# Verificación completa del stack de monitoreo
kubectl get all -n monitoring

# Verificación de salud de todos los componentes
curl -f http://localhost:30090/-/healthy  # Prometheus
curl -f http://localhost:30030/api/health # Grafana
curl -f http://localhost:30920/_cluster/health # Elasticsearch
curl -f http://localhost:30601/api/status # Kibana
curl -f http://localhost:30411/health     # Zipkin
```

### Logs Centralizados para Troubleshooting

```bash
# Obtener logs de todos los componentes de monitoreo
kubectl logs -n monitoring -l app=prometheus --tail=100
kubectl logs -n monitoring -l app=grafana --tail=100
kubectl logs -n monitoring -l app=elasticsearch --tail=100
kubectl logs -n monitoring -l app=logstash --tail=100
kubectl logs -n monitoring -l app=kibana --tail=100
kubectl logs -n monitoring -l app=zipkin --tail=100
```

### Métricas de Diagnóstico

```promql
# Verificar salud de servicios
up{job="microservices"}

# Verificar uso de recursos
container_memory_usage_bytes{namespace="monitoring"}
container_cpu_usage_seconds_total{namespace="monitoring"}

# Verificar errores en logs
increase(logback_events_total{level="error"}[5m])

# Verificar latencia de servicios
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

## Procedimientos de Escalación

### Nivel 1: Problemas Básicos
- Verificar estado de pods y servicios
- Revisar logs básicos
- Verificar conectividad de red
- Reiniciar componentes si es necesario

### Nivel 2: Problemas de Configuración
- Analizar configuraciones de componentes
- Verificar recursos y límites
- Revisar políticas de red
- Ajustar parámetros de performance

### Nivel 3: Problemas Complejos
- Análisis profundo de métricas
- Debugging de consultas y pipelines
- Optimización de recursos
- Escalado horizontal de componentes

### Contactos de Escalación
- **DevOps Team**: Para problemas de infraestructura
- **Platform Team**: Para problemas de Kubernetes
- **Application Team**: Para problemas de métricas de aplicación

## Conclusión

Esta guía proporciona un enfoque sistemático para resolver problemas en el stack de monitoreo. La clave está en seguir un proceso estructurado de diagnóstico, desde verificaciones básicas hasta análisis profundos, utilizando las herramientas y comandos apropiados para cada situación. 