# 🚀 Kubernetes Deployment - User Service

## 📋 Archivos de Deployment

- `namespace.yaml` - Namespace para el proyecto ecommerce
- `configmap.yaml` - Configuración de la aplicación para K8s
- `deployment.yaml` - Deployment y Service de user-service
- `deploy.sh` - Script automatizado de deployment

## 🎯 Deployment Automático

### Desde Jenkins Pipeline:
El pipeline incluye un stage de "Deploy to Kubernetes" que:
1. ✅ Verifica conectividad con el cluster
2. ✅ Aplica namespace, configmap y deployment
3. ✅ Espera a que el deployment esté listo
4. ✅ Muestra el estado de pods y servicios

### Deployment Manual:
```bash
cd user-service/k8s
./deploy.sh
```

## 🔧 Configuración

### Recursos:
- **CPU**: 250m request, 500m limit
- **Memory**: 256Mi request, 512Mi limit
- **Replicas**: 2 pods
- **Port**: 8700

### Health Checks:
- **Liveness**: `/actuator/health/liveness`
- **Readiness**: `/actuator/health/readiness`

### Environment:
- **Profile**: `k8s`
- **Database**: H2 in-memory
- **Config**: Montado desde ConfigMap

## 🌐 Acceso al Servicio

### Port Forward:
```bash
kubectl port-forward svc/user-service 8700:8700 -n ecommerce
```

### Endpoints disponibles:
- Health: http://localhost:8700/actuator/health
- H2 Console: http://localhost:8700/h2-console
- Metrics: http://localhost:8700/actuator/metrics

## 📊 Comandos Útiles

```bash
# Ver pods
kubectl get pods -n ecommerce

# Ver logs
kubectl logs -f deployment/user-service -n ecommerce

# Describir deployment
kubectl describe deployment user-service -n ecommerce

# Escalar deployment
kubectl scale deployment user-service --replicas=3 -n ecommerce

# Eliminar deployment
kubectl delete -f deployment.yaml
kubectl delete -f configmap.yaml
kubectl delete -f namespace.yaml
```

## ⚠️ Notas

- Si no hay cluster K8s disponible, el pipeline marcará el build como UNSTABLE pero continuará
- La imagen Docker debe estar disponible en el nodo donde se ejecute el pod
- Para producción, considera usar un registry externo para las imágenes 