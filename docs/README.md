# Documentación del Sistema E-commerce Microservices

## Resumen

Esta carpeta contiene la documentación técnica completa del sistema de microservicios E-commerce, incluyendo patrones de arquitectura, guías de troubleshooting y procedimientos operacionales.

## Estructura de Documentación

### Documentación de Arquitectura
- **[PATRONES_ARQUITECTURA.md](PATRONES_ARQUITECTURA.md)** - 14 patrones de diseño en la nube implementados

### Documentación de Monitoreo
- **[TROUBLESHOOTING_MONITOREO.md](TROUBLESHOOTING_MONITOREO.md)** - Guía completa de troubleshooting para el stack de monitoreo
- **[GUIA-ANALISIS-MONITOREO.md](GUIA-ANALISIS-MONITOREO.md)** - Análisis detallado del sistema de monitoreo
- **[MONITOREO-README.md](MONITOREO-README.md)** - Guía de configuración y uso del monitoreo

### Documentación Operacional
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Guía general de troubleshooting del sistema
- **[screenshots/](screenshots/)** - Capturas de pantalla y evidencias visuales

## Patrones de Arquitectura Implementados

El sistema implementa 14 patrones de diseño en la nube de nivel empresarial:

| Patrón | Estado | Componentes |
|--------|--------|-------------|
| Health Check Pattern | ✓ Completo | Spring Boot Actuator + Kubernetes Probes |
| Circuit Breaker Pattern | ✓ Completo | Resilience4j |
| Service Discovery Pattern | ✓ Completo | Eureka Server + Clients |
| API Gateway Pattern | ✓ Completo | Spring Cloud Gateway |
| Load Balancer Pattern | ✓ Completo | Spring Cloud LoadBalancer + Feign |
| Service Mesh/Proxy Pattern | ✓ Completo | Proxy Client Aggregator |
| Observability Pattern | ✓ Completo | Prometheus + Grafana + ELK + Zipkin |
| Configuration Management | ✓ Completo | Kubernetes ConfigMaps |
| Secrets Management | ✓ Completo | Kubernetes Secrets |
| Sidecar Pattern | ✓ Completo | Monitoring agents |
| Graceful Degradation | ✓ Completo | Circuit breakers con fallbacks |
| Monitoring & Alerting | ✓ Completo | Stack completo de observabilidad |
| Distributed Tracing | ✓ Completo | Zipkin + Spring Cloud Sleuth |
| Strangler Fig Pattern | ⚠ Parcial | API Gateway routing |

## Stack de Monitoreo

### Componentes Principales

1. **Prometheus** (Puerto 30090)
   - Recolección de métricas
   - Alerting rules
   - Service discovery

2. **Grafana** (Puerto 30030)
   - Dashboards interactivos
   - Visualización de métricas
   - Alerting

3. **ELK Stack**
   - **Elasticsearch** (Puerto 30920) - Almacenamiento de logs
   - **Logstash** (Puerto 30500/30580) - Procesamiento de logs
   - **Kibana** (Puerto 30601) - Visualización de logs

4. **Zipkin** (Puerto 30411)
   - Distributed tracing
   - Performance analysis
   - Service dependency mapping

### Métricas Clave

- **Disponibilidad**: Uptime de servicios > 99.5%
- **Performance**: P95 response time < 1000ms
- **Errores**: Error rate < 5%
- **Recursos**: CPU/Memory utilization < 80%

## Guías de Troubleshooting

### Problemas Comunes

1. **Pods en CrashLoopBackOff**
   - Verificar logs: `kubectl logs -n <namespace> <pod-name>`
   - Revisar configuración y recursos

2. **Servicios no accesibles**
   - Verificar NodePorts: `kubectl get services -n <namespace>`
   - Comprobar estado de Minikube: `minikube status`

3. **Métricas faltantes**
   - Verificar targets Prometheus: `http://localhost:30090/targets`
   - Revisar configuración de ServiceMonitor

4. **Dashboards vacíos**
   - Verificar conexión Grafana-Prometheus
   - Comprobar consultas PromQL

5. **Logs no aparecen**
   - Verificar pipeline ELK
   - Revisar configuración Logstash

### Comandos de Diagnóstico Rápido

```bash
# Verificación general del sistema
./diagnose-microservices.sh

# Estado de pods de monitoreo
kubectl get pods -n monitoring

# Conectividad de servicios
curl -f http://localhost:30090/api/v1/query?query=up
curl -f http://localhost:30030/api/health
curl -f http://localhost:30601/api/status
curl -f http://localhost:30920/_cluster/health
```

## Mejores Prácticas

### Monitoreo
- Implementar health checks profundos
- Configurar alertas proactivas
- Usar structured logging con correlation IDs
- Monitorear métricas de negocio además de técnicas

### Troubleshooting
- Seguir un enfoque sistemático de diagnóstico
- Documentar soluciones para problemas recurrentes
- Usar herramientas de diagnóstico automatizado
- Mantener logs centralizados para análisis

### Performance
- Optimizar consultas PromQL
- Ajustar retención de datos según necesidades
- Balancear frecuencia de scraping con overhead
- Implementar caching donde sea apropiado

## Recursos Adicionales

- **Prometheus Documentation**: https://prometheus.io/docs/
- **Grafana Documentation**: https://grafana.com/docs/
- **ELK Stack Documentation**: https://www.elastic.co/guide/
- **Zipkin Documentation**: https://zipkin.io/
- **Kubernetes Documentation**: https://kubernetes.io/docs/

## Contacto y Soporte

Para problemas específicos, consultar las guías de troubleshooting correspondientes o contactar al equipo de DevOps según los procedimientos de escalación definidos en la documentación.
