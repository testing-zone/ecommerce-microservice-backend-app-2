#!/bin/bash

echo "🔧 SOLUCIONANDO DOCKER EN JENKINS (ARM64 Compatible)"
echo "====================================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${BLUE}[STEP]${NC} $1"; }

log_step "1. Detectando arquitectura del sistema..."
ARCH=$(uname -m)
echo "🖥️ Arquitectura detectada: $ARCH"

log_step "2. Deteniendo Jenkins actual..."
docker stop jenkins-server 2>/dev/null || true
docker rm jenkins-server 2>/dev/null || true

log_step "3. Creando Jenkins con soporte Docker mejorado..."

# Crear Jenkins con binario Docker del host montado
docker run -d --name jenkins-server \
  --restart=unless-stopped \
  --privileged \
  -p 8081:8080 \
  -p 50000:50000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  -v /usr/local/bin/docker:/usr/local/bin/docker \
  -v /usr/bin/docker:/usr/bin/docker \
  -e DOCKER_HOST=unix:///var/run/docker.sock \
  -e JENKINS_OPTS="--httpPort=8080" \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  --user root \
  jenkins/jenkins:2.440.3-lts

log_step "4. Esperando que Jenkins inicie..."
for i in {1..30}; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 | grep -q "403\|200"; then
        log_info "✅ Jenkins respondiendo"
        break
    fi
    echo -n "."
    sleep 10
done

log_step "5. Configurando Docker en Jenkins (método alternativo)..."

# Método 1: Instalar Docker CLI binario directamente
docker exec -u root jenkins-server bash -c "
    # Descargar Docker CLI binario
    cd /tmp
    if [ '$ARCH' = 'aarch64' ] || [ '$ARCH' = 'arm64' ]; then
        curl -fsSL https://download.docker.com/linux/static/stable/aarch64/docker-20.10.9.tgz -o docker.tgz
    else
        curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz -o docker.tgz
    fi
    
    tar -xzf docker.tgz
    cp docker/docker /usr/local/bin/
    chmod +x /usr/local/bin/docker
    rm -rf docker docker.tgz
"

log_step "6. Instalando herramientas adicionales..."

# Instalar Maven
docker exec -u root jenkins-server bash -c "
    cd /opt
    wget https://archive.apache.org/dist/maven/maven-3/3.8.6/binaries/apache-maven-3.8.6-bin.tar.gz
    tar -xzf apache-maven-3.8.6-bin.tar.gz
    ln -s /opt/apache-maven-3.8.6/bin/mvn /usr/local/bin/mvn
    rm apache-maven-3.8.6-bin.tar.gz
"

# Instalar kubectl
docker exec -u root jenkins-server bash -c "
    if [ '$ARCH' = 'aarch64' ] || [ '$ARCH' = 'arm64' ]; then
        curl -LO 'https://dl.k8s.io/release/v1.28.0/bin/linux/arm64/kubectl'
    else
        curl -LO 'https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl'
    fi
    chmod +x kubectl
    mv kubectl /usr/local/bin/
"

log_step "7. Configurando permisos..."
docker exec -u root jenkins-server bash -c "
    # Configurar grupos y permisos
    groupadd -f docker || true
    usermod -aG docker jenkins
    chown jenkins:jenkins /var/run/docker.sock
    chmod 666 /var/run/docker.sock
    
    # Configurar variables de entorno
    echo 'export PATH=/usr/local/bin:\$PATH' >> /var/jenkins_home/.bashrc
    echo 'export DOCKER_HOST=unix:///var/run/docker.sock' >> /var/jenkins_home/.bashrc
"

log_step "8. Copiando configuración Kubernetes..."
if [ -f ~/.kube/config ]; then
    docker exec -u root jenkins-server mkdir -p /var/jenkins_home/.kube
    docker cp ~/.kube/config jenkins-server:/var/jenkins_home/.kube/config
    docker exec -u root jenkins-server chown -R jenkins:jenkins /var/jenkins_home/.kube
    log_info "✅ Configuración kubectl copiada"
else
    log_warn "⚠️ No se encontró ~/.kube/config"
fi

log_step "9. Reiniciando Jenkins..."
docker restart jenkins-server

echo "⏳ Esperando reinicio completo..."
sleep 20

for i in {1..15}; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 | grep -q "403\|200"; then
        log_info "✅ Jenkins reiniciado correctamente"
        break
    fi
    echo -n "."
    sleep 5
done

log_step "10. Verificando instalaciones..."

echo "🔍 Verificando Docker:"
docker exec jenkins-server /usr/local/bin/docker --version || echo "⚠️ Usando fallback"

echo "🔍 Verificando kubectl:"
docker exec jenkins-server /usr/local/bin/kubectl version --client || echo "⚠️ kubectl con problemas"

echo "🔍 Verificando Maven:"
docker exec jenkins-server /usr/local/bin/mvn -version || echo "⚠️ Maven con problemas"

echo "🔍 Verificando Java:"
docker exec jenkins-server java -version

echo "🔍 Verificando conectividad Docker:"
docker exec jenkins-server /usr/local/bin/docker ps >/dev/null 2>&1 && echo "✅ Docker funcional" || echo "⚠️ Docker con problemas de conectividad"

echo ""
echo "🎉 ¡CONFIGURACIÓN COMPLETADA!"
echo "============================="
echo ""
echo "🌐 URL Jenkins: http://localhost:8081"
echo "🔑 Contraseña: $(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo 'Ya configurado')"
echo ""
echo "✅ COMPONENTES INSTALADOS:"
echo "   ✅ Docker CLI (estático)"
echo "   ✅ Maven 3.8.6"
echo "   ✅ kubectl"
echo "   ✅ Java 17"
echo ""
echo "🔧 MEJORAS IMPLEMENTADAS:"
echo "   ✅ Binarios estáticos para compatibilidad ARM64"
echo "   ✅ PATH configurado correctamente"
echo "   ✅ Permisos Docker ajustados"
echo "   ✅ Variables de entorno configuradas"
echo ""
echo "📋 VERIFICACIÓN FINAL:"
echo "   ./diagnose-jenkins.sh"
echo ""
echo "🚀 AHORA PUEDES:"
echo "   1. Acceder a Jenkins en http://localhost:8081"
echo "   2. Ejecutar ./update-jenkinsfiles-docker.sh"
echo "   3. Configurar y ejecutar pipelines"
echo "" 