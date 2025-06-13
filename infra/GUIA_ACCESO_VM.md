# Guía de Acceso a VM en Google Cloud

## 🔧 Opción 1: Google Cloud Console (Más Fácil)

### Paso 1: Ir a Google Cloud Console
1. Abre https://console.cloud.google.com
2. Ve a "Compute Engine" > "VM instances"
3. Busca tu VM (dev-microservices-vm, stage-microservices-vm, etc.)
4. Haz clic en el botón "SSH" al lado de la instancia

### Ventajas:
- ✅ No necesita configurar claves SSH
- ✅ Funciona inmediatamente
- ✅ Acceso directo desde el navegador
- ✅ Google se encarga de la autenticación

---

## 🔧 Opción 2: Habilitar OS Login con gcloud (Recomendado para CLI)

### Paso 1: Configurar gcloud
```bash
# Autenticarse con Google Cloud
gcloud auth login

# Configurar el proyecto
gcloud config set project 682948479106

# Añadir tu clave SSH a tu cuenta
gcloud compute os-login ssh-keys add --key-file="C:\Users\pinil\.ssh\id_ed25519.pub"
```

### Paso 2: Conectarse usando gcloud
```bash
# Obtener el comando SSH correcto
gcloud compute ssh dev-microservices-vm --zone=us-central1-a

# O para otras VMs
gcloud compute ssh stage-microservices-vm --zone=us-central1-b
gcloud compute ssh prod-microservices-vm --zone=us-central1-c
```

---

## 🔧 Opción 3: Deshabilitar OS Login (Para usar usuarios locales)

### ¿Qué necesitamos cambiar en Terraform?

En el módulo de VM, necesitamos:
1. Deshabilitar OS Login
2. Configurar usuarios locales
3. Habilitar autenticación por contraseña

### Cambios requeridos:
```hcl
metadata = {
  enable-oslogin = "FALSE"  # Crucial
  startup-script = "script que configure usuario/contraseña"
}
```

---

## ❌ ¿Por qué no funciona la autenticación por contraseña?

Google Cloud deshabilita la autenticación SSH por contraseña por defecto debido a:

1. **Políticas de seguridad**: Las contraseñas son menos seguras que las claves SSH
2. **OS Login**: Sistema de Google que gestiona usuarios automáticamente
3. **Configuración de SSH por defecto**: PasswordAuthentication está deshabilitada

---

## ✅ Recomendación Inmediata

**Para acceso rápido:** Usa Google Cloud Console
1. Ve a console.cloud.google.com
2. Compute Engine > VM instances  
3. Haz clic en "SSH" al lado de tu VM

**Para automatización:** Usa gcloud compute ssh

¿Cuál prefieres que configuremos?
