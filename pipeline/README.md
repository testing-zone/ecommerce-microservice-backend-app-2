# Pipeline Scripts

Scripts organizados del sistema de despliegue:

## Scripts Principales

- `master-deployment-pipeline.sh` - Orquesta todo el despliegue
- `organize-scripts.sh` - Organiza y limpia el proyecto
- `clean-repository.sh` - Limpieza completa del repositorio

## Scripts de Componentes

- `deploy-monitoring.sh` - Stack completo de monitoreo
- `generate-monitoring-data.sh` - Generación de tráfico y datos
- `verify-monitoring.sh` - Verificación de funcionamiento
- `DEPLOY_ALL_MICROSERVICES.sh` - Despliegue de microservicios
- `setup-jenkins.sh` - Configuración de Jenkins
- `run-performance-tests-optimized.sh` - Tests de performance

## Uso

El punto de entrada principal es `ecommerce-manager.sh` en la raíz del proyecto.
