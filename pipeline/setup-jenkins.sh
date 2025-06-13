#!/bin/bash

echo "🚀 Configurando Jenkins ESTABLE con Docker"
echo "=========================================="

echo "🧹 Paso 1: Limpiando instalación anterior..."
docker stop jenkins-server 2>/dev/null || true
docker rm jenkins-server 2>/dev/null || true
docker volume rm jenkins_home 2>/dev/null || true

echo "🐳 Paso 2: Iniciando Jenkins estable..."
docker run -d --name jenkins-server \
  --privileged \
  -p 8081:8080 \
  -e JENKINS_USER=root \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:2.440.3-lts

echo "⏳ Paso 3: Esperando que Jenkins inicie completamente..."
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
echo "🔐 Paso 4: Obteniendo contraseña inicial..."
sleep 10
JENKINS_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "No disponible aún")

echo ""
echo "🎉 ¡JENKINS CONFIGURADO EXITOSAMENTE!"
echo "====================================="
echo ""
echo "🌐 URL: http://localhost:8081"
echo "🔐 Contraseña inicial: $JENKINS_PASSWORD"
echo ""
echo "📋 SETUP INICIAL REQUERIDO:"
echo "1. Abrir http://localhost:8081 en tu navegador"
echo "2. Usar la contraseña: $JENKINS_PASSWORD"
echo "3. Instalar plugins sugeridos"
echo "4. Crear usuario admin"
echo "5. Configurar URL de Jenkins"
echo ""
echo "🔌 PLUGINS NECESARIOS PARA EL PIPELINE:"
echo "- Git"
echo "- Pipeline"
echo "- Docker Pipeline"
echo "- Maven Integration"
echo "- JUnit"
echo "- Build Timeout"
echo "- Timestamper"
echo ""
echo "📊 Estado actual:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep jenkins
echo ""
echo "🔧 Comandos útiles:"
echo "- Ver logs: docker logs jenkins-server"
echo "- Reiniciar: docker restart jenkins-server"
echo "- Parar: docker stop jenkins-server"
echo "- Obtener password: docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword"
echo ""
echo "✅ ¡Listo para configurar tu pipeline!" 