#!/bin/bash

echo "🐳 Restarting Jenkins with Docker support..."

echo "🛑 Stopping current Jenkins containers..."
docker-compose -f docker-compose.jenkins.yml down

echo "🧹 Removing old containers and images..."
docker rm -f jenkins-server jenkins-docker 2>/dev/null || true

echo "🔨 Building custom Jenkins image with Docker..."
docker-compose -f docker-compose.jenkins.yml build --no-cache

echo "🚀 Starting Jenkins with Docker support..."
docker-compose -f docker-compose.jenkins.yml up -d

echo "⏳ Waiting for Jenkins to start..."
sleep 90

echo "🔑 Getting Jenkins initial admin password..."
JENKINS_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "✅ Jenkins with Docker is ready!"
    echo "🌐 Access Jenkins at: http://localhost:8081"
    echo "🔐 Initial admin password: $JENKINS_PASSWORD"
    echo ""
    echo "🐳 Docker verification:"
    docker exec jenkins-server docker --version
    echo ""
    echo "📋 Next steps:"
    echo "1. Open http://localhost:8081 in your browser"
    echo "2. Use the password above to unlock Jenkins"
    echo "3. Docker should now be available in pipelines"
    echo "4. Run your pipeline to test Docker build"
else
    echo "❌ Jenkins failed to start properly. Checking logs..."
    docker-compose -f docker-compose.jenkins.yml logs jenkins
fi

echo ""
echo "🔧 Jenkins now includes Docker CLI and Docker Pipeline plugin"
echo "✅ Ready for Docker builds in pipelines!" 