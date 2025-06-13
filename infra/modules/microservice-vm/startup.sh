#!/bin/bash
set -e

# Instalar dependencias
apt-get update -y
apt-get install -y docker.io docker-compose git

# Agregar usuario al grupo docker
usermod -aG docker ${ssh_user}

# Clonar el repositorio de scripts
cd /home/${ssh_user}
git clone https://github.com/tu_usuario/tu_repo_scripts.git || true
cd tu_repo_scripts

# Dar permisos de ejecución a todos los scripts
chmod +x *.sh

# Ejecutar el script principal
./1-setup-completo.sh