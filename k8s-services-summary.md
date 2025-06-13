# 📊 RESUMEN DE SERVICIOS Y PUERTOS K8S

## 🌐 **Servicios de Infraestructura**
| Servicio | Puerto Interno | NodePort | Descripción |
|----------|---------------|----------|-------------|
| service-discovery | 8761 | 30761 | Eureka Server |
| api-gateway | 8080 | 30080 | Gateway Principal |
| proxy-client | 8900 | 30900 | Frontend/Swagger UI |

## 🏪 **Microservicios de Negocio**
| Servicio | Puerto Interno | NodePort | Descripción |
|----------|---------------|----------|-------------|
| user-service | 8087 | 30087 | Gestión de usuarios |
| product-service | 8082 | 30082 | Catálogo de productos |
| order-service | 8083 | 30083 | Gestión de pedidos |
| payment-service | 8084 | 30084 | Procesamiento de pagos |
| shipping-service | 8085 | 30085 | Envíos y logística |
| favourite-service | 8086 | 30086 | Lista de favoritos |

## 🔗 **URLs de Acceso**
```bash
# Obtener IP de Minikube
MINIKUBE_IP=$(minikube ip)

# Frontend/Swagger UI
http://$MINIKUBE_IP:30900/swagger-ui.html

# API Gateway
http://$MINIKUBE_IP:30080

# Service Discovery (Eureka)
http://$MINIKUBE_IP:30761

# Microservicios individuales
http://$MINIKUBE_IP:30087  # user-service
http://$MINIKUBE_IP:30082  # product-service
http://$MINIKUBE_IP:30083  # order-service
http://$MINIKUBE_IP:30084  # payment-service
http://$MINIKUBE_IP:30085  # shipping-service
http://$MINIKUBE_IP:30086  # favourite-service
```

## 🚀 **Port-Forward para Acceso Local**
```bash
# Frontend
kubectl port-forward svc/proxy-client -n ecommerce 8900:8900

# API Gateway  
kubectl port-forward svc/api-gateway -n ecommerce 8080:8080

# Microservicios
kubectl port-forward svc/user-service -n ecommerce 8087:8087
kubectl port-forward svc/product-service -n ecommerce 8082:8082
kubectl port-forward svc/order-service -n ecommerce 8083:8083
kubectl port-forward svc/payment-service -n ecommerce 8084:8084
kubectl port-forward svc/shipping-service -n ecommerce 8085:8085
kubectl port-forward svc/favourite-service -n ecommerce 8086:8086
```

## 📦 **Comandos de Deployment**
```bash
# Desplegar todo
kubectl apply -f k8s-all-services.yaml

# Verificar estado
kubectl get all -n ecommerce

# Ver logs
kubectl logs -f deployment/proxy-client -n ecommerce
```
