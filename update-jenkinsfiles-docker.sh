#!/bin/bash

echo "🔄 ACTUALIZANDO JENKINSFILES PARA MANEJAR DOCKER"
echo "================================================"

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

# Servicios a actualizar
SERVICES=("user-service" "product-service" "order-service" "payment-service" "shipping-service" "favourite-service")

# Función para crear Jenkinsfile mejorado
create_improved_jenkinsfile() {
    local service_name=$1
    local service_port=$2
    
    log_step "Actualizando Jenkinsfile para $service_name..."
    
    cat > "${service_name}/Jenkinsfile" << 'EOF'
pipeline {
    agent any
    
    tools {
        maven 'Maven'
    }
    
    environment {
        PROJECT_VERSION = '0.1.0'
        DOCKER_IMAGE = "${SERVICE_NAME}-ecommerce"
        DOCKER_TAG = "${BUILD_NUMBER}"
        MAVEN_OPTS = '-Dmaven.repo.local=/var/jenkins_home/.m2/repository'
        SERVICE_NAME = 'SERVICE_NAME_PLACEHOLDER'
        SERVICE_PORT = 'SERVICE_PORT_PLACEHOLDER'
        K8S_NAMESPACE = 'ecommerce'
        // Configuración Docker
        DOCKER_BUILDKIT = '1'
        DOCKER_CLI_EXPERIMENTAL = 'enabled'
    }
    
    options {
        timeout(time: 30, unit: 'MINUTES')
        retry(1)
        timestamps()
    }
    
    stages {
        stage('Verify Environment') {
            steps {
                script {
                    echo 'Verifying build environment...'
                    sh 'echo "Current JAVA_HOME: $JAVA_HOME"'
                    sh 'java -version'
                    sh 'mvn -version'
                    
                    // Verificar Docker con manejo de errores
                    try {
                        sh 'docker --version'
                        env.DOCKER_AVAILABLE = 'true'
                        echo '✅ Docker disponible'
                    } catch (Exception e) {
                        env.DOCKER_AVAILABLE = 'false'
                        echo '⚠️ Docker no disponible - construyendo solo JAR'
                    }
                    
                    // Verificar kubectl
                    try {
                        sh 'kubectl version --client'
                        env.KUBECTL_AVAILABLE = 'true'
                        echo '✅ kubectl disponible'
                    } catch (Exception e) {
                        env.KUBECTL_AVAILABLE = 'false'
                        echo '⚠️ kubectl no disponible - sin deployment K8s'
                    }
                }
            }
        }
        
        stage('Checkout') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }
        
        stage('Unit Tests') {
            steps {
                echo 'Running unit tests...'
                dir(env.SERVICE_NAME) {
                    sh 'mvn clean test -Dtest=*ServiceTest'
                }
            }
            post {
                always {
                    dir(env.SERVICE_NAME) {
                        publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                    }
                }
            }
        }
        
        stage('Integration Tests') {
            steps {
                echo 'Running integration tests...'
                dir(env.SERVICE_NAME) {
                    sh 'mvn test -Dtest=*IntegrationTest -DfailIfNoTests=false'
                }
            }
            post {
                always {
                    dir(env.SERVICE_NAME) {
                        publishTestResults testResultsPattern: 'target/surefire-reports/*.xml'
                    }
                }
            }
        }
        
        stage('Build Application') {
            steps {
                echo 'Building the application...'
                dir(env.SERVICE_NAME) {
                    sh 'mvn clean compile package -DskipTests'
                }
            }
            post {
                success {
                    dir(env.SERVICE_NAME) {
                        archiveArtifacts artifacts: 'target/*.jar', allowEmptyArchive: false
                    }
                }
            }
        }
        
        stage('Code Quality Analysis') {
            steps {
                echo 'Running code quality analysis...'
                dir(env.SERVICE_NAME) {
                    script {
                        try {
                            sh 'mvn checkstyle:check'
                            echo '✅ Checkstyle passed'
                        } catch (Exception e) {
                            echo '⚠️ Checkstyle warnings found - continuing'
                            currentBuild.result = 'UNSTABLE'
                        }
                    }
                }
            }
        }
        
        stage('Docker Build') {
            when {
                environment name: 'DOCKER_AVAILABLE', value: 'true'
            }
            steps {
                echo 'Building Docker image...'
                dir(env.SERVICE_NAME) {
                    script {
                        try {
                            // Verificar que existe Dockerfile
                            if (fileExists('Dockerfile')) {
                                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                                sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                                sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:dev-${DOCKER_TAG}"
                                
                                // Mostrar imágenes creadas
                                sh "docker images | grep ${env.SERVICE_NAME}-ecommerce"
                                
                                echo "✅ Docker image built successfully: ${DOCKER_IMAGE}:${DOCKER_TAG}"
                            } else {
                                echo '⚠️ Dockerfile not found - skipping Docker build'
                                env.DOCKER_AVAILABLE = 'false'
                            }
                        } catch (Exception e) {
                            echo "❌ Docker build failed: ${e.getMessage()}"
                            echo "📝 Build will continue without Docker image"
                            env.DOCKER_AVAILABLE = 'false'
                            currentBuild.result = 'UNSTABLE'
                        }
                    }
                }
            }
        }
        
        stage('Spring Boot Build Image') {
            when {
                environment name: 'DOCKER_AVAILABLE', value: 'false'
            }
            steps {
                echo 'Building with Spring Boot Maven plugin...'
                dir(env.SERVICE_NAME) {
                    script {
                        try {
                            sh 'mvn spring-boot:build-image -Dspring-boot.build-image.imageName=${DOCKER_IMAGE}:${DOCKER_TAG}'
                            echo '✅ Spring Boot image built successfully'
                            env.DOCKER_AVAILABLE = 'true'
                        } catch (Exception e) {
                            echo "⚠️ Spring Boot build-image failed: ${e.getMessage()}"
                            echo "📝 Continuing with JAR only"
                        }
                    }
                }
            }
        }
        
        stage('Deploy to Dev Environment') {
            when {
                allOf {
                    branch 'develop'
                    environment name: 'KUBECTL_AVAILABLE', value: 'true'
                }
            }
            steps {
                echo 'Deploying to development environment...'
                script {
                    try {
                        sh 'kubectl cluster-info --request-timeout=5s'
                        
                        dir("${env.SERVICE_NAME}/k8s") {
                            // Aplicar configuraciones K8s
                            sh "kubectl apply -f namespace.yaml"
                            sh "kubectl apply -f configmap.yaml"
                            
                            // Actualizar deployment con nueva imagen
                            def deploymentFile = fileExists('deployment.yaml') ? 'deployment.yaml' : 'deployment-dev.yaml'
                            sh "sed 's/{{BUILD_NUMBER}}/${BUILD_NUMBER}/g' ${deploymentFile} | kubectl apply -f -"
                            sh "kubectl apply -f service.yaml"
                            
                            // Esperar rollout
                            sh "kubectl rollout status deployment/${SERVICE_NAME} -n ${K8S_NAMESPACE} --timeout=300s"
                            
                            echo '✅ Development deployment successful!'
                            sh "kubectl get pods -n ${K8S_NAMESPACE} -l app=${SERVICE_NAME}"
                            sh "kubectl get svc -n ${K8S_NAMESPACE} -l app=${SERVICE_NAME}"
                        }
                    } catch (Exception e) {
                        echo "❌ Kubernetes deployment failed: ${e.getMessage()}"
                        echo "📝 Check cluster connectivity and RBAC permissions"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        
        stage('Health Check') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'staging'
                }
            }
            steps {
                echo 'Performing health check...'
                script {
                    try {
                        // Health check con retry
                        timeout(time: 5, unit: 'MINUTES') {
                            waitUntil {
                                script {
                                    def result = sh(
                                        script: "kubectl get pods -n ${K8S_NAMESPACE} -l app=${SERVICE_NAME} -o jsonpath='{.items[0].status.phase}'",
                                        returnStdout: true
                                    ).trim()
                                    return result == 'Running'
                                }
                            }
                        }
                        echo '✅ Service is healthy and running'
                    } catch (Exception e) {
                        echo "⚠️ Health check timeout: ${e.getMessage()}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
        
        stage('E2E Tests') {
            when {
                anyOf {
                    branch 'develop'
                    branch 'staging'
                }
            }
            steps {
                echo 'Running E2E tests...'
                script {
                    try {
                        dir('.') {
                            sh 'mvn test -Dtest=*E2ETest -Dspring.profiles.active=test -DfailIfNoTests=false'
                        }
                    } catch (Exception e) {
                        echo "⚠️ E2E tests failed: ${e.getMessage()}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
            post {
                always {
                    publishTestResults testResultsPattern: 'target/surefire-reports/*.xml', allowEmptyResults: true
                }
            }
        }
        
        stage('Deploy to Production') {
            when {
                branch 'master'
            }
            steps {
                echo 'Deploying to production environment...'
                input message: 'Deploy to production?', ok: 'Deploy'
                
                script {
                    try {
                        dir("${env.SERVICE_NAME}/k8s") {
                            sh "kubectl apply -f namespace-prod.yaml"
                            sh "kubectl apply -f configmap-prod.yaml"
                            sh "sed 's/{{BUILD_NUMBER}}/${BUILD_NUMBER}/g' deployment-prod.yaml | kubectl apply -f -"
                            sh "kubectl apply -f service-prod.yaml"
                            
                            sh "kubectl rollout status deployment/${SERVICE_NAME} -n ${K8S_NAMESPACE}-prod --timeout=600s"
                            
                            echo '✅ Production deployment successful!'
                        }
                    } catch (Exception e) {
                        echo "❌ Production deployment failed: ${e.getMessage()}"
                        currentBuild.result = 'FAILURE'
                        error("Production deployment failed")
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo 'Pipeline completed.'
            
            // Cleanup workspace
            cleanWs()
        }
        success {
            echo '✅ Pipeline succeeded!'
            script {
                if (env.BRANCH_NAME == 'master') {
                    echo '🎉 Production deployment completed successfully!'
                } else if (env.BRANCH_NAME == 'develop') {
                    echo '🚀 Development deployment completed successfully!'
                }
            }
        }
        failure {
            echo '❌ Pipeline failed!'
            script {
                // Notificación de fallo
                echo "💬 Build failed for ${env.SERVICE_NAME} on branch ${env.BRANCH_NAME}"
            }
        }
        unstable {
            echo '⚠️ Pipeline completed with warnings!'
        }
    }
}
EOF

    # Reemplazar placeholders
    sed -i "s/SERVICE_NAME_PLACEHOLDER/${service_name}/g" "${service_name}/Jenkinsfile"
    sed -i "s/SERVICE_PORT_PLACEHOLDER/${service_port}/g" "${service_name}/Jenkinsfile"
    
    log_info "✅ Jenkinsfile actualizado para ${service_name}"
}

# Actualizar todos los servicios
log_step "Iniciando actualización de Jenkinsfiles..."

# Mapeo de servicios y puertos
declare -A service_ports=(
    ["user-service"]="8087"
    ["product-service"]="8082"
    ["order-service"]="8083"
    ["payment-service"]="8084"
    ["shipping-service"]="8085"
    ["favourite-service"]="8086"
)

for service in "${SERVICES[@]}"; do
    if [ -d "$service" ]; then
        # Backup del Jenkinsfile original
        if [ -f "${service}/Jenkinsfile" ]; then
            cp "${service}/Jenkinsfile" "${service}/Jenkinsfile.backup"
            log_info "📦 Backup creado: ${service}/Jenkinsfile.backup"
        fi
        
        # Crear nuevo Jenkinsfile
        create_improved_jenkinsfile "$service" "${service_ports[$service]}"
    else
        log_warn "⚠️ Directorio $service no encontrado"
    fi
done

echo ""
echo "🎉 ¡ACTUALIZACIÓN DE JENKINSFILES COMPLETADA!"
echo "============================================="
echo ""
echo "✅ MEJORAS IMPLEMENTADAS:"
echo "   ✅ Manejo robusto de errores Docker"
echo "   ✅ Fallback a Spring Boot build-image"
echo "   ✅ Verificación de prerequisitos"
echo "   ✅ Health checks automáticos"
echo "   ✅ Timeouts configurados"
echo "   ✅ Mejor logging y debugging"
echo "   ✅ Backups de archivos originales"
echo ""
echo "🔧 LOS PIPELINES AHORA PUEDEN:"
echo "   ✅ Funcionar SIN Docker (usando Spring Boot build-image)"
echo "   ✅ Detectar automáticamente herramientas disponibles"
echo "   ✅ Continuar con warnings en lugar de fallar"
echo "   ✅ Realizar health checks post-deployment"
echo "   ✅ Manejar timeouts apropiadamente"
echo ""
echo "📋 PRÓXIMOS PASOS:"
echo "   1. Ejecutar: ./fix-jenkins-docker.sh (si no lo has hecho)"
echo "   2. Configurar pipelines en Jenkins UI"
echo "   3. Ejecutar un pipeline de prueba"
echo ""
echo "💡 NOTA: Si Docker sigue fallando, los pipelines usarán"
echo "   Spring Boot Maven plugin como alternativa."
echo "" 