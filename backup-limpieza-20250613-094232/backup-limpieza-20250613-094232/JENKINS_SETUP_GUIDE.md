# Guía de Configuración de Jenkins - MVP E-commerce Microservices

## 🚀 Estado Actual
✅ Jenkins está ejecutándose en: http://localhost:8081  
🔐 Password inicial: `dc6f56304d314b05978a1e08eb1699bf`  
✅ Versión: Jenkins 2.440.3-lts (problemas de plugins resueltos)

## 📋 Configuración Inicial de Jenkins

### 1. Acceso Inicial
1. Abrir http://localhost:8081 en el navegador
2. Usar la contraseña inicial: `dc6f56304d314b05978a1e08eb1699bf`
3. Seleccionar "Install suggested plugins" - ✅ Todos los plugins ahora cargan correctamente
4. Crear usuario administrador

### 2. Configuración de Herramientas

#### Maven Configuration
1. Ir a `Manage Jenkins` → `Global Tool Configuration`
2. En la sección `Maven`:
   - Hacer clic en "Add Maven"
   - Name: `Maven-3.9.0`
   - Marcar "Install automatically"
   - Seleccionar versión 3.9.0

#### JDK Configuration
1. En la misma página, sección `JDK`:
   - Hacer clic en "Add JDK"
   - Name: `JDK-11`
   - Marcar "Install automatically"
   - Seleccionar "OpenJDK 11"

### 3. Plugins Requeridos
✅ Todos los plugins ahora funcionan correctamente con Jenkins 2.440.3:
- Pipeline ✅
- Docker Pipeline ✅
- Maven Integration Plugin ✅
- JUnit Plugin ✅
- JaCoCo Plugin ✅
- Blue Ocean (recomendado) ✅

## 🔧 Crear el Primer Pipeline - User Service

### 1. Crear Nuevo Job
1. En el dashboard de Jenkins, hacer clic en "New Item"
2. Nombre: `user-service-pipeline`
3. Seleccionar "Pipeline"
4. Hacer clic en "OK"

### 2. Configurar Pipeline
1. En la configuración del job:
   - **Description**: "Pipeline CI/CD para User Service"
   - **Pipeline Definition**: "Pipeline script from SCM"
   - **SCM**: Git
   - **Repository URL**: Ruta local o URL del repositorio
   - **Script Path**: `user-service/Jenkinsfile`

### 3. Ejecutar Pipeline
1. Hacer clic en "Build Now"
2. Monitorear la ejecución en "Console Output"

## 📊 Estructura del Pipeline Actual

El pipeline incluye las siguientes etapas:

1. **Checkout**: Obtener código fuente
2. **Build**: Compilar la aplicación
3. **Test**: Ejecutar pruebas unitarias
4. **Package**: Crear JAR
5. **Docker Build**: Construir imagen Docker
6. **Archive Artifacts**: Guardar artefactos

## 🧪 Pruebas Unitarias Agregadas

Se han agregado 5 pruebas unitarias para el UserService:
- ✅ `testFindAll_Success`: Verifica obtener todos los usuarios
- ✅ `testFindById_Success`: Verifica obtener usuario por ID
- ✅ `testFindById_UserNotFound`: Verifica manejo de usuario no encontrado
- ✅ `testSave_Success`: Verifica guardar usuario
- ✅ `testUpdate_Success`: Verifica actualizar usuario
- ✅ `testDeleteById_Success`: Verifica eliminar usuario

## 🐛 Solución de Problemas Comunes

### ✅ RESUELTO: Plugin Dependency Errors
**Problema**: Plugins requerían Jenkins 2.440.3 o superior  
**Solución**: Actualizado Jenkins a versión 2.440.3-lts

### Error: Maven no encontrado
- Verificar configuración de Maven en Global Tool Configuration
- Asegurar que el nombre coincida con el Jenkinsfile (`Maven-3.9.0`)

### Error: JDK no encontrado
- Verificar configuración de JDK en Global Tool Configuration
- Asegurar que el nombre coincida con el Jenkinsfile (`JDK-11`)

### Error: Docker no disponible
- Verificar que Docker esté ejecutándose
- Verificar que el socket de Docker esté montado correctamente

## 📈 Próximos Pasos

1. ✅ Configurar Jenkins básico
2. ✅ Crear pipeline para user-service
3. ✅ Agregar pruebas unitarias (5 pruebas)
4. 🔄 Agregar pruebas de integración
5. 🔄 Configurar Kubernetes
6. 🔄 Agregar más microservicios

## 🛠️ Comandos Útiles

```bash
# Iniciar Jenkins
./start-jenkins.sh

# Reiniciar Jenkins (después de cambios)
./restart-jenkins.sh

# Probar user-service localmente
./test-user-service.sh

# Ver logs de Jenkins
docker-compose -f docker-compose.jenkins.yml logs jenkins

# Parar Jenkins
docker-compose -f docker-compose.jenkins.yml down

# Ver contenedores activos
docker ps
```

## 📝 Notas Importantes

- ✅ Jenkins actualizado a versión 2.440.3-lts
- ✅ Todos los problemas de dependencias de plugins resueltos
- Jenkins está configurado para usar Docker-in-Docker
- Los volúmenes persisten los datos de Jenkins
- El workspace está montado en `/workspace` dentro del contenedor
- Puerto 8081 para evitar conflictos con otros servicios
- JaCoCo configurado para reportes de cobertura de código 