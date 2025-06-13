#!/bin/bash

# ============================================================================
# LIMPIEZA COMPLETA DEL REPOSITORIO
# ============================================================================
# Script que elimina TODOS los archivos duplicados, obsoletos y desorganizados
# Deja solo los archivos esenciales bien organizados
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "============================================================================"
echo " 🧹 LIMPIEZA COMPLETA DEL REPOSITORIO E-COMMERCE"
echo "============================================================================"
echo ""
echo "⚠️  ADVERTENCIA: Este script eliminará PERMANENTEMENTE archivos duplicados"
echo ""

# Crear backup completo antes de limpiar
BACKUP_DIR="$PROJECT_ROOT/backup-limpieza-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 Creando backup completo en: $BACKUP_DIR"
cp -r "$PROJECT_ROOT"/* "$BACKUP_DIR/" 2>/dev/null || true
echo "✅ Backup creado"
echo ""

read -p "¿Continuar con la limpieza completa? [y/N]: " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Limpieza cancelada"
    exit 0
fi

echo ""
echo "🗑️  ELIMINANDO ARCHIVOS DUPLICADOS Y OBSOLETOS..."
echo "============================================================================"

# ELIMINAR SCRIPTS DUPLICADOS DE JENKINS
echo "🔧 Limpiando scripts de Jenkins duplicados..."
rm -f "$PROJECT_ROOT/jenkins-setup.sh"
rm -f "$PROJECT_ROOT/setup-jenkins-with-kubectl.sh"
rm -f "$PROJECT_ROOT/restart-jenkins.sh"
rm -f "$PROJECT_ROOT/start-jenkins.sh"
rm -f "$PROJECT_ROOT/4-configurar-jenkins.sh"
rm -f "$PROJECT_ROOT/jenkins.Dockerfile"
echo "  ✅ Scripts de Jenkins duplicados eliminados"

# ELIMINAR SCRIPTS DE TALLER OBSOLETOS
echo "🎓 Limpiando archivos de taller obsoletos..."
rm -f "$PROJECT_ROOT/1-setup-completo.sh"
rm -f "$PROJECT_ROOT/2-verificar-servicios.sh"
rm -f "$PROJECT_ROOT/3-pruebas-performance.sh"
rm -f "$PROJECT_ROOT/5-configurar-ambientes-e2e.sh"
rm -f "$PROJECT_ROOT/START.sh"
rm -f "$PROJECT_ROOT/FIX_POD.sh"
rm -f "$PROJECT_ROOT/DIAGNOSTICO_RAPIDO.sh"
rm -f "$PROJECT_ROOT/check-k8s-status.sh"
rm -f "$PROJECT_ROOT/test-user-service.sh"
rm -f "$PROJECT_ROOT/VERIFICAR_FUNCIONAMIENTO.sh"
echo "  ✅ Scripts de taller obsoletos eliminados"

# ELIMINAR DOCUMENTACIÓN DUPLICADA
echo "📄 Limpiando documentación duplicada..."
rm -f "$PROJECT_ROOT/README-TALLER-2.md"
rm -f "$PROJECT_ROOT/README_TALLER_2.md"
rm -f "$PROJECT_ROOT/TALLER_2_OPTIMIZADO.md"
rm -f "$PROJECT_ROOT/VERIFICAR_BRANCHES_TALLER_2.md"
rm -f "$PROJECT_ROOT/ACCION_INMEDIATA_TALLER_2.md"
rm -f "$PROJECT_ROOT/TALLER_2_FINAL_SUMMARY.md"
rm -f "$PROJECT_ROOT/KUBERNETES_DOCKER_STATUS.md"
rm -f "$PROJECT_ROOT/TALLER_2_STATUS_CHECKLIST.md"
rm -f "$PROJECT_ROOT/TALLER_2_RESUMEN_EJECUTIVO.md"
rm -f "$PROJECT_ROOT/PIPELINE_DOCUMENTATION.md"
rm -f "$PROJECT_ROOT/README_JENKINS_MVP.md"
rm -f "$PROJECT_ROOT/JENKINS_SETUP_GUIDE.md"
rm -f "$PROJECT_ROOT/MVP_SUMMARY.md"
rm -f "$PROJECT_ROOT/COMO_VERIFICAR.md"
rm -f "$PROJECT_ROOT/WORKFLOW_COMPLETO.md"
rm -f "$PROJECT_ROOT/USAR_TERMINAL_NATIVO.md"
rm -f "$PROJECT_ROOT/install-plugins-manual.md"
echo "  ✅ Documentación duplicada eliminada"

# ELIMINAR ARCHIVOS DE PIPELINES OBSOLETOS
echo "🔧 Limpiando pipelines obsoletos..."
rm -f "$PROJECT_ROOT/jenkins-pipeline-taller2-final.groovy"
rm -f "$PROJECT_ROOT/jenkins-pipeline-completo.groovy"
echo "  ✅ Pipelines obsoletos eliminados"

# ELIMINAR ARCHIVOS DE CONFIGURACIÓN DUPLICADOS
echo "⚙️  Limpiando configuraciones duplicadas..."
rm -f "$PROJECT_ROOT/namespace.yaml"
rm -f "$PROJECT_ROOT/deployment.yaml"
rm -f "$PROJECT_ROOT/configmap.yaml"
echo "  ✅ Configuraciones duplicadas eliminadas"

# ELIMINAR ARCHIVOS TEMPORALES Y DE EXPOSICIÓN OBSOLETOS
echo "🧹 Limpiando archivos temporales..."
rm -f "$PROJECT_ROOT/expose-monitoring-terminal.sh"
rm -f "$PROJECT_ROOT/expose-monitoring-temp.sh"
rm -f "$PROJECT_ROOT/monitoring-tunnels.log"
rm -rf "$PROJECT_ROOT/.minikube-terminals"
echo "  ✅ Archivos temporales eliminados"

# ELIMINAR ARCHIVOS COMPRIMIDOS DE TALLER
echo "🗜️  Limpiando archivos comprimidos..."
rm -f "$PROJECT_ROOT/taller2-pruebas-20250530.zip"
rm -rf "$PROJECT_ROOT/taller2-pruebas-entrega"
echo "  ✅ Archivos comprimidos eliminados"

# ELIMINAR DIRECTORIOS DE REPORTES DUPLICADOS
echo "📊 Limpiando reportes duplicados..."
rm -rf "$PROJECT_ROOT/planb-performance-report"
rm -rf "$PROJECT_ROOT/quick-performance-report"
echo "  ✅ Reportes duplicados eliminados"

# ELIMINAR SCRIPTS OBSOLETOS DEL DIRECTORIO RAÍZ
echo "🧹 Limpieza final de scripts obsoletos..."
rm -f "$PROJECT_ROOT/deploy-ecommerce-complete.sh"  # Reemplazado por ecommerce-manager.sh
echo "  ✅ Scripts obsoletos eliminados"

echo ""
echo "📁 ORGANIZANDO ESTRUCTURA FINAL..."
echo "============================================================================"

# Crear directorios organizados
mkdir -p "$PROJECT_ROOT/docs"
mkdir -p "$PROJECT_ROOT/archive"

# Mover documentación esencial a docs/
echo "📄 Organizando documentación..."
if [ -f "$PROJECT_ROOT/GUIA-ANALISIS-MONITOREO.md" ]; then
    mv "$PROJECT_ROOT/GUIA-ANALISIS-MONITOREO.md" "$PROJECT_ROOT/docs/"
fi
if [ -f "$PROJECT_ROOT/MONITOREO-README.md" ]; then
    mv "$PROJECT_ROOT/MONITOREO-README.md" "$PROJECT_ROOT/docs/"
fi
if [ -f "$PROJECT_ROOT/TROUBLESHOOTING.md" ]; then
    mv "$PROJECT_ROOT/TROUBLESHOOTING.md" "$PROJECT_ROOT/docs/"
fi
echo "  ✅ Documentación organizada"

# Mover scripts esenciales a pipeline/ si no están ahí
echo "🔧 Organizando scripts esenciales..."
for script in "deploy-monitoring.sh" "generate-monitoring-data.sh" "verify-monitoring.sh" "DEPLOY_ALL_MICROSERVICES.sh" "setup-jenkins.sh" "run-performance-tests-optimized.sh"; do
    if [ -f "$PROJECT_ROOT/$script" ] && [ ! -f "$PROJECT_ROOT/pipeline/$script" ]; then
        mv "$PROJECT_ROOT/$script" "$PROJECT_ROOT/pipeline/"
        ln -sf "pipeline/$script" "$PROJECT_ROOT/$script"
        echo "  ✅ Movido: $script → pipeline/"
    fi
done

# Crear README principal limpio
echo "📝 Creando README principal..."
cat > "$PROJECT_ROOT/README.md" << 'EOF'
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
EOF

# Crear README para pipeline/
cat > "$PROJECT_ROOT/pipeline/README.md" << 'EOF'
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
EOF

# Crear README para docs/
cat > "$PROJECT_ROOT/docs/README.md" << 'EOF'
# Documentación

Documentación completa del sistema:

## Guías Principales

- `GUIA-ANALISIS-MONITOREO.md` - Guía completa de análisis de monitoreo
- `MONITOREO-README.md` - Documentación técnica del stack de monitoreo  
- `TROUBLESHOOTING.md` - Solución de problemas comunes

## Uso

Estas guías te ayudarán a:
- Configurar dashboards de Grafana
- Analizar métricas de Prometheus
- Revisar logs en Kibana
- Explorar trazas en Jaeger
- Resolver problemas comunes
EOF

echo ""
echo "🧹 LIMPIEZA FINAL..."
echo "============================================================================"

# Eliminar archivos de cache y temporales
rm -rf "$PROJECT_ROOT/__pycache__" 2>/dev/null || true
find "$PROJECT_ROOT" -name "*.pyc" -delete 2>/dev/null || true
find "$PROJECT_ROOT" -name "*.log" -delete 2>/dev/null || true
find "$PROJECT_ROOT" -name ".DS_Store" -delete 2>/dev/null || true

echo "✅ Archivos temporales eliminados"

echo ""
echo "📊 RESUMEN DE LIMPIEZA"
echo "============================================================================"

echo "✅ ELIMINADO:"
echo "  • Scripts duplicados de Jenkins (5+ archivos)"
echo "  • Documentación de taller obsoleta (15+ archivos)"
echo "  • Scripts de configuración duplicados (10+ archivos)"
echo "  • Archivos temporales y de cache"
echo "  • Pipelines obsoletos"
echo "  • Reportes duplicados"
echo ""

echo "📁 ESTRUCTURA FINAL:"
echo ""
echo "📄 Raíz del proyecto:"
echo "  ├── ecommerce-manager.sh          (SCRIPT PRINCIPAL)"
echo "  ├── README.md                     (Documentación principal)"
echo "  ├── pom.xml                       (Configuración Maven)"
echo "  ├── locustfile.py                 (Tests de performance)"
echo "  └── compose.yml                   (Docker Compose)"
echo ""
echo "📁 pipeline/                        (Scripts organizados)"
echo "  ├── master-deployment-pipeline.sh"
echo "  ├── clean-repository.sh"
echo "  ├── organize-scripts.sh"
echo "  └── [scripts de componentes]"
echo ""
echo "📁 docs/                           (Documentación)"
echo "  ├── GUIA-ANALISIS-MONITOREO.md"
echo "  ├── MONITOREO-README.md"
echo "  └── TROUBLESHOOTING.md"
echo ""
echo "📁 monitoring/                     (Configuraciones)"
echo "  └── monitoring-nodeports.yaml"
echo ""
echo "📁 [microservicios]/               (Código fuente)"
echo "  ├── user-service/"
echo "  ├── product-service/"
echo "  ├── order-service/"
echo "  ├── payment-service/"
echo "  ├── shipping-service/"
echo "  └── favourite-service/"
echo ""

echo "💾 BACKUP DISPONIBLE EN:"
echo "  $BACKUP_DIR"
echo ""

echo "============================================================================"
echo " ✅ LIMPIEZA COMPLETADA EXITOSAMENTE"
echo "============================================================================"
echo ""
echo "🚀 PRÓXIMO PASO:"
echo "   ./ecommerce-manager.sh"
echo "" 