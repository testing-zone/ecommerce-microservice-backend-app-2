#!/bin/bash

# Quick Test Script for Jenkins Pipelines
# Tests that all pipelines can be triggered and monitored

set -e

echo "🚀 Quick Pipeline Test - Taller 2"

# Configuration
JENKINS_URL=${JENKINS_URL:-"http://localhost:8081"}
JENKINS_USER=${JENKINS_USER:-"admin"}
JENKINS_PASSWORD=${JENKINS_PASSWORD:-"admin"}

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Check Jenkins
check_jenkins() {
    log_info "Checking Jenkins connection..."
    if curl -f -s "$JENKINS_URL/api/json" > /dev/null 2>&1; then
        log_info "✅ Jenkins is running at $JENKINS_URL"
    else
        log_error "❌ Jenkins not accessible at $JENKINS_URL"
        log_info "Start Jenkins: docker run -p 8081:8080 jenkins/jenkins:2.440.3-lts"
        exit 1
    fi
}

# Test if we can trigger builds
test_pipeline_creation() {
    log_info "Testing pipeline creation..."
    
    # Try to create a simple test job
    cat > test-job-config.xml << 'EOF'
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description>Test Pipeline for Taller 2</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.80">
    <script>
pipeline {
    agent any
    stages {
        stage('Test') {
            steps {
                echo '🎯 Testing pipeline execution...'
                echo '✅ Unit Tests: PASSED (simulated)'
                echo '✅ Integration Tests: PASSED (simulated)'
                echo '✅ E2E Tests: PASSED (simulated)'
                echo '✅ Docker Build: SUCCESS (simulated)'
                echo '🚀 All tests completed successfully!'
            }
        }
    }
    post {
        always {
            echo '🏁 Test pipeline completed'
        }
    }
}
    </script>
    <sandbox>true</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF

    # Download Jenkins CLI if not exists
    if [ ! -f "jenkins-cli.jar" ]; then
        log_info "Downloading Jenkins CLI..."
        curl -s -o jenkins-cli.jar "$JENKINS_URL/jnlpJars/jenkins-cli.jar"
    fi

    # Create test job
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
        create-job "test-pipeline-taller2" < test-job-config.xml 2>/dev/null || \
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
        update-job "test-pipeline-taller2" < test-job-config.xml

    rm -f test-job-config.xml
    log_info "✅ Test pipeline created successfully"
}

# Test build execution
test_build_execution() {
    log_info "Testing build execution..."
    
    # Trigger the test build
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
        build "test-pipeline-taller2" -s -v
    
    log_info "✅ Test build executed successfully"
}

# Show next steps
show_next_steps() {
    echo ""
    log_info "🎉 Pipeline test completed successfully!"
    echo ""
    echo "🚀 Next steps to run all your microservice pipelines:"
    echo ""
    echo "1️⃣  Create all microservice pipelines:"
    echo "   ./scripts/setup-jenkins-pipelines.sh"
    echo ""
    echo "2️⃣  Or manually create pipelines in Jenkins:"
    echo "   • Go to $JENKINS_URL"
    echo "   • New Item → Pipeline"
    echo "   • Use SCM with your repository"
    echo "   • Script Path: product-service/Jenkinsfile"
    echo ""
    echo "3️⃣  Run individual pipelines:"
    echo "   • product-service-pipeline"
    echo "   • order-service-pipeline"
    echo "   • user-service-pipeline"
    echo "   • payment-service-pipeline"
    echo "   • shipping-service-pipeline"
    echo "   • favourite-service-pipeline"
    echo ""
    echo "4️⃣  Monitor progress:"
    echo "   🌐 Dashboard: $JENKINS_URL"
    echo "   📊 Build logs: Click on any build number"
    echo "   ⏱️  Real-time: Watch console output"
    echo ""
    echo "🏆 Your Taller 2 setup is ready to go!"
}

# Cleanup test job
cleanup() {
    log_info "Cleaning up test resources..."
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
        delete-job "test-pipeline-taller2" 2>/dev/null || true
    log_info "✅ Cleanup completed"
}

# Main execution
main() {
    echo "==============================================="
    echo "🎯 Jenkins Pipeline Quick Test - Taller 2"
    echo "==============================================="
    
    check_jenkins
    test_pipeline_creation
    test_build_execution
    cleanup
    show_next_steps
}

# Run main function
main "$@" 