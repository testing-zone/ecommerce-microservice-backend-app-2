#!/bin/bash

# Jenkins Setup Script for E-commerce Microservices
echo "🚀 Setting up Jenkins for E-commerce Microservices..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Start Jenkins
echo "📦 Starting Jenkins..."
docker-compose -f docker-compose.jenkins.yml up -d

# Wait for Jenkins to be ready
echo "⏳ Waiting for Jenkins to start..."
sleep 30

# Get initial admin password
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
    echo ""
    echo "🛠️ Required tools to configure in Jenkins:"
    echo "   - Maven: Name 'Maven-3.9.0', Install automatically"
    echo "   - JDK: Name 'JDK-11', Install automatically (OpenJDK 11)"
    echo ""
    echo "📦 Required plugins:"
    echo "   - Pipeline"
    echo "   - Docker Pipeline"
    echo "   - Maven Integration"
    echo "   - JUnit"
    echo "   - Jacoco"
    echo "   - Blue Ocean (recommended)"
else
    echo "❌ Jenkins failed to start properly. Check logs with:"
    echo "   docker-compose -f docker-compose.jenkins.yml logs"
fi 