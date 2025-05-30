#!/bin/bash

echo "🧪 Testing Docker functionality in Jenkins pipeline..."

echo "📋 Jenkins Access Information:"
echo "🌐 URL: http://localhost:8081"
echo "🔐 Password: dc6f56304d314b05978a1e08eb1699bf"
echo ""

echo "🔍 Verifying Docker in Jenkins container..."
docker exec jenkins-server docker --version

echo ""
echo "🔍 Verifying Docker daemon connection..."
docker exec jenkins-server docker ps

echo ""
echo "🔍 Checking if Jenkins can access Docker socket..."
docker exec jenkins-server ls -la /var/run/docker.sock

echo ""
echo "🔍 Testing Docker build capability..."
docker exec jenkins-server docker images

echo ""
echo "📝 Manual Pipeline Test Instructions:"
echo "1. Open http://localhost:8081 in your browser"
echo "2. Use password: dc6f56304d314b05978a1e08eb1699bf"
echo "3. Create a new Pipeline job"
echo "4. Configure it to use SCM with this repository"
echo "5. Set script path to: user-service/Jenkinsfile"
echo "6. Run the pipeline to test Docker build"

echo ""
echo "✅ Docker setup verification complete!"
echo "🐳 Jenkins should now be able to build Docker images!" 