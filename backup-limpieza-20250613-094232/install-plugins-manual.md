# 🔌 Instalación Manual de Plugins

## 📋 Plugins Requeridos para Pipeline

Ve a **Manage Jenkins** → **Manage Plugins** → **Available** y busca estos plugins:

### ✅ Plugins Esenciales:
1. **Pipeline** (o "Pipeline: Groovy")
2. **Git plugin**
3. **Docker Pipeline**
4. **JUnit**
5. **Maven Integration plugin**
6. **Pipeline: Stage View**
7. **Build Timeout**
8. **Timestamper**

### 📝 Pasos:
1. Marca cada plugin en la lista
2. Haz clic en **"Install without restart"**
3. Espera a que se instalen
4. **Reinicia Jenkins** cuando termine

### 🔄 Después de instalar:
1. Ve a **Dashboard**
2. Haz clic en **"New Item"**
3. Deberías ver la opción **"Pipeline"**

## 🚨 Si no aparece "Manage Jenkins":

Significa que el usuario admin no se creó correctamente. Haz esto:

1. Ve a http://localhost:8081
2. Si aparece el wizard de configuración inicial:
   - Usa la contraseña que aparece en los logs
   - Selecciona "Install suggested plugins"
   - Crea un usuario admin
3. Si no aparece el wizard, reinicia Jenkins:
   ```bash
   docker restart jenkins-server
   ``` 