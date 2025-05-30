#!/bin/bash

echo "Stopping Jenkins..."
docker stop jenkins-server
docker rm jenkins-server

echo "Building new Jenkins image..."
docker build -f jenkins.Dockerfile -t jenkins-with-docker .

echo "Starting Jenkins with Docker support..."
docker run -d \
  --name jenkins-server \
  -p 8081:8080 \
  -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd):/workspace \
  jenkins-with-docker

echo "Waiting for Jenkins to start..."
sleep 60

echo "Getting admin password..."
docker exec jenkins-server cat /var/jenkins_home/secrets/initialAdminPassword

echo "Testing Docker access..."
docker exec jenkins-server docker ps

echo "Jenkins ready at http://localhost:8081" 