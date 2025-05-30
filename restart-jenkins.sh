#!/bin/bash

echo "🔄 Restarting Jenkins with updated version..."

echo "🛑 Stopping current Jenkins containers..."
docker-compose -f docker-compose.jenkins.yml down

echo "🧹 Removing old Jenkins containers..."
docker rm -f jenkins-server jenkins-docker 2>/dev/null || true

echo "🐳 Pulling new Jenkins image..."
docker pull jenkins/jenkins:2.440.3-lts

echo "🚀 Starting Jenkins with new version..."
docker-compose -f docker-compose.jenkins.yml up -d

echo "⏳ Waiting for Jenkins to start..."
sleep 60

echo "🔑 Getting Jenkins initial admin password..."
JENKINS_PASSWORD=$(docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)

if [ $? -eq 0 ]; then
    echo "✅ Jenkins is ready!"
    echo "🌐 Access Jenkins at: http://localhost:8081"
    echo "🔐 Initial admin password: $JENKINS_PASSWORD"
    echo ""
    echo "📋 Next steps:"
    echo "1. Open http://localhost:8081 in your browser"
    echo "2. Use the password above to unlock Jenkins"
    echo "3. All plugins should now load correctly with Jenkins 2.440.3"
    echo "4. Install suggested plugins"
    echo "5. Create an admin user"
    echo "6. Configure tools (Maven, JDK)"
else
    echo "❌ Jenkins failed to start properly. Checking logs..."
    docker-compose -f docker-compose.jenkins.yml logs jenkins
fi

echo ""
echo "🔧 Jenkins version updated to 2.440.3-lts"
echo "✅ Plugin dependency issues should be resolved" 