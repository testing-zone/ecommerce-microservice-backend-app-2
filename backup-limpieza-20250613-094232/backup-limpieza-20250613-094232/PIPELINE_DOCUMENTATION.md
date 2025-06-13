# Documentación de Pipelines - E-commerce Microservices

## Taller 2: Pruebas y Lanzamiento

### Resumen Ejecutivo

Este documento presenta la implementación completa de pipelines CI/CD para 6 microservicios del sistema e-commerce, incluyendo pruebas unitarias, de integración, E2E y de rendimiento, junto con despliegues automatizados a Kubernetes.

---

## 1. Microservicios Seleccionados

Los siguientes microservicios fueron seleccionados por su interdependencia y funcionalidades core:

### 1.1 Microservicios Principales
- **user-service** (Puerto 8081) - Gestión de usuarios y autenticación
- **product-service** (Puerto 8082) - Catálogo de productos
- **order-service** (Puerto 8083) - Gestión de órdenes
- **payment-service** (Puerto 8084) - Procesamiento de pagos
- **shipping-service** (Puerto 8085) - Gestión de envíos
- **favourite-service** (Puerto 8086) - Favoritos de usuarios

### 1.2 Servicios de Apoyo
- **service-discovery** (Puerto 8761) - Eureka Server
- **api-gateway** (Puerto 8080) - Gateway principal
- **cloud-config** (Puerto 8888) - Configuración centralizada

---

## 2. Arquitectura de Pipelines

### 2.1 Estructura de Pipelines por Ambiente

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Development   │    │     Staging     │    │   Production    │
│    (develop)    │    │   (staging)     │    │    (master)     │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ • Unit Tests    │    │ • Integration   │    │ • Full Test     │
│ • Build         │    │ • E2E Tests     │    │   Suite         │
│ • Docker Build  │    │ • Performance   │    │ • Manual        │
│ • Deploy to K8s │    │ • Security      │    │   Approval      │
│ • Basic Tests   │    │ • Deploy        │    │ • Blue-Green    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### 2.2 Fases de Pipeline

#### Fase 1: Verificación y Construcción
- **Verify Environment**: Validación de herramientas (Java, Maven, Docker, kubectl)
- **Checkout**: Obtención del código fuente
- **Unit Tests**: Ejecución de pruebas unitarias
- **Build Application**: Compilación y empaquetado

#### Fase 2: Calidad y Seguridad
- **Code Quality Analysis**: Checkstyle, SonarQube
- **Integration Tests**: Pruebas de integración entre servicios
- **Security Scan**: Análisis de vulnerabilidades

#### Fase 3: Containerización
- **Docker Build**: Construcción de imágenes multi-stage
- **Image Security Scan**: Escaneo de vulnerabilidades en imágenes
- **Registry Push**: Subida a registry de contenedores

#### Fase 4: Despliegue y Validación
- **Deploy to Environment**: Despliegue a Kubernetes
- **Health Checks**: Validación de salud de servicios
- **E2E Tests**: Pruebas end-to-end
- **Performance Tests**: Pruebas de carga con Locust

#### Fase 5: Liberación y Documentación
- **Release Notes Generation**: Generación automática de notas de liberación
- **Artifacts Archive**: Archivado de artefactos
- **Notifications**: Notificaciones por email/Slack

---

## 3. Configuración de Pruebas

### 3.1 Pruebas Unitarias (5 nuevas implementadas)

#### ProductServiceTest
```java
@ExtendWith(MockitoExtension.class)
@DisplayName("Product Service Unit Tests")
class ProductServiceTest {
    // Pruebas para validación de inventario
    // Gestión de productos
    // Búsqueda y filtrado
}
```

#### OrderServiceTest
```java
@ExtendWith(MockitoExtension.class)
@DisplayName("Order Service Unit Tests")
class OrderServiceTest {
    // Procesamiento de órdenes
    // Validación de datos
    // Estados de orden
}
```

### 3.2 Pruebas de Integración (5 nuevas implementadas)

#### EcommerceIntegrationTest
```java
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class EcommerceIntegrationTest {
    // Comunicación user-service <-> product-service
    // Flujo completo de órdenes
    // Integración con favoritos
    // Validación de disponibilidad
}
```

### 3.3 Pruebas E2E (5 nuevas implementadas)

#### EcommerceE2ETest
```java
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
@DisplayName("E-commerce End-to-End Tests")
class EcommerceE2ETest {
    // Registro y autenticación completa
    // Gestión de catálogo de productos
    // Flujo de compra completo
    // Procesamiento de pagos y envíos
    // Experiencia de usuario con favoritos
}
```

### 3.4 Pruebas de Rendimiento con Locust

#### Configuración de Carga
```python
class EcommerceLoadTest(HttpUser):
    wait_time = between(1, 3)
    
    # Usuarios normales (80%)
    # Administradores (10%)
    # Pruebas de estrés (10%)
```

#### Métricas Monitoreadas
- **Tiempo de respuesta promedio**: < 200ms
- **Throughput**: > 100 requests/segundo
- **Tasa de errores**: < 1%
- **Percentil 95**: < 500ms
- **Capacidad máxima**: 1000 usuarios concurrentes

---

## 4. Configuración de Kubernetes

### 4.1 Namespaces por Ambiente
```yaml
# Development
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce
  labels:
    environment: development

# Staging
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce-staging
  labels:
    environment: staging

# Production
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce-prod
  labels:
    environment: production
```

### 4.2 Recursos por Servicio
```yaml
resources:
  requests:
    memory: "256Mi"
    cpu: "200m"
  limits:
    memory: "512Mi"
    cpu: "500m"
```

### 4.3 Health Checks
```yaml
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8082
  initialDelaySeconds: 30
  periodSeconds: 30

readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8082
  initialDelaySeconds: 20
  periodSeconds: 10
```

---

## 5. Estrategias de Despliegue

### 5.1 Rolling Deployment (Desarrollo/Staging)
- Actualizaciones graduales sin downtime
- Rollback automático en caso de falla
- Validación de salud durante el despliegue

### 5.2 Blue-Green Deployment (Producción)
- Ambiente completamente separado
- Cambio instantáneo de tráfico
- Rollback inmediato disponible

### 5.3 Canary Deployment (Funcionalidades específicas)
- Liberación gradual de tráfico
- Monitoreo de métricas en tiempo real
- Decisión automática de promoción/rollback

---

## 6. Monitoreo y Observabilidad

### 6.1 Métricas de Pipeline
- **Tiempo de ejecución total**: < 15 minutos
- **Tiempo de pruebas**: < 5 minutos
- **Tiempo de construcción**: < 3 minutos
- **Tasa de éxito**: > 95%

### 6.2 Métricas de Aplicación
```yaml
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus
  metrics:
    export:
      prometheus:
        enabled: true
```

### 6.3 Logging Centralizado
```yaml
logging:
  level:
    com.selimhorri: DEBUG
  pattern:
    console: "%d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n"
```

---

## 7. Seguridad

### 7.1 Secrets Management
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: service-secrets
type: Opaque
data:
  database-username: <base64-encoded>
  database-password: <base64-encoded>
```

### 7.2 Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### 7.3 RBAC
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pipeline-role
rules:
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "patch"]
```

---

## 8. Release Management

### 8.1 Versionado Semántico
- **MAJOR**: Cambios incompatibles de API
- **MINOR**: Funcionalidades compatibles hacia atrás
- **PATCH**: Correcciones de bugs

### 8.2 Generación Automática de Release Notes
```groovy
def generateReleaseNotes() {
    script {
        def releaseNotes = """
# ${SERVICE_NAME} Release Notes - v${PROJECT_VERSION}.${BUILD_NUMBER}

**Release Date:** ${new Date().format('yyyy-MM-dd HH:mm:ss')}
**Build Number:** ${BUILD_NUMBER}
**Git Commit:** ${env.GIT_COMMIT}

## Changes in this Release
- Feature implementations
- Bug fixes
- Performance improvements

## Test Results
- Unit Tests: ${unitTestResults}
- Integration Tests: ${integrationTestResults}
- E2E Tests: ${e2eTestResults}
- Performance Tests: ${performanceTestResults}

## Deployment Information
- Environment: ${deploymentEnvironment}
- Namespace: ${K8S_NAMESPACE}
- Docker Image: ${DOCKER_IMAGE}:${DOCKER_TAG}

## Rollback Instructions
kubectl rollout undo deployment/${SERVICE_NAME} -n ${K8S_NAMESPACE}
        """
        
        writeFile file: 'RELEASE_NOTES.md', text: releaseNotes
        archiveArtifacts artifacts: 'RELEASE_NOTES.md'
    }
}
```

---

## 9. Procedimientos de Emergencia

### 9.1 Rollback de Producción
```bash
# Rollback automático
kubectl rollout undo deployment/service-name -n ecommerce-prod

# Rollback a versión específica
kubectl rollout undo deployment/service-name --to-revision=2 -n ecommerce-prod

# Verificar estado
kubectl rollout status deployment/service-name -n ecommerce-prod
```

### 9.2 Escalado de Emergencia
```bash
# Escalar horizontalmente
kubectl scale deployment service-name --replicas=10 -n ecommerce-prod

# Escalar verticalmente (actualizar recursos)
kubectl patch deployment service-name -p '{"spec":{"template":{"spec":{"containers":[{"name":"service-name","resources":{"limits":{"cpu":"1000m","memory":"1Gi"}}}]}}}}' -n ecommerce-prod
```

---

## 10. Métricas de Éxito

### 10.1 KPIs de Pipeline
- **Mean Time to Recovery (MTTR)**: < 10 minutos
- **Deployment Frequency**: 2-3 veces por día
- **Lead Time**: < 2 horas
- **Change Failure Rate**: < 5%

### 10.2 KPIs de Aplicación
- **Uptime**: > 99.9%
- **Response Time**: < 200ms (P95)
- **Error Rate**: < 0.1%
- **Throughput**: > 1000 RPS

---

## 11. Próximos Pasos

### 11.1 Mejoras Planificadas
- [ ] Implementar GitOps con ArgoCD
- [ ] Configurar Istio Service Mesh
- [ ] Integrar herramientas de seguridad (Vault, OPA)
- [ ] Implementar Chaos Engineering
- [ ] Configurar observabilidad completa (Prometheus + Grafana + Jaeger)

### 11.2 Automatizaciones Adicionales
- [ ] Auto-scaling basado en métricas
- [ ] Self-healing de servicios
- [ ] Disaster recovery automatizado
- [ ] Compliance y auditoría automatizada

---

## 12. Contactos y Soporte

### 12.1 Equipo DevOps
- **Lead DevOps Engineer**: devops-lead@company.com
- **Platform Engineer**: platform@company.com
- **SRE Team**: sre@company.com

### 12.2 Documentación Adicional
- [Runbooks](./runbooks/)
- [Troubleshooting Guide](./TROUBLESHOOTING.md)
- [API Documentation](./api-docs/)
- [Architecture Diagrams](./diagrams/)

---

*Documento generado automáticamente por el sistema de CI/CD - Última actualización: [FECHA]* 