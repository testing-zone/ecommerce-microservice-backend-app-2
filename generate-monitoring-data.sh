#!/bin/bash

echo "🎯 GENERANDO DATOS PARA MONITOREO"
echo "================================="
echo ""
echo "📋 Este script generará tráfico y datos para verificar:"
echo "   • Métricas en Prometheus"
echo "   • Logs en ELK Stack"
echo "   • Trazas en Jaeger"
echo "   • Alertas en AlertManager"
echo ""

# Obtener IP de minikube
MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "localhost")

# Función para hacer peticiones HTTP a los microservicios
make_requests() {
    local service=$1
    local port=$2
    local endpoint=${3:-"/actuator/health"}
    local count=${4:-10}
    
    echo "📡 Generando $count peticiones a $service..."
    
    for i in $(seq 1 $count); do
        response=$(curl -s -w "%{http_code}" "http://${MINIKUBE_IP}:$port$endpoint" 2>/dev/null || echo "000")
        
        if [[ $response == *"200"* ]] || [[ $response == *"UP"* ]]; then
            echo "✅ Petición $i/$count a $service: OK"
        else
            echo "⚠️  Petición $i/$count a $service: Error (response: ${response:0:50}...)"
        fi
        
        # Pequeña pausa entre peticiones
        sleep 0.5
    done
}

# Función para generar errores controlados
generate_errors() {
    local service=$1
    local port=$2
    local count=${3:-5}
    
    echo "🚨 Generando $count errores controlados en $service..."
    
    for i in $(seq 1 $count); do
        # Intentar acceder a un endpoint que no existe para generar 404s
        curl -s "http://${MINIKUBE_IP}:$port/non-existent-endpoint" &>/dev/null
        echo "❌ Error $i/$count generado en $service (404)"
        sleep 1
    done
}

echo "🚀 1. VERIFICANDO CONECTIVIDAD CON MICROSERVICIOS..."

# Verificar si minikube tunnel está corriendo
if ! pgrep -f "minikube tunnel" > /dev/null; then
    echo "⚠️  minikube tunnel no está corriendo. Los NodePorts podrían no ser accesibles."
    echo "💡 Ejecuta en otra terminal: minikube tunnel"
fi

# Mapeo de servicios y puertos (usando NodePorts del setup original)
SERVICES=(
    "user-service:30087:/actuator/health"
    "product-service:30082:/actuator/health"
    "order-service:30083:/actuator/health"
    "payment-service:30084:/actuator/health"
    "shipping-service:30085:/actuator/health"
    "favourite-service:30086:/actuator/health"
)

echo ""
echo "📊 2. GENERANDO TRÁFICO NORMAL EN MICROSERVICIOS..."

for service_config in "${SERVICES[@]}"; do
    IFS=':' read -r service port endpoint <<< "$service_config"
    
    echo ""
    echo "🔄 Testeando $service en puerto $port..."
    
    # Verificar conectividad básica
    if curl -s --max-time 5 "http://${MINIKUBE_IP}:$port$endpoint" &>/dev/null; then
        echo "✅ $service está respondiendo"
        make_requests "$service" "$port" "$endpoint" 15
    else
        echo "❌ $service no está accesible en $port"
        echo "💡 Verificando con port-forward..."
        
        # Intentar con port-forward como fallback
        kubectl port-forward "svc/$service" "$port:$port" -n ecommerce &>/dev/null &
        local pf_pid=$!
        sleep 3
        
        if curl -s --max-time 5 "http://localhost:$port$endpoint" &>/dev/null; then
            echo "✅ $service responde via port-forward"
            make_requests "$service" "$port" "$endpoint" 10
        else
            echo "❌ $service no responde ni con port-forward"
        fi
        
        kill $pf_pid 2>/dev/null
    fi
done

echo ""
echo "🚨 3. GENERANDO ERRORES PARA ALERTAS..."

for service_config in "${SERVICES[@]}"; do
    IFS=':' read -r service port endpoint <<< "$service_config"
    generate_errors "$service" "$port" 3
done

echo ""
echo "📈 4. VERIFICANDO MÉTRICAS EN PROMETHEUS..."

# Verificar conectividad con Prometheus
echo "🔍 Verificando que Prometheus esté recolectando métricas..."

if curl -s "http://${MINIKUBE_IP}:30090/-/healthy" &>/dev/null; then
    echo "✅ Prometheus está accesible"
    
    # Verificar algunos targets
    targets=$(curl -s "http://${MINIKUBE_IP}:30090/api/v1/targets" | grep -o '"health":"[^"]*"' | head -5)
    if [ ! -z "$targets" ]; then
        echo "✅ Prometheus tiene targets configurados:"
        echo "$targets" | sed 's/"health":"\([^"]*\)"/   \1/'
    else
        echo "⚠️  No se pudieron obtener targets de Prometheus"
    fi
    
    # Verificar métricas básicas
    up_metrics=$(curl -s "http://${MINIKUBE_IP}:30090/api/v1/query?query=up" | grep -o '"value":\[[^]]*\]' | head -3)
    if [ ! -z "$up_metrics" ]; then
        echo "✅ Prometheus está recolectando métricas 'up':"
        echo "$up_metrics" | sed 's/"value":\[\([^]]*\)\]/   up=\1/'
    fi
else
    echo "❌ Prometheus no está accesible en :30090"
fi

echo ""
echo "📋 5. VERIFICANDO LOGS EN ELASTICSEARCH..."

if curl -s "http://${MINIKUBE_IP}:9200/_cluster/health" &>/dev/null; then
    echo "✅ Elasticsearch está accesible"
    
    # Verificar índices de logs
    indices=$(curl -s "http://${MINIKUBE_IP}:9200/_cat/indices/ecommerce-logs*" | head -3)
    if [ ! -z "$indices" ]; then
        echo "✅ Índices de logs encontrados:"
        echo "$indices" | awk '{print "   " $3 " (" $6 " docs)"}'
    else
        echo "⚠️  No se encontraron índices de logs todavía"
        echo "💡 Los logs pueden tardar unos minutos en aparecer"
    fi
else
    echo "❌ Elasticsearch no está accesible"
    echo "💡 Intentando con port-forward..."
    kubectl port-forward svc/elasticsearch 9200:9200 -n monitoring &>/dev/null &
    local es_pid=$!
    sleep 3
    
    if curl -s "http://localhost:9200/_cluster/health" &>/dev/null; then
        echo "✅ Elasticsearch responde via port-forward"
    fi
    kill $es_pid 2>/dev/null
fi

echo ""
echo "🔍 6. VERIFICANDO JAEGER TRACING..."

if curl -s "http://${MINIKUBE_IP}:30686/" &>/dev/null; then
    echo "✅ Jaeger UI está accesible"
    
    # Verificar servicios en Jaeger
    services=$(curl -s "http://${MINIKUBE_IP}:30686/api/services" 2>/dev/null | grep -o '"[^"]*-service"' | head -3)
    if [ ! -z "$services" ]; then
        echo "✅ Servicios encontrados en Jaeger:"
        echo "$services" | sed 's/"//g' | sed 's/^/   /'
    else
        echo "⚠️  No se encontraron servicios en Jaeger todavía"
        echo "💡 Las trazas pueden tardar en aparecer"
    fi
else
    echo "❌ Jaeger no está accesible en :30686"
fi

echo ""
echo "🚨 7. VERIFICANDO ALERTMANAGER..."

if curl -s "http://${MINIKUBE_IP}:30093/-/healthy" &>/dev/null; then
    echo "✅ AlertManager está accesible"
    
    # Verificar alertas activas
    alerts=$(curl -s "http://${MINIKUBE_IP}:30093/api/v1/alerts" 2>/dev/null | grep -o '"alertname":"[^"]*"' | head -3)
    if [ ! -z "$alerts" ]; then
        echo "🔔 Alertas encontradas:"
        echo "$alerts" | sed 's/"alertname":"\([^"]*\)"/   \1/' 
    else
        echo "✅ No hay alertas activas actualmente"
    fi
else
    echo "❌ AlertManager no está accesible en :30093"
fi

echo ""
echo "📊 8. GENERANDO CARGA SOSTENIDA..."
echo "⏳ Generando tráfico durante 2 minutos para poblar dashboards..."

# Generar carga sostenida durante 2 minutos
end_time=$(($(date +%s) + 120))
request_count=0

while [ $(date +%s) -lt $end_time ]; do
    for service_config in "${SERVICES[@]}"; do
        IFS=':' read -r service port endpoint <<< "$service_config"
        
        # Petición normal
        curl -s --max-time 3 "http://${MINIKUBE_IP}:$port$endpoint" &>/dev/null && 
        request_count=$((request_count + 1))
        
        # Ocasionalmente generar un error
        if [ $((RANDOM % 10)) -eq 0 ]; then
            curl -s --max-time 3 "http://${MINIKUBE_IP}:$port/error-endpoint" &>/dev/null
        fi
    done
    
    echo "🔄 Peticiones enviadas: $request_count"
    sleep 5
done

echo ""
echo "🎉 GENERACIÓN DE DATOS COMPLETADA!"
echo "=================================="
echo ""
echo "📊 RESUMEN DE DATOS GENERADOS:"
echo "   • $request_count peticiones HTTP a microservicios"
echo "   • ~30 errores 404 controlados"
echo "   • Métricas recolectadas por Prometheus"
echo "   • Logs enviados a ELK Stack"
echo "   • Trazas generadas para Jaeger"
echo ""

echo "🌐 VERIFICAR RESULTADOS EN:"
echo "┌─────────────────┬─────────────────────────────────────┐"
echo "│ Dashboard       │ URL                                 │"
echo "├─────────────────┼─────────────────────────────────────┤"
echo "│ Prometheus      │ http://${MINIKUBE_IP}:30090         │"
echo "│ Grafana         │ http://${MINIKUBE_IP}:30030         │"
echo "│ Kibana          │ http://${MINIKUBE_IP}:30601         │"
echo "│ Jaeger          │ http://${MINIKUBE_IP}:30686         │"
echo "│ AlertManager    │ http://${MINIKUBE_IP}:30093         │"
echo "└─────────────────┴─────────────────────────────────────┘"

echo ""
echo "📈 PRÓXIMOS PASOS:"
echo "1. Abre Grafana y verifica los dashboards de métricas"
echo "2. Revisa Kibana para análisis de logs"
echo "3. Explora Jaeger para ver trazas distribuidas"
echo "4. Verifica AlertManager para alertas configuradas"
echo ""
echo "💡 Los datos pueden tardar 1-2 minutos en aparecer en todos los dashboards" 