# Infraestructura de Microservicios con Terraform

Esta infraestructura despliega un conjunto de microservicios en Google Cloud Platform utilizando Terraform.

## Características Principales

- **Autenticación por Usuario/Contraseña**: Las VMs utilizan autenticación por usuario y contraseña en lugar de claves SSH
- **Múltiples Entornos**: dev, stage, y prod con configuraciones específicas
- **Microservicios Containerizados**: Cada servicio se ejecuta en Docker
- **Networking Seguro**: VPCs dedicadas por entorno con firewalls configurados

## Estructura de Directorios

```
infra/
├── versions.tf                 # Versiones de providers
├── modules/
│   ├── network/               # Módulo de red (VPC, subnets, firewall)
│   └── microservice-vm/       # Módulo de VM para microservicios
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── startup.sh
│       └── user-data.sh
└── enviroments/
    ├── dev/                   # Entorno de desarrollo
    ├── stage/                 # Entorno de staging
    └── prod/                  # Entorno de producción
        ├── main.tf
        ├── variables.tf
        ├── terraform.tfvars
        ├── backend.tf
        └── outputs.tf
```

## Configuración por Entorno

### Desarrollo (dev)
- **Usuario**: `devuser`
- **Zona**: `us-central1-a`
- **Red**: `10.0.0.0/24`
- **Máquina**: `e2-standard-4`
- **Disco**: 100GB

### Staging (stage)
- **Usuario**: `stageuser`
- **Zona**: `us-central1-b`
- **Red**: `10.1.0.0/24`
- **Máquina**: `e2-standard-4`
- **Disco**: 120GB

### Producción (prod)
- **Usuario**: `produser`
- **Zona**: `us-central1-c`
- **Red**: `10.2.0.0/24`
- **Máquina**: `e2-standard-8`
- **Disco**: 200GB

## Microservicios Incluidos

1. **auth-service** (Puerto 8001)
2. **orders-service** (Puerto 8002)
3. **products-service** (Puerto 8003)
4. **users-service** (Puerto 8004)
5. **inventory-service** (Puerto 8005)
6. **payment-service** (Puerto 8006)
7. **shipping-service** (Puerto 8007)
8. **analytics-service** (Puerto 8008)
9. **notification-service** (Puerto 8009)
10. **gateway-service** (Puerto 8010)

## Uso

### 1. Configurar Google Cloud SDK

```bash
gcloud auth login
gcloud config set project 682948479106
```

### 2. Desplegar un Entorno

```bash
# Cambiar al directorio del entorno deseado
cd infra/enviroments/dev  # o stage/prod

# Inicializar Terraform
terraform init

# Revisar el plan
terraform plan

# Aplicar cambios
terraform apply
```

### 3. Obtener Credenciales de Acceso

```bash
# Ver la contraseña generada
terraform output -raw vm_password

# Ver la IP externa
terraform output vm_external_ip

# Ver el usuario
terraform output vm_username
```

### 4. Conectarse a la VM

```bash
# SSH con usuario/contraseña
ssh [usuario]@[ip_externa]
# Cuando solicite la contraseña, usar la obtenida del output

# O usando Google Cloud Console con SSH en navegador
```

### 5. Verificar Microservicios

Una vez conectado a la VM:

```bash
# Ver los contenedores ejecutándose
docker ps

# Ver logs de un servicio específico
docker-compose -f /home/[usuario]/microservices/docker-compose.yml logs [nombre_servicio]

# Reiniciar todos los servicios
sudo systemctl restart microservices
```

## Personalización

### Cambiar Configuración de VM

Editar el archivo `terraform.tfvars` del entorno correspondiente:

```hcl
vm_machine_type = "e2-standard-8"  # Cambiar tipo de máquina
vm_disk_size    = 200              # Cambiar tamaño de disco
```

### Agregar Nuevos Microservicios

Editar el array `microservices` en `main.tf`:

```hcl
microservices = [
  { name = "nuevo-service", port = 8011, image = "gcr.io/${var.project_id}/nuevo:latest" },
  # ... otros servicios
]
```

### Configurar IPs Permitidas

Para mayor seguridad, especificar IPs específicas en `terraform.tfvars`:

```hcl
ssh_allowed_ips = ["203.0.113.0/24"]  # Reemplazar con tu IP
```

## Limpieza

Para destruir la infraestructura:

```bash
cd infra/enviroments/[entorno]
terraform destroy
```

## Notas de Seguridad

1. **Cambiar IPs Permitidas**: Por defecto permite acceso desde cualquier IP (0.0.0.0/0)
2. **Contraseñas Seguras**: Se generan automáticamente contraseñas de 16-20 caracteres
3. **Usuarios No Root**: Cada entorno usa un usuario específico sin privilegios de root
4. **Firewall**: Solo los puertos necesarios están abiertos

## Solución de Problemas

### Error de Permisos
```bash
# Si hay problemas de permisos con Docker
sudo usermod -aG docker $USER
sudo systemctl restart docker
```

### Servicios No Iniciados
```bash
# Verificar estado del servicio
sudo systemctl status microservices

# Reiniciar servicios
sudo systemctl restart microservices
```

### Conectividad
```bash
# Verificar puertos abiertos
sudo netstat -tlnp | grep :80

# Verificar firewall de GCP en la consola web
```
