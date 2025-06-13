#!/bin/bash

echo "🚀 DESPLEGANDO PILA COMPLETA DE MONITOREO"
echo "========================================="
echo ""
echo "📋 Componentes a desplegar:"
echo "   • Prometheus + Grafana"
echo "   • ELK Stack (Elasticsearch, Logstash, Kibana)"
echo "   • Jaeger para tracing distribuido"
echo "   • Health checks (readiness/liveness probes)"
echo "   • AlertManager para alertas"
echo ""

# Verificar prerequisitos
echo "🔍 1. VERIFICANDO PREREQUISITOS..."
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Kubernetes no está disponible. Ejecuta minikube start primero."
    exit 1
fi

if ! kubectl get namespace ecommerce &> /dev/null; then
    echo "❌ Namespace 'ecommerce' no existe. Ejecuta el setup de microservicios primero."
    exit 1
fi

echo "✅ Prerequisitos verificados"

# Crear namespace de monitoring
echo ""
echo "📦 2. CONFIGURANDO NAMESPACE DE MONITORING..."
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
echo "✅ Namespace 'monitoring' configurado"

# Desplegar Prometheus
echo ""
echo "📊 3. DESPLEGANDO PROMETHEUS..."
kubectl apply -f monitoring/prometheus/prometheus-config.yaml
kubectl apply -f monitoring/prometheus/prometheus-deployment.yaml

echo "⏳ Esperando que Prometheus inicie..."
kubectl wait --for=condition=available --timeout=300s deployment/prometheus -n monitoring
echo "✅ Prometheus desplegado exitosamente"

# Desplegar Grafana
echo ""
echo "📈 4. DESPLEGANDO GRAFANA..."
kubectl apply -f monitoring/grafana/dashboards-config.yaml
kubectl apply -f monitoring/grafana/grafana-dashboards.yaml
kubectl apply -f monitoring/grafana/grafana-deployment.yaml

echo "⏳ Esperando que Grafana inicie..."
kubectl wait --for=condition=available --timeout=300s deployment/grafana -n monitoring
echo "✅ Grafana desplegado exitosamente"

# Desplegar ELK Stack
echo ""
echo "🔍 5. DESPLEGANDO ELK STACK..."
cat << 'EOF' | kubectl apply -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: elasticsearch-config
  namespace: monitoring
data:
  elasticsearch.yml: |
    cluster.name: "docker-cluster"
    network.host: 0.0.0.0
    discovery.type: single-node
    xpack.security.enabled: false
    xpack.monitoring.collection.enabled: true
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: elasticsearch
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
      - name: elasticsearch
        image: docker.elastic.co/elasticsearch/elasticsearch:8.5.0
        ports:
        - containerPort: 9200
        - containerPort: 9300
        env:
        - name: discovery.type
          value: single-node
        - name: ES_JAVA_OPTS
          value: "-Xms512m -Xmx512m"
        - name: xpack.security.enabled
          value: "false"
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: config-volume
          mountPath: /usr/share/elasticsearch/config/elasticsearch.yml
          subPath: elasticsearch.yml
      volumes:
      - name: config-volume
        configMap:
          name: elasticsearch-config
---
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
  namespace: monitoring
spec:
  ports:
  - port: 9200
    targetPort: 9200
    name: http
  - port: 9300
    targetPort: 9300
    name: transport
  selector:
    app: elasticsearch
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: logstash-config
  namespace: monitoring
data:
  logstash.conf: |
    input {
      beats {
        port => 5044
      }
      http {
        port => 8080
      }
    }
    filter {
      if [kubernetes] {
        mutate {
          add_field => { "service_name" => "%{[kubernetes][container][name]}" }
          add_field => { "namespace" => "%{[kubernetes][namespace]}" }
        }
      }
      if [message] =~ /ERROR/ {
        mutate {
          add_tag => [ "error" ]
          add_field => { "log_level" => "ERROR" }
        }
      }
      if [message] =~ /WARN/ {
        mutate {
          add_tag => [ "warning" ]
          add_field => { "log_level" => "WARN" }
        }
      }
    }
    output {
      elasticsearch {
        hosts => ["elasticsearch:9200"]
        index => "ecommerce-logs-%{+YYYY.MM.dd}"
      }
      stdout { codec => rubydebug }
    }
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: logstash
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: logstash
  template:
    metadata:
      labels:
        app: logstash
    spec:
      containers:
      - name: logstash
        image: docker.elastic.co/logstash/logstash:8.5.0
        ports:
        - containerPort: 5044
        - containerPort: 8080
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        volumeMounts:
        - name: config-volume
          mountPath: /usr/share/logstash/pipeline/logstash.conf
          subPath: logstash.conf
      volumes:
      - name: config-volume
        configMap:
          name: logstash-config
---
apiVersion: v1
kind: Service
metadata:
  name: logstash
  namespace: monitoring
spec:
  ports:
  - port: 5044
    targetPort: 5044
    name: beats
  - port: 8080
    targetPort: 8080
    name: http
  selector:
    app: logstash
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kibana
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kibana
  template:
    metadata:
      labels:
        app: kibana
    spec:
      containers:
      - name: kibana
        image: docker.elastic.co/kibana/kibana:8.5.0
        ports:
        - containerPort: 5601
        env:
        - name: ELASTICSEARCH_HOSTS
          value: "http://elasticsearch:9200"
        - name: XPACK_SECURITY_ENABLED
          value: "false"
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        readinessProbe:
          httpGet:
            path: /app/kibana
            port: 5601
          initialDelaySeconds: 30
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - port: 5601
    targetPort: 5601
    nodePort: 30601
  selector:
    app: kibana
EOF

echo "⏳ Esperando que ELK Stack inicie..."
kubectl wait --for=condition=available --timeout=300s deployment/elasticsearch -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/logstash -n monitoring
kubectl wait --for=condition=available --timeout=300s deployment/kibana -n monitoring
echo "✅ ELK Stack desplegado exitosamente"

# Desplegar Jaeger
echo ""
echo "🔍 6. DESPLEGANDO JAEGER PARA TRACING..."
cat << 'EOF' | kubectl apply -f -
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
  namespace: monitoring
  labels:
    app: jaeger
spec:
  replicas: 1
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
      - name: jaeger
        image: jaegertracing/all-in-one:1.50
        ports:
        - containerPort: 16686
          name: ui
        - containerPort: 14268
          name: collector
        - containerPort: 6831
          name: agent-udp
        - containerPort: 6832
          name: agent-binary
        env:
        - name: COLLECTOR_ZIPKIN_HOST_PORT
          value: ":9411"
        - name: COLLECTOR_OTLP_ENABLED
          value: "true"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
        readinessProbe:
          httpGet:
            path: /
            port: 16686
          initialDelaySeconds: 5
          periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger
  namespace: monitoring
  labels:
    app: jaeger
spec:
  type: NodePort
  ports:
  - port: 16686
    targetPort: 16686
    nodePort: 30686
    name: ui
  - port: 14268
    targetPort: 14268
    name: collector
  - port: 6831
    targetPort: 6831
    protocol: UDP
    name: agent-udp
  - port: 6832
    targetPort: 6832
    name: agent-binary
  selector:
    app: jaeger
EOF

echo "⏳ Esperando que Jaeger inicie..."
kubectl wait --for=condition=available --timeout=300s deployment/jaeger -n monitoring
echo "✅ Jaeger desplegado exitosamente"

# Desplegar AlertManager
echo ""
echo "🚨 7. DESPLEGANDO ALERTMANAGER..."
cat << 'EOF' | kubectl apply -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: alertmanager-config
  namespace: monitoring
data:
  alertmanager.yml: |
    global:
      smtp_smarthost: 'localhost:587'
      smtp_from: 'alertmanager@ecommerce.local'
    route:
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
      receiver: 'web.hook'
    receivers:
    - name: 'web.hook'
      webhook_configs:
      - url: 'http://127.0.0.1:5001/'
        send_resolved: true
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: alertmanager
  namespace: monitoring
spec:
  replicas: 1
  selector:
    matchLabels:
      app: alertmanager
  template:
    metadata:
      labels:
        app: alertmanager
    spec:
      containers:
      - name: alertmanager
        image: prom/alertmanager:v0.25.0
        args:
          - '--config.file=/etc/alertmanager/alertmanager.yml'
          - '--storage.path=/alertmanager'
        ports:
        - containerPort: 9093
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        volumeMounts:
        - name: config-volume
          mountPath: /etc/alertmanager
      volumes:
      - name: config-volume
        configMap:
          name: alertmanager-config
---
apiVersion: v1
kind: Service
metadata:
  name: alertmanager
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - port: 9093
    targetPort: 9093
    nodePort: 30093
  selector:
    app: alertmanager
EOF

echo "⏳ Esperando que AlertManager inicie..."
kubectl wait --for=condition=available --timeout=300s deployment/alertmanager -n monitoring
echo "✅ AlertManager desplegado exitosamente"

# Actualizar microservicios con health checks mejorados
echo ""
echo "🏥 8. ACTUALIZANDO MICROSERVICIOS CON HEALTH CHECKS..."
cat << 'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: ecommerce
  labels:
    app: user-service
    version: "monitored"
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
        version: "monitored"
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/path: "/actuator/prometheus"
        prometheus.io/port: "8081"
    spec:
      containers:
      - name: user-service
        image: selimhorri/ecommerce-user-service:latest
        ports:
        - containerPort: 8081
          name: http
        env:
        - name: SERVER_PORT
          value: "8081"
        - name: MANAGEMENT_ENDPOINTS_WEB_EXPOSURE_INCLUDE
          value: "health,info,metrics,prometheus"
        - name: MANAGEMENT_ENDPOINT_HEALTH_SHOW_DETAILS
          value: "always"
        - name: JAEGER_AGENT_HOST
          value: "jaeger.monitoring.svc.cluster.local"
        - name: JAEGER_AGENT_PORT
          value: "6831"
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /actuator/health/liveness
            port: 8081
          initialDelaySeconds: 60
          periodSeconds: 30
          timeoutSeconds: 10
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /actuator/health/readiness
            port: 8081
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
EOF

echo "✅ Health checks configurados en microservicios"

# Configurar Filebeat para logs
echo ""
echo "📋 9. DESPLEGANDO FILEBEAT PARA RECOLECCIÓN DE LOGS..."
cat << 'EOF' | kubectl apply -f -
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: filebeat-config
  namespace: monitoring
data:
  filebeat.yml: |-
    filebeat.inputs:
    - type: container
      paths:
        - /var/log/containers/*.log
      processors:
        - add_kubernetes_metadata:
            host: ${NODE_NAME}
            matchers:
            - logs_path:
                logs_path: "/var/log/containers/"
    output.logstash:
      hosts: ["logstash:5044"]
    logging.level: info
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: filebeat
  namespace: monitoring
spec:
  selector:
    matchLabels:
      app: filebeat
  template:
    metadata:
      labels:
        app: filebeat
    spec:
      serviceAccountName: filebeat
      terminationGracePeriodSeconds: 30
      hostNetwork: true
      dnsPolicy: ClusterFirstWithHostNet
      containers:
      - name: filebeat
        image: docker.elastic.co/beats/filebeat:8.5.0
        args: [
          "-c", "/etc/filebeat.yml",
          "-e",
        ]
        env:
        - name: NODE_NAME
          valueFrom:
            fieldRef:
              fieldPath: spec.nodeName
        resources:
          limits:
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 100Mi
        volumeMounts:
        - name: config
          mountPath: /etc/filebeat.yml
          readOnly: true
          subPath: filebeat.yml
        - name: data
          mountPath: /usr/share/filebeat/data
        - name: varlibdockercontainers
          mountPath: /var/lib/docker/containers
          readOnly: true
        - name: varlog
          mountPath: /var/log
          readOnly: true
      volumes:
      - name: config
        configMap:
          defaultMode: 0640
          name: filebeat-config
      - name: varlibdockercontainers
        hostPath:
          path: /var/lib/docker/containers
      - name: varlog
        hostPath:
          path: /var/log
      - name: data
        hostPath:
          path: /var/lib/filebeat-data
          type: DirectoryOrCreate
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: filebeat
rules:
- apiGroups: [""]
  resources:
  - namespaces
  - pods
  - nodes
  verbs:
  - get
  - watch
  - list
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: filebeat
subjects:
- kind: ServiceAccount
  name: filebeat
  namespace: monitoring
roleRef:
  kind: ClusterRole
  name: filebeat
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: filebeat
  namespace: monitoring
EOF

echo "✅ Filebeat desplegado para recolección de logs"

# Mostrar resumen
echo ""
echo "🎉 MONITOREO DESPLEGADO EXITOSAMENTE!"
echo "====================================="
echo ""
echo "📊 SERVICIOS DISPONIBLES:"
echo "┌─────────────────┬─────────────────┬─────────────────┐"
echo "│ Servicio        │ URL             │ Credenciales    │"
echo "├─────────────────┼─────────────────┼─────────────────┤"
echo "│ Prometheus      │ :30090          │ N/A             │"
echo "│ Grafana         │ :30030          │ admin/admin123  │"
echo "│ Kibana          │ :30601          │ N/A             │"
echo "│ Jaeger          │ :30686          │ N/A             │"
echo "│ AlertManager    │ :30093          │ N/A             │"
echo "└─────────────────┴─────────────────┴─────────────────┘"
echo ""

# Obtener IP de minikube
MINIKUBE_IP=$(minikube ip 2>/dev/null || echo "localhost")

echo "🌐 URLs DE ACCESO:"
echo "  • Prometheus:    http://${MINIKUBE_IP}:30090"
echo "  • Grafana:       http://${MINIKUBE_IP}:30030"
echo "  • Kibana:        http://${MINIKUBE_IP}:30601"
echo "  • Jaeger:        http://${MINIKUBE_IP}:30686"
echo "  • AlertManager:  http://${MINIKUBE_IP}:30093"
echo ""

echo "📋 COMANDOS ÚTILES:"
echo "  kubectl get pods -n monitoring"
echo "  kubectl logs -f deployment/prometheus -n monitoring"
echo "  kubectl port-forward svc/grafana 3000:3000 -n monitoring"
echo ""

echo "✅ Todos los componentes de monitoreo están corriendo!"
echo "📈 Puedes comenzar a revisar las métricas y logs en los dashboards" 