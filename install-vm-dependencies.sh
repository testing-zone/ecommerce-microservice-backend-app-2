#!/bin/bash

echo "🚀 INSTALADOR AUTOMÁTICO DE DEPENDENCIAS - E-COMMERCE VM"
echo "========================================================"
echo ""
echo "Este script instalará todas las dependencias necesarias:"
echo "• Docker & Docker Compose"
echo "• Minikube & kubectl"
echo "• Java 11 & Maven"
echo "• Herramientas adicionales"
echo ""

# Función para mostrar progreso
show_progress() {
    local step=$1
    local total=$2
    local description=$3
    echo ""
    echo "📦 PASO $step/$total: $description"
    echo "=================================="
}

# Función para verificar si el comando fue exitoso
check_success() {
    if [ $? -eq 0 ]; then
        echo "✅ Completado exitosamente"
    else
        echo "❌ Error en la instalación"
        exit 1
    fi
}

# Detectar el sistema operativo
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    else
        OS=$(uname -s)
        VER=$(uname -r)
    fi
    
    echo "🔍 Sistema detectado: $OS $VER"
}

# PASO 1: Actualizar sistema
show_progress 1 8 "Actualizando sistema base"
detect_os

if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    sudo apt update && sudo apt upgrade -y
    sudo apt install -y curl wget git unzip vim htop lsof net-tools
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    sudo yum update -y
    sudo yum install -y curl wget git unzip vim htop lsof net-tools
else
    echo "⚠️  Sistema no reconocido, instalación manual requerida"
fi
check_success

# PASO 2: Instalar Docker
show_progress 2 8 "Instalando Docker"

# Remover versiones anteriores
sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null

# Instalar Docker usando el script oficial
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
rm get-docker.sh

# Agregar usuario al grupo docker
sudo usermod -aG docker $USER

# Iniciar y habilitar Docker
sudo systemctl start docker
sudo systemctl enable docker

echo "✅ Docker instalado. Nota: Cierra y abre nueva sesión para usar Docker sin sudo"

# PASO 3: Instalar kubectl
show_progress 3 8 "Instalando kubectl"

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

check_success

# PASO 4: Instalar Minikube
show_progress 4 8 "Instalando Minikube"

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

check_success

# PASO 5: Instalar Java 11
show_progress 5 8 "Instalando Java 11 y configurando JAVA_HOME"

if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    sudo apt install -y openjdk-11-jdk
    JAVA_PATH="/usr/lib/jvm/java-11-openjdk-amd64"
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    sudo yum install -y java-11-openjdk-devel
    JAVA_PATH="/usr/lib/jvm/java-11-openjdk"
fi

# Configurar JAVA_HOME
echo "export JAVA_HOME=$JAVA_PATH" >> ~/.bashrc
echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> ~/.bashrc

check_success

# PASO 6: Instalar Maven
show_progress 6 8 "Instalando Maven"

if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    sudo apt install -y maven
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    sudo yum install -y maven
fi

check_success

# PASO 7: Instalar herramientas adicionales
show_progress 7 8 "Instalando herramientas adicionales"

if [[ "$OS" == *"Ubuntu"* ]] || [[ "$OS" == *"Debian"* ]]; then
    sudo apt install -y jq tree htop iotop
elif [[ "$OS" == *"CentOS"* ]] || [[ "$OS" == *"Red Hat"* ]]; then
    sudo yum install -y jq tree htop iotop
fi

check_success

# PASO 8: Configurar Minikube
show_progress 8 8 "Configurando Minikube con recursos óptimos"

# Configurar Minikube para usar recursos adecuados
minikube config set memory 8192
minikube config set cpus 4
minikube config set disk-size 30g
minikube config set driver docker

echo "✅ Minikube configurado con:"
echo "   • Memoria: 8GB"
echo "   • CPUs: 4"
echo "   • Disco: 30GB"
echo "   • Driver: Docker"

# CONFIGURACIÓN FINAL
echo ""
echo "🎉 INSTALACIÓN COMPLETADA!"
echo "========================="
echo ""
echo "📋 RESUMEN DE INSTALACIÓN:"
echo "├─ ✅ Docker instalado y configurado"
echo "├─ ✅ kubectl instalado"
echo "├─ ✅ Minikube instalado y configurado"
echo "├─ ✅ Java 11 instalado"
echo "├─ ✅ Maven instalado"
echo "└─ ✅ Herramientas adicionales instaladas"

echo ""
echo "⚠️  IMPORTANTE - SIGUIENTE PASO:"
echo "1. Cierra esta sesión terminal"
echo "2. Abre una nueva sesión (para aplicar permisos Docker)"
echo "3. Ejecuta: source ~/.bashrc"
echo "4. Verifica instalación: ./check-prerequisites.sh"

echo ""
echo "🚀 COMANDOS PARA INICIAR:"
echo "========================"
echo ""
echo "# 1. Verificar prerequisitos"
echo "./check-prerequisites.sh"
echo ""
echo "# 2. Iniciar Minikube"
echo "minikube start"
echo ""
echo "# 3. Verificar estado"
echo "minikube status"
echo "kubectl cluster-info"
echo ""
echo "# 4. Ejecutar despliegue completo"
echo "./ecommerce-manager.sh"

echo ""
echo "📚 RECURSOS ÚTILES:"
echo "==================="
echo "• Guía completa: cat GUIA-VM-COMPLETA.md"
echo "• Verificar sistema: ./check-prerequisites.sh"
echo "• Scripts disponibles: ls -la *.sh"

echo ""
echo "🔧 TROUBLESHOOTING:"
echo "=================="
echo "• Si Docker da permisos: sudo usermod -aG docker \$USER && newgrp docker"
echo "• Si Java no funciona: source ~/.bashrc"
echo "• Si Minikube falla: minikube delete && minikube start"

echo ""
echo "🎯 ¡Instalación automática completada!"
echo "   Ejecuta los comandos de siguiente paso para continuar." 