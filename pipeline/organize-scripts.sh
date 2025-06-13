#!/bin/bash

# ============================================================================
# SCRIPT DE ORGANIZACIÓN Y LIMPIEZA DE SCRIPTS
# ============================================================================
# Este script:
# 1. Identifica scripts esenciales vs duplicados/obsoletos
# 2. Mueve scripts principales a pipeline/
# 3. Archiva scripts obsoletos en archive/
# 4. Crea enlaces simbólicos para mantener compatibilidad
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Crear directorios de organización
mkdir -p "$PROJECT_ROOT/pipeline"
mkdir -p "$PROJECT_ROOT/archive"
mkdir -p "$PROJECT_ROOT/backup-$(date +%Y%m%d)"

echo "============================================================================"
echo " ORGANIZANDO Y LIMPIANDO SCRIPTS DEL PROYECTO"
echo "============================================================================"

# Scripts ESENCIALES que se mantienen en pipeline/
declare -A ESSENTIAL_SCRIPTS=(
    ["deploy-monitoring.sh"]="Despliegue del stack completo de monitoreo"
    ["generate-monitoring-data.sh"]="Generación de tráfico y datos de prueba"
    ["verify-monitoring.sh"]="Verificación del funcionamiento del monitoreo"
    ["DEPLOY_ALL_MICROSERVICES.sh"]="Despliegue de todos los microservicios"
    ["setup-jenkins.sh"]="Configuración de Jenkins"
    ["run-performance-tests-optimized.sh"]="Tests de performance optimizados"
)

# Scripts DUPLICADOS o OBSOLETOS que se archivan
declare -A OBSOLETE_SCRIPTS=(
    ["1-setup-completo.sh"]="Duplicado de setup-jenkins.sh"
    ["2-verificar-servicios.sh"]="Funcionalidad incluida en verify-monitoring.sh"
    ["3-pruebas-performance.sh"]="Reemplazado por run-performance-tests-optimized.sh"
    ["4-configurar-jenkins.sh"]="Funcionalidad incluida en setup-jenkins.sh"
    ["5-configurar-ambientes-e2e.sh"]="Específico de taller, no necesario"
    ["jenkins-setup.sh"]="Duplicado de setup-jenkins.sh"
    ["setup-jenkins-with-kubectl.sh"]="Variante de setup-jenkins.sh"
    ["restart-jenkins.sh"]="Funcionalidad básica de Docker"
    ["start-jenkins.sh"]="Funcionalidad básica de Docker"
    ["test-user-service.sh"]="Funcionalidad incluida en generate-monitoring-data.sh"
    ["VERIFICAR_FUNCIONAMIENTO.sh"]="Duplicado de verify-monitoring.sh"
    ["DIAGNOSTICO_RAPIDO.sh"]="Funcionalidad incluida en master pipeline"
    ["check-k8s-status.sh"]="Funcionalidad incluida en master pipeline"
    ["FIX_POD.sh"]="Script específico, no parte del pipeline principal"
    ["START.sh"]="Script obsoleto"
    ["expose-monitoring-terminal.sh"]="Reemplazado por funcionalidad en master pipeline"
)

# Documentos que se mantienen en docs/
declare -A DOCS_TO_ORGANIZE=(
    ["GUIA-ANALISIS-MONITOREO.md"]="docs/"
    ["MONITOREO-README.md"]="docs/"
    ["README-TALLER-2.md"]="docs/"
    ["README_TALLER_2.md"]="docs/"
    ["TALLER_2_OPTIMIZADO.md"]="docs/"
    ["JENKINS_SETUP_GUIDE.md"]="docs/"
    ["README_JENKINS_MVP.md"]="docs/"
    ["TROUBLESHOOTING.md"]="docs/"
    ["PIPELINE_DOCUMENTATION.md"]="docs/"
    ["USAR_TERMINAL_NATIVO.md"]="docs/"
)

echo ""
echo "📋 FASE 1: IDENTIFICANDO SCRIPTS..."

# Listar scripts encontrados
echo "Scripts esenciales encontrados:"
for script in "${!ESSENTIAL_SCRIPTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$script" ]; then
        echo "  ✅ $script - ${ESSENTIAL_SCRIPTS[$script]}"
    else
        echo "  ❌ $script - NO ENCONTRADO"
    fi
done

echo ""
echo "Scripts obsoletos encontrados:"
for script in "${!OBSOLETE_SCRIPTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$script" ]; then
        echo "  📦 $script - ${OBSOLETE_SCRIPTS[$script]}"
    fi
done

echo ""
echo "📋 FASE 2: CREANDO BACKUP COMPLETO..."

# Crear backup de todos los scripts antes de mover
for script in "${!ESSENTIAL_SCRIPTS[@]}" "${!OBSOLETE_SCRIPTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$script" ]; then
        cp "$PROJECT_ROOT/$script" "$PROJECT_ROOT/backup-$(date +%Y%m%d)/"
        echo "  Backed up: $script"
    fi
done

echo ""
echo "📋 FASE 3: MOVIENDO SCRIPTS ESENCIALES A PIPELINE/..."

# Mover scripts esenciales a pipeline/ y crear enlaces simbólicos
for script in "${!ESSENTIAL_SCRIPTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$script" ]; then
        # Mover a pipeline/
        mv "$PROJECT_ROOT/$script" "$PROJECT_ROOT/pipeline/"
        echo "  ✅ Movido: $script → pipeline/"
        
        # Crear enlace simbólico en la raíz para compatibilidad
        ln -sf "pipeline/$script" "$PROJECT_ROOT/$script"
        echo "    🔗 Enlace simbólico creado: $script"
    fi
done

echo ""
echo "📋 FASE 4: ARCHIVANDO SCRIPTS OBSOLETOS..."

# Mover scripts obsoletos a archive/
for script in "${!OBSOLETE_SCRIPTS[@]}"; do
    if [ -f "$PROJECT_ROOT/$script" ]; then
        mv "$PROJECT_ROOT/$script" "$PROJECT_ROOT/archive/"
        echo "  📦 Archivado: $script → archive/"
    fi
done

echo ""
echo "📋 FASE 5: ORGANIZANDO DOCUMENTACIÓN..."

# Crear directorio docs si no existe
mkdir -p "$PROJECT_ROOT/docs"

# Mover documentos a docs/
for doc in "${!DOCS_TO_ORGANIZE[@]}"; do
    if [ -f "$PROJECT_ROOT/$doc" ]; then
        mv "$PROJECT_ROOT/$doc" "$PROJECT_ROOT/docs/"
        echo "  📄 Movido: $doc → docs/"
    fi
done

echo ""
echo "📋 FASE 6: CREANDO ESTRUCTURA FINAL..."

# Crear README para pipeline/
cat > "$PROJECT_ROOT/pipeline/README.md" << 'EOF'
# Pipeline Scripts

Este directorio contiene los scripts principales del pipeline de despliegue:

## Scripts Principales

- `master-deployment-pipeline.sh` - Pipeline maestro que orquesta todo el despliegue
- `deploy-monitoring.sh` - Despliegue del stack completo de monitoreo  
- `generate-monitoring-data.sh` - Generación de tráfico y datos de prueba
- `verify-monitoring.sh` - Verificación del funcionamiento del monitoreo
- `DEPLOY_ALL_MICROSERVICES.sh` - Despliegue de todos los microservicios
- `setup-jenkins.sh` - Configuración de Jenkins
- `run-performance-tests-optimized.sh` - Tests de performance

## Uso

Para ejecutar el pipeline completo:
```bash
chmod +x pipeline/master-deployment-pipeline.sh
bash pipeline/master-deployment-pipeline.sh
```

## Enlaces Simbólicos

Los scripts mantienen enlaces simbólicos en la raíz del proyecto para compatibilidad con scripts existentes.
EOF

# Crear README para archive/
cat > "$PROJECT_ROOT/archive/README.md" << 'EOF'
# Scripts Archivados

Este directorio contiene scripts obsoletos o duplicados que fueron reemplazados por el pipeline principal.

Estos scripts se mantienen por referencia histórica pero no son parte del pipeline activo.

## Contenido

Scripts archivados de versiones anteriores del proyecto, incluyendo:
- Scripts duplicados de configuración
- Versiones obsoletas de scripts de testing
- Scripts específicos de talleres anteriores

## Restauración

Si necesitas restaurar algún script archivado:
```bash
cp archive/nombre-script.sh .
chmod +x nombre-script.sh
```
EOF

echo ""
echo "📋 FASE 7: VALIDANDO ESTRUCTURA FINAL..."

echo ""
echo "Estructura final en pipeline/:"
ls -la "$PROJECT_ROOT/pipeline/" | grep -E '\.(sh|md)$' | awk '{print "  " $9}'

echo ""
echo "Scripts archivados:"
ls -la "$PROJECT_ROOT/archive/" | grep -E '\.sh$' | awk '{print "  " $9}'

echo ""
echo "Documentación en docs/:"
ls -la "$PROJECT_ROOT/docs/" | grep -E '\.md$' | awk '{print "  " $9}'

echo ""
echo "============================================================================"
echo " ORGANIZACIÓN COMPLETADA"
echo "============================================================================"
echo ""
echo "RESUMEN:"
echo "  📁 Scripts esenciales: pipeline/"
echo "  📦 Scripts archivados: archive/"  
echo "  📄 Documentación: docs/"
echo "  💾 Backup completo: backup-$(date +%Y%m%d)/"
echo ""
echo "PRÓXIMO PASO:"
echo "  Ejecutar: bash pipeline/master-deployment-pipeline.sh"
echo "" 