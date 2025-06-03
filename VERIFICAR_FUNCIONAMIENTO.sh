#!/bin/bash

echo "🔍 VERIFICANDO QUE TODO FUNCIONA - TALLER 2"
echo "==========================================="
echo ""

# Variables para conteo
CHECKS_TOTAL=0
CHECKS_PASSED=0

check_step() {
    local description="$1"
    local command="$2"
    local expected="$3"
    
    CHECKS_TOTAL=$((CHECKS_TOTAL + 1))
    echo "[$CHECKS_TOTAL] 🔍 $description"
    
    if eval "$command" >/dev/null 2>&1; then
        echo "   ✅ PASS: $expected"
        CHECKS_PASSED=$((CHECKS_PASSED + 1))
    else
        echo "   ❌ FAIL: $expected"
    fi
    echo ""
}

echo "📋 VERIFICACIONES DE INFRAESTRUCTURA:"
echo "===================================="

check_step "Docker disponible" "command -v docker" "Docker command found"
check_step "Docker funcionando" "docker info" "Docker daemon responding"
check_step "kubectl disponible" "command -v kubectl" "kubectl command found"
check_step "minikube disponible" "command -v minikube" "minikube command found"
check_step "minikube corriendo" "minikube status" "minikube is running"

echo "📋 VERIFICACIONES DE KUBERNETES:"
echo "================================"

check_step "Cluster accesible" "kubectl cluster-info" "Kubernetes cluster is running"
check_step "Namespace ecommerce existe" "kubectl get namespace ecommerce" "ecommerce namespace found"
check_step "Hay pods en ecommerce" "kubectl get pods -n ecommerce --no-headers | wc -l | grep -v '^0$'" "pods are deployed"

echo "📋 VERIFICACIONES DE SERVICIO:"
echo "=============================="

# Ver estado actual de pods
echo "📊 ESTADO ACTUAL DE PODS:"
kubectl get pods -n ecommerce 2>/dev/null || echo "   No hay pods o namespace no accesible"
echo ""

# Ver servicios
echo "🌐 SERVICIOS DISPONIBLES:"
kubectl get services -n ecommerce 2>/dev/null || echo "   No hay servicios o namespace no accesible"
echo ""

# Verificar si hay algún pod running
if kubectl get pods -n ecommerce 2>/dev/null | grep -q "Running"; then
    echo "✅ HAY PODS FUNCIONANDO"
    CHECKS_PASSED=$((CHECKS_PASSED + 1))
    
    # Intentar obtener URL del servicio
    echo ""
    echo "🌐 PROBANDO CONECTIVIDAD:"
    
    # Buscar cualquier servicio disponible
    SERVICE_NAME=$(kubectl get services -n ecommerce --no-headers 2>/dev/null | head -1 | awk '{print $1}')
    
    if [[ -n "$SERVICE_NAME" ]]; then
        echo "   Servicio encontrado: $SERVICE_NAME"
        
        # Intentar obtener URL
        SERVICE_URL=$(minikube service $SERVICE_NAME -n ecommerce --url 2>/dev/null | head -1)
        
        if [[ -n "$SERVICE_URL" ]]; then
            echo "   URL del servicio: $SERVICE_URL"
            
            # Probar conectividad
            if curl -s --connect-timeout 5 "$SERVICE_URL" >/dev/null 2>&1; then
                echo "   ✅ SERVICIO RESPONDE"
                CHECKS_PASSED=$((CHECKS_PASSED + 1))
                
                echo ""
                echo "🧪 RESPUESTA DEL SERVICIO:"
                curl -s --connect-timeout 5 "$SERVICE_URL" | head -c 200
                echo ""
            else
                echo "   ⚠️  Servicio no responde (puede estar iniciando)"
            fi
        else
            echo "   ⚠️  No se pudo obtener URL del servicio"
        fi
    else
        echo "   ⚠️  No hay servicios desplegados"
    fi
else
    echo "❌ NO HAY PODS FUNCIONANDO"
    echo ""
    echo "💡 NECESITAS EJECUTAR:"
    echo "   ./FIX_POD.sh"
fi

CHECKS_TOTAL=$((CHECKS_TOTAL + 2))  # Agregamos las verificaciones de pods y servicio

echo ""
echo "📊 RESUMEN FINAL:"
echo "================"
echo "✅ Verificaciones pasadas: $CHECKS_PASSED/$CHECKS_TOTAL"

if [ $CHECKS_PASSED -eq $CHECKS_TOTAL ]; then
    echo "🎉 TODO FUNCIONA PERFECTAMENTE"
    echo ""
    echo "📸 LISTO PARA SCREENSHOTS:"
    echo "   kubectl get pods -n ecommerce"
    echo "   kubectl get services -n ecommerce" 
    echo "   minikube dashboard"
    echo "   curl $SERVICE_URL"
elif [ $CHECKS_PASSED -gt $((CHECKS_TOTAL / 2)) ]; then
    echo "⚠️  MAYORMENTE FUNCIONAL - solo ajustes menores"
    echo ""
    echo "🔧 PARA ARREGLAR:"
    echo "   ./FIX_POD.sh"
else
    echo "❌ NECESITA CONFIGURACIÓN"
    echo ""
    echo "🔧 PARA CONFIGURAR:"
    echo "   ./TALLER_2_MINIMO.sh → opción B (Kubernetes)"
fi

echo ""
echo "💡 COMANDOS ÚTILES:"
echo "   Ver pods: kubectl get pods -n ecommerce"
echo "   Ver logs: kubectl logs -n ecommerce [pod-name]"
echo "   Dashboard: minikube dashboard" 