#!/bin/bash

echo "🚀 Configurando Jenkins desde CERO con Docker"
echo "=============================================="

# Función para mostrar estado
show_status() {
    echo ""
    echo "📊 Estado actual:"
    echo "- Jenkins: $(docker ps --filter name=jenkins-server --format 'table {{.Status}}' | tail -n +2 || echo 'No ejecutándose')"
    echo "- Docker: $(docker --version | cut -d' ' -f3 | cut -d',' -f1)"
    echo ""
}

# Paso 1: Limpiar instalación anterior
echo "🧹 Paso 1: Limpiando instalación anterior..."
docker stop jenkins-server 2>/dev/null || true
docker rm jenkins-server 2>/dev/null || true
docker volume rm jenkins_home 2>/dev/null || true
docker rmi jenkins-mvp 2>/dev/null || true

# Paso 2: Construir imagen personalizada
echo "🔨 Paso 2: Construyendo imagen Jenkins personalizada..."
docker build -f jenkins.Dockerfile -t jenkins-mvp . || {
    echo "❌ Error construyendo imagen Jenkins"
    exit 1
}

# Paso 3: Iniciar Jenkins
echo "🚀 Paso 3: Iniciando Jenkins con configuración automática..."
docker run -d \
  --name jenkins-server \
  -p 8081:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd):/workspace \
  -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" \
  jenkins-mvp || {
    echo "❌ Error iniciando Jenkins"
    exit 1
}

# Paso 4: Esperar que Jenkins inicie
echo "⏳ Paso 4: Esperando que Jenkins inicie completamente..."
echo "Esto puede tomar 2-3 minutos..."

# Esperar hasta que Jenkins responda
for i in {1..60}; do
    if curl -s http://localhost:8081 > /dev/null 2>&1; then
        echo "✅ Jenkins respondiendo en puerto 8081"
        break
    fi
    echo -n "."
    sleep 5
done

# Verificar que Jenkins esté funcionando
if ! curl -s http://localhost:8081 > /dev/null 2>&1; then
    echo "❌ Jenkins no responde después de 5 minutos"
    echo "📋 Logs de Jenkins:"
    docker logs jenkins-server
    exit 1
fi

# Paso 5: Verificar Docker en Jenkins
echo "🐳 Paso 5: Verificando Docker en Jenkins..."
sleep 10
docker exec jenkins-server docker ps > /dev/null 2>&1 || {
    echo "❌ Docker no funciona en Jenkins"
    exit 1
}

# Paso 6: Mostrar información de acceso
echo ""
echo "🎉 ¡JENKINS CONFIGURADO EXITOSAMENTE!"
echo "====================================="
echo ""
echo "🌐 URL: http://localhost:8081"
echo "👤 Usuario: admin"
echo "🔐 Contraseña: admin123"
echo ""
echo "🐳 Docker: ✅ Funcionando"
echo "🔧 Maven: ✅ Configurado"
echo "🔌 Plugins: ✅ Instalados automáticamente"
echo ""

# Mostrar estado final
show_status

echo "📋 PRÓXIMOS PASOS:"
echo "1. Abrir http://localhost:8081 en tu navegador"
echo "2. Iniciar sesión con admin/admin123"
echo "3. Crear un nuevo Pipeline job"
echo "4. Configurar con tu repositorio:"
echo "   - Repository URL: https://github.com/Svak-in-ML/ecommerce-microservice-backend-app-2.git"
echo "   - Script Path: user-service/Jenkinsfile"
echo "5. ¡Ejecutar el pipeline!"
echo ""
echo "🔧 Comandos útiles:"
echo "- Ver logs: docker logs jenkins-server"
echo "- Reiniciar: docker restart jenkins-server"
echo "- Parar: docker stop jenkins-server"
echo ""
echo "✅ ¡Listo para probar tu pipeline con Docker!" 