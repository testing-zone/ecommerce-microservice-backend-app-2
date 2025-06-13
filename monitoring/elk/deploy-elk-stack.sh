#!/bin/bash

# Script para desplegar ELK Stack completo
set -e

echo "🚀 Desplegando ELK Stack para E-commerce..."

# Crear namespace si no existe
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Desplegar componentes en orden
echo "📊 Desplegando Elasticsearch..."
kubectl apply -f monitoring/elk/elasticsearch-deployment.yaml

echo "⏳ Esperando que Elasticsearch esté listo..."
kubectl wait --for=condition=ready pod -l app=elasticsearch -n monitoring --timeout=300s

echo "🔄 Desplegando Logstash..."
kubectl apply -f monitoring/elk/logstash-deployment.yaml

echo "📈 Desplegando Kibana..."
kubectl apply -f monitoring/elk/kibana-deployment.yaml

echo "🌐 Configurando NodePorts..."
kubectl apply -f monitoring/monitoring-nodeports.yaml

echo "✅ ELK Stack desplegado!"
echo ""
echo "🔍 URLs de acceso:"
echo "- Kibana: http://localhost:30601"
echo "- Elasticsearch: http://localhost:30920"
echo "- Logstash TCP: localhost:30500"
echo ""
echo "📋 Configurar índices en Kibana: ecommerce-logs-*" 