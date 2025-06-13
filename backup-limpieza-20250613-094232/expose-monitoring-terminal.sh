#!/bin/bash

# Servicios de monitoreo a exponer
SERVICES=("grafana" "prometheus" "kibana" "jaeger" "alertmanager")
NAMESPACE="monitoring"

# Carpeta temporal para scripts individuales
TMPDIR="$(pwd)/.minikube-terminals"
mkdir -p "$TMPDIR"

for SERVICE in "${SERVICES[@]}"; do
  SCRIPT="$TMPDIR/expose-$SERVICE.sh"
  cat > "$SCRIPT" <<EOF
#!/bin/bash
echo "Exponiendo $SERVICE en una terminal dedicada..."
minikube service $SERVICE -n $NAMESPACE
echo
echo "Presiona Ctrl+C para cerrar el túnel de $SERVICE."
bash
EOF
  chmod +x "$SCRIPT"
  # Abrir nueva ventana de Terminal.app ejecutando el script
  open -a Terminal.app "$SCRIPT"
done

echo "✅ Se abrieron terminales para todos los servicios de monitoreo."
echo "No cierres estas ventanas mientras quieras acceder a los dashboards."