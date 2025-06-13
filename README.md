# E-Commerce Microservices Platform

Sistema completo de microservicios e-commerce con monitoreo, CI/CD y observabilidad.

## 🚀 Inicio Rápido

**Un solo comando para desplegar todo:**

```bash
chmod +x ecommerce-manager.sh
./ecommerce-manager.sh
```

## 📦 Componentes

- **6 Microservicios**: user, product, order, payment, shipping, favourite
- **Jenkins CI/CD**: Pipeline automatizado
- **Monitoreo**: Prometheus + Grafana + ELK + Jaeger
- **Tests**: Performance y E2E automatizados

## 🏗️ Arquitectura

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Jenkins   │    │ Kubernetes  │    │ Monitoring  │
│    CI/CD    │───▶│Microservices│───▶│   Stack     │
└─────────────┘    └─────────────┘    └─────────────┘
```

## 📊 Monitoreo

- **Grafana**: Dashboards de métricas
- **Prometheus**: Recolección de métricas  
- **Kibana**: Análisis de logs
- **Jaeger**: Trazas distribuidas
- **AlertManager**: Gestión de alertas

## 📚 Documentación

- [Guía de Análisis de Monitoreo](docs/GUIA-ANALISIS-MONITOREO.md)
- [Documentación de Monitoreo](docs/MONITOREO-README.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)

## 🛠️ Scripts

Todos los scripts están organizados en `pipeline/`:

- `master-deployment-pipeline.sh` - Pipeline maestro
- `deploy-monitoring.sh` - Stack de monitoreo
- `setup-jenkins.sh` - Configuración de Jenkins
- `DEPLOY_ALL_MICROSERVICES.sh` - Despliegue de microservicios

## 🔧 Comandos Útiles

```bash
# Ver estado de servicios
kubectl get pods -A

# Ver IP de minikube
minikube ip

# Logs del sistema
tail -f ecommerce-manager.log
```

## 📋 Requisitos

- Docker
- Minikube
- kubectl
- curl

---

**Desarrollado para demostrar arquitectura de microservicios moderna con observabilidad completa.**
