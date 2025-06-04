#### Integrantes
 - Sara Cardona
 - Luis Pinillos
 - 

# 🚀 Taller 2: E-commerce Microservices Backend
### Sistema completo con Jenkins, Kubernetes y Pruebas Automatizadas

---

## 📋 Descripción del Proyecto

Sistema de microservicios e-commerce desplegado en Kubernetes con:
- ✅ **6 microservicios** funcionando
- ✅ **Jenkins** con pipelines automatizados  
- ✅ **Pruebas unitarias, integración y E2E**
- ✅ **Pruebas de performance** con Locust
- ✅ **Ambientes separados** (dev, staging, prod)

---

## 🚀 Inicio Rápido (3 comandos)

```bash
# 1. Setup completo desde cero
./1-setup-completo.sh

# 2. Verificar que todo funciona
./2-verificar-servicios.sh

# 3. Generar evidencias de pruebas
./3-pruebas-performance.sh
```

---

## 🔑 Credenciales

**Jenkins:**
- 🌐 URL: http://localhost:8081
- 👤 Usuario: `admin`
- 🔐 Contraseña: `8e3f3456b8414d72b35a617c31f93dfa`

---

## 📊 Evidencias Generadas

### ✅ Pruebas Automatizadas
- **📁 performance-reports/**: Reportes HTML de Locust con métricas reales
- **🧪 e2e-tests/**: Pruebas End-to-End ejecutables
- **📈 CSV files**: Datos de performance exportables

### ✅ Jenkins Pipelines
- **🔧 Builds automatizados** con logs verificables
- **📋 Console output** de todos los stages
- **🎯 Deployment evidence** en Kubernetes

---

## 🏗️ Arquitectura del Sistema

<details>
<summary>📊 Ver Diagrama de Arquitectura</summary>

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   user-service  │    │ product-service │    │  order-service  │
│     :8081       │    │     :8082       │    │     :8083       │
└─────────────────┘    └─────────────────┘    └─────────────────┘

┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│payment-service  │    │shipping-service │    │favourite-service│
│     :8084       │    │     :8085       │    │     :8086       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

**Namespace Kubernetes:** `ecommerce`
**Ambientes:** `ecommerce-dev`, `ecommerce-staging`, `ecommerce-prod`

</details>

---

## 📝 Scripts Disponibles

| Script | Descripción | Tiempo |
|--------|-------------|---------|
| `1-setup-completo.sh` | Setup inicial completo | ~5 min |
| `2-verificar-servicios.sh` | Verificar funcionamiento | ~1 min |
| `3-pruebas-performance.sh` | Generar evidencias de performance | ~10 min |
| `4-configurar-jenkins.sh` | Guía de configuración Jenkins | Manual |
| `5-configurar-ambientes-e2e.sh` | Setup ambientes y E2E | ~3 min |


---

## 🖼️ Evidencias Visuales

### 📸 Jenkins Pipeline Success

<details>
<summary>🔍 Ver Jenkins Pipeline Dashboard</summary>

> <img width="1348" alt="Screenshot 2025-06-04 at 8 50 15 AM" src="https://github.com/user-attachments/assets/ec94e7ed-9a61-4f8f-b149-2839a82a96b1" />

</details>

### 📸 Kubernetes Pods Running

<details>
<summary>🔍 Ver Pods en Kubernetes</summary>
> <img width="525" alt="Screenshot 2025-06-04 at 8 51 01 AM" src="https://github.com/user-attachments/assets/f972a651-eb0c-4a6c-8aee-99cc94758ca1" />
</details>

### 📸 Performance Reports

<details>
<summary>🔍 Ver Reportes de Performance</summary>

> <img width="789" alt="Screenshot 2025-06-04 at 8 51 27 AM" src="https://github.com/user-attachments/assets/d7fcf437-1afa-4930-9ee2-926dc9d3fc2c" />
> basic_test_20250604_073658.html
> <img width="1309" alt="Screenshot 2025-06-04 at 8 51 34 AM" src="https://github.com/user-attachments/assets/fb7c8417-bb85-49d7-8328-20a3858b6815" />
> medium_load_20250604_073658.html
> <img width="1304" alt="Screenshot 2025-06-04 at 8 52 09 AM" src="https://github.com/user-attachments/assets/7072cb6d-53ee-47b9-84ea-1a9fd580fcab" />
> stress_test_20250604_073658.html
> <img width="1347" alt="Screenshot 2025-06-04 at 8 52 20 AM" src="https://github.com/user-attachments/assets/1b204222-a021-4582-b122-6b4b8a00f6c6" />

</details>

### 📸 Microservicios en Jenkins

<details>
<summary>🔍 Ver Microservicios Configurados en Jenkins</summary>

> <img width="1664" alt="Screenshot 2025-06-04 at 8 52 45 AM" src="https://github.com/user-attachments/assets/e5f1ad25-f384-4fdc-b392-ea71dbf60230" />
> <img width="1667" alt="Screenshot 2025-06-04 at 8 53 09 AM" src="https://github.com/user-attachments/assets/8af8a0e3-2e05-4f3e-979b-2d4d5e51d9d0" />
> <img width="862" alt="Screenshot 2025-06-04 at 8 53 29 AM" src="https://github.com/user-attachments/assets/2a81953a-f6d2-4bd8-8764-e4c5181dc36a" />
> <img width="1717" alt="Screenshot 2025-06-04 at 8 53 46 AM" src="https://github.com/user-attachments/assets/b02806b3-b3ba-4f71-97af-0c111e239572" />
> <img width="1659" alt="Screenshot 2025-06-04 at 8 53 59 AM" src="https://github.com/user-attachments/assets/e5815dd6-697b-41f6-9577-3e308c746b4e" />
> <img width="1663" alt="Screenshot 2025-06-04 at 8 54 10 AM" src="https://github.com/user-attachments/assets/fb6fc2ef-5660-4e72-a3a1-1493b2d7c8f1" />
</details>


---

## 🔍 Comandos de Verificación

```bash
# Ver estado de todos los pods
kubectl get pods -n ecommerce

# Ver servicios disponibles
kubectl get services -n ecommerce

# Ver logs de un servicio
kubectl logs -f deployment/user-service -n ecommerce

# Acceder a Jenkins
open http://localhost:8081

# Ver reportes de performance
open performance-reports/

# Ejecutar pruebas E2E
cd e2e-tests && ./run_e2e_tests.sh
```

---

## Ambientes Configurados

| Ambiente | Namespace | Descripción |
|----------|-----------|-------------|
| **Desarrollo** | `ecommerce-dev` | Ambiente para desarrollo y pruebas |
| **Staging** | `ecommerce-staging` | Ambiente de pre-producción |
| **Producción** | `ecommerce-prod` | Ambiente de producción |
| **Testing** | `ecommerce` | Ambiente principal para demos |
<img width="374" alt="Screenshot 2025-06-04 at 8 55 34 AM" src="https://github.com/user-attachments/assets/81b43e8d-95bb-4c9e-8476-17295a759085" />

---

## 🧪 Pruebas Implementadas

<details>
<summary>📋 Ver Detalle de Pruebas</summary>

### Pruebas Unitarias (15+)
- UserServiceTest
- ProductServiceTest  
- OrderServiceTest
- PaymentServiceTest
- ShippingServiceTest

### Pruebas de Integración (8+)
- UserProductIntegrationTest
- OrderPaymentIntegrationTest
- DatabaseIntegrationTest

### Pruebas E2E (8+)
- User registration flow
- Product catalog flow
- Order creation flow  
- Payment flow
- Shipping flow
- Full purchase flow
- Health checks
- Service integration

### Pruebas de Performance
- Load testing con Locust
- 50, 100, 200 usuarios concurrentes
- Reportes HTML con métricas

</details>

---

## ⚡ Resolución de Problemas

<details>
<summary>🔧 Troubleshooting Común</summary>

### Docker no inicia
```bash
open -a Docker
# Esperar que Docker Desktop inicie
```

### Kubernetes no responde
```bash
minikube status
minikube start
```

### Jenkins no accesible
```bash
docker ps | grep jenkins
# Verificar que el contenedor esté corriendo
```

### Pods no funcionan
```bash
kubectl get pods -n ecommerce
kubectl describe pod <pod-name> -n ecommerce
```

</details>

---

## 📁 Estructura del Proyecto

<details>
<summary>📂 Ver Estructura Completa</summary>

```
ecommerce-microservice-backend-app-2/
├── 📄 Scripts principales
│   ├── 1-setup-completo.sh
│   ├── 2-verificar-servicios.sh
│   ├── 3-pruebas-performance.sh
│   ├── 4-configurar-jenkins.sh
│   └── 5-configurar-ambientes-e2e.sh
├── 🧪 Pruebas
│   ├── e2e-tests/
│   ├── performance-reports/
│   └── locustfile.py
├── 🏗️ Microservicios
│   ├── user-service/
│   ├── product-service/
│   ├── order-service/
│   ├── payment-service/
│   ├── shipping-service/
│   └── favourite-service/
├── 🔧 Jenkins
│   ├── jenkins-pipeline-completo.groovy
│   └── jenkins.Dockerfile
└── 📋 Documentación
    ├── README.md
    └── README-TALLER-2.md
```

</details>


