#!/bin/bash

echo "🚀 Configurando Jenkins con Docker + kubectl"
echo "==========================================="

echo "🧹 Paso 1: Limpiando instalación anterior..."
docker stop jenkins-server 2>/dev/null || true
docker rm jenkins-server 2>/dev/null || true
docker volume rm jenkins_home 2>/dev/null || true

echo "🔨 Paso 2: Construyendo imagen con kubectl..."
docker build -f jenkins.Dockerfile -t jenkins-with-kubectl . || {
    echo "❌ Error construyendo imagen Jenkins con kubectl"
    exit 1
}

echo "🐳 Paso 3: Iniciando Jenkins con kubectl..."
docker run -d --name jenkins-server \
  --privileged \
  -p 8081:8080 \
  -e JENKINS_USER=root \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  -v ~/.kube:/var/jenkins_home/.kube \
  -v ~/.minikube:/var/jenkins_home/.minikube \
  jenkins-with-kubectl

echo "⏳ Paso 4: Esperando que Jenkins inicie completamente..."
echo "Esto puede tomar 2-3 minutos..."

# Esperar a que Jenkins responda
for i in {1..30}; do
    if curl -s -o /dev/null -w "%{http_code}" http://localhost:8081 | grep -q "403\|200"; then
        echo "✅ Jenkins respondiendo en puerto 8081"
        break
    fi
    echo -n "."
    sleep 5
done

echo ""
echo "🔐 Paso 5: Obteniendo contraseña inicial..."
sleep 10
JENKINS_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "No disponible aún")

echo "☸️ Paso 6: Configurando permisos de Kubernetes..."
docker exec jenkins-server chown -R jenkins:jenkins /var/jenkins_home/.kube /var/jenkins_home/.minikube 2>/dev/null || true

echo ""
echo "🎉 ¡JENKINS CON KUBECTL CONFIGURADO!"
echo "=================================="
echo ""
echo "🌐 URL: http://localhost:8081"
echo "🔐 Contraseña inicial: $JENKINS_PASSWORD"
echo ""
echo "✅ Características habilitadas:"
echo "- Docker builds"
echo "- kubectl para Kubernetes"
echo "- Acceso a cluster Minikube"
echo ""
echo "📋 SETUP INICIAL REQUERIDO:"
echo "1. Abrir http://localhost:8081 en tu navegador"
echo "2. Usar la contraseña: $JENKINS_PASSWORD"
echo "3. Instalar plugins sugeridos"
echo "4. Crear usuario admin"
echo "5. Configurar URL de Jenkins"
echo ""
echo "🔌 PLUGINS NECESARIOS:"
echo "- Git, Pipeline, Docker Pipeline"
echo "- Maven Integration, JUnit"
echo "- Build Timeout, Timestamper"
echo ""
echo "📊 Estado actual:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep jenkins
echo ""
echo "🔧 Comandos útiles:"
echo "- Ver logs: docker logs jenkins-server"
echo "- Test kubectl: docker exec jenkins-server kubectl version --client"
echo "- Obtener password: docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword"
echo ""
echo "⚠️ NOTA: Este script es para pipelines con deployment automático a K8s"
echo "   Si solo necesitas CI (build/test), usa setup-jenkins.sh" 