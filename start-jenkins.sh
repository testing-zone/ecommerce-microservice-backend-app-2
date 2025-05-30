#!/bin/bash

echo "🧹 Cleaning up existing Jenkins containers..."
docker rm -f jenkins-server jenkins-docker 2>/dev/null || true

echo "🚀 Starting Jenkins..."
docker-compose -f docker-compose.jenkins.yml up -d

echo "⏳ Waiting for Jenkins to start..."
sleep 45

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
    echo "3. Install suggested plugins"
    echo "4. Create an admin user"
    echo "5. Configure tools (Maven, JDK)"
else
    echo "❌ Jenkins failed to start properly. Checking logs..."
    docker-compose -f docker-compose.jenkins.yml logs jenkins
fi 