#!/bin/bash

# Script para probar ELK Stack con logs de prueba
set -e

echo "🧪 Probando ELK Stack con logs de prueba..."

# URLs de los servicios
LOGSTASH_HTTP="http://localhost:30580"
ELASTICSEARCH_URL="http://localhost:30920"
KIBANA_URL="http://localhost:30601"

# Función para enviar logs de prueba
send_test_logs() {
    echo "📤 Enviando logs de prueba a Logstash..."
    
    # Logs de diferentes servicios y niveles
    curl -X POST "$LOGSTASH_HTTP" \
        -H "Content-Type: application/json" \
        -d '{
            "service_name": "user-service",
            "level": "INFO",
            "message": "Usuario creado exitosamente",
            "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'",
            "service_type": "business",
            "service_category": "user_management"
        }'
    
    curl -X POST "$LOGSTASH_HTTP" \
        -H "Content-Type: application/json" \
        -d '{
            "service_name": "product-service",
            "level": "ERROR",
            "message": "Error al conectar con base de datos",
            "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'",
            "service_type": "business",
            "service_category": "catalog",
            "alert_level": "high"
        }'
    
    curl -X POST "$LOGSTASH_HTTP" \
        -H "Content-Type: application/json" \
        -d '{
            "service_name": "api-gateway",
            "level": "INFO",
            "message": "Request processed in 150ms",
            "timestamp": "'$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)'",
            "service_type": "infrastructure",
            "service_category": "gateway",
            "response_time_ms": 150
        }'
    
    echo "✅ Logs de prueba enviados"
}

# Función para verificar Elasticsearch
check_elasticsearch() {
    echo "🔍 Verificando Elasticsearch..."
    
    if curl -s "$ELASTICSEARCH_URL/_cluster/health" | grep -q "green\|yellow"; then
        echo "✅ Elasticsearch está funcionando"
        
        # Mostrar índices
        echo "📊 Índices disponibles:"
        curl -s "$ELASTICSEARCH_URL/_cat/indices?v" | head -10
        
        # Buscar logs recientes
        echo ""
        echo "📝 Logs recientes:"
        curl -s "$ELASTICSEARCH_URL/ecommerce-logs-*/_search?size=5&sort=@timestamp:desc" | jq '.hits.hits[]._source' 2>/dev/null || echo "Instalar jq para ver logs formateados"
    else
        echo "❌ Elasticsearch no está respondiendo"
        return 1
    fi
}

# Función para verificar Kibana
check_kibana() {
    echo "🖥️  Verificando Kibana..."
    
    if curl -s "$KIBANA_URL/api/status" | grep -q "available"; then
        echo "✅ Kibana está funcionando"
        echo "🌐 Accede a: $KIBANA_URL"
    else
        echo "❌ Kibana no está respondiendo"
        return 1
    fi
}

# Función principal
main() {
    echo "🚀 Iniciando pruebas de ELK Stack..."
    
    # Verificar componentes
    check_elasticsearch
    echo ""
    check_kibana
    echo ""
    
    # Enviar logs de prueba
    send_test_logs
    
    echo ""
    echo "⏳ Esperando 10 segundos para que se procesen los logs..."
    sleep 10
    
    # Verificar logs en Elasticsearch
    check_elasticsearch
    
    echo ""
    echo "✅ Pruebas completadas!"
    echo ""
    echo "📋 Próximos pasos en Kibana ($KIBANA_URL):"
    echo "1. Ir a Stack Management > Index Patterns"
    echo "2. Crear patrón: ecommerce-logs-*"
    echo "3. Seleccionar campo de tiempo: @timestamp"
    echo "4. Ir a Discover para ver los logs"
    echo "5. Crear dashboards personalizados"
}

# Ejecutar función principal
main "$@" 