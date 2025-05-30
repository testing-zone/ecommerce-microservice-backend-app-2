#!/bin/bash

# Setup Jenkins Pipelines for E-commerce Microservices
# Taller 2: Pruebas y Lanzamiento

set -e

echo "=== Setting up Jenkins Pipelines ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
JENKINS_URL=${JENKINS_URL:-"http://localhost:8081"}
JENKINS_USER=${JENKINS_USER:-"admin"}
JENKINS_PASSWORD=${JENKINS_PASSWORD:-"admin"}
GIT_REPO_URL=${GIT_REPO_URL:-"https://github.com/your-repo/ecommerce-microservice-backend-app-2.git"}

# Functions
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check Jenkins connectivity
check_jenkins() {
    log_info "Checking Jenkins connectivity..."
    if curl -f -s "$JENKINS_URL/api/json" > /dev/null 2>&1; then
        log_info "✅ Jenkins is accessible at $JENKINS_URL"
    else
        log_error "❌ Cannot connect to Jenkins at $JENKINS_URL"
        log_info "Make sure Jenkins is running: docker run -p 8081:8080 jenkins/jenkins:2.440.3-lts"
        exit 1
    fi
}

# Install Jenkins CLI
setup_jenkins_cli() {
    log_info "Setting up Jenkins CLI..."
    
    if [ ! -f "jenkins-cli.jar" ]; then
        log_info "Downloading Jenkins CLI..."
        curl -s -o jenkins-cli.jar "$JENKINS_URL/jnlpJars/jenkins-cli.jar"
    fi
    
    log_info "✅ Jenkins CLI ready"
}

# Create Jenkins job configuration
create_job_config() {
    local service_name=$1
    local service_port=$2
    
    cat > "${service_name}-pipeline-config.xml" << EOF
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description>CI/CD Pipeline for $service_name - Taller 2</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
      <triggers>
        <hudson.triggers.SCMTrigger>
          <spec>H/5 * * * *</spec>
          <ignorePostCommitHooks>false</ignorePostCommitHooks>
        </hudson.triggers.SCMTrigger>
      </triggers>
    </org.jenkinsci.plugins.workflow.job.properties.PipelineTriggersJobProperty>
  </properties>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@2.80">
    <scm class="hudson.plugins.git.GitSCM" plugin="git@4.4.5">
      <configVersion>2</configVersion>
      <userRemoteConfigs>
        <hudson.plugins.git.UserRemoteConfig>
          <url>$GIT_REPO_URL</url>
        </hudson.plugins.git.UserRemoteConfig>
      </userRemoteConfigs>
      <branches>
        <hudson.plugins.git.BranchSpec>
          <name>*/develop</name>
        </hudson.plugins.git.BranchSpec>
        <hudson.plugins.git.BranchSpec>
          <name>*/staging</name>
        </hudson.plugins.git.BranchSpec>
        <hudson.plugins.git.BranchSpec>
          <name>*/master</name>
        </hudson.plugins.git.BranchSpec>
      </branches>
      <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
      <submoduleCfg class="list"/>
      <extensions/>
    </scm>
    <scriptPath>$service_name/Jenkinsfile</scriptPath>
    <lightweight>true</lightweight>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF
}

# Create multibranch pipeline configuration
create_multibranch_config() {
    local service_name=$1
    
    cat > "${service_name}-multibranch-config.xml" << EOF
<?xml version='1.1' encoding='UTF-8'?>
<org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject plugin="workflow-multibranch@2.21">
  <actions/>
  <description>Multibranch Pipeline for $service_name - Taller 2</description>
  <properties>
    <org.jenkinsci.plugins.pipeline.modeldefinition.config.FolderConfig plugin="pipeline-model-definition@1.7.0">
      <dockerLabel></dockerLabel>
      <registry plugin="docker-commons@1.17"/>
    </org.jenkinsci.plugins.pipeline.modeldefinition.config.FolderConfig>
  </properties>
  <folderViews class="jenkins.branch.MultiBranchProjectViewHolder" plugin="branch-api@2.6.0">
    <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
  </folderViews>
  <healthMetrics>
    <com.cloudbees.hudson.plugins.folder.health.WorstChildHealthMetric plugin="cloudbees-folder@6.14">
      <nonRecursive>false</nonRecursive>
    </com.cloudbees.hudson.plugins.folder.health.WorstChildHealthMetric>
  </healthMetrics>
  <icon class="jenkins.branch.MetadataActionFolderIcon" plugin="branch-api@2.6.0">
    <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
  </icon>
  <orphanedItemStrategy class="com.cloudbees.hudson.plugins.folder.computed.DefaultOrphanedItemStrategy" plugin="cloudbees-folder@6.14">
    <pruneDeadBranches>true</pruneDeadBranches>
    <daysToKeep>-1</daysToKeep>
    <numToKeep>-1</numToKeep>
  </orphanedItemStrategy>
  <triggers>
    <com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger plugin="cloudbees-folder@6.14">
      <spec>H H/4 * * *</spec>
      <interval>86400000</interval>
    </com.cloudbees.hudson.plugins.folder.computed.PeriodicFolderTrigger>
  </triggers>
  <disabled>false</disabled>
  <sources class="jenkins.branch.BranchSource" plugin="branch-api@2.6.0">
    <source class="jenkins.plugins.git.GitSCMSource" plugin="git@4.4.5">
      <id>$service_name-git-source</id>
      <remote>$GIT_REPO_URL</remote>
      <credentialsId></credentialsId>
      <traits>
        <jenkins.plugins.git.traits.BranchDiscoveryTrait>
          <strategyId>1</strategyId>
        </jenkins.plugins.git.traits.BranchDiscoveryTrait>
        <jenkins.plugins.git.traits.CloneOptionTrait>
          <extension class="hudson.plugins.git.extensions.impl.CloneOption">
            <shallow>false</shallow>
            <noTags>false</noTags>
            <reference></reference>
            <timeout>10</timeout>
            <depth>0</depth>
            <honorRefspec>false</honorRefspec>
          </extension>
        </jenkins.plugins.git.traits.CloneOptionTrait>
      </traits>
    </source>
    <strategy class="jenkins.branch.DefaultBranchPropertyStrategy">
      <properties class="empty-list"/>
    </strategy>
  </sources>
  <factory class="org.jenkinsci.plugins.workflow.multibranch.WorkflowBranchProjectFactory">
    <owner class="org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject" reference="../.."/>
    <scriptPath>$service_name/Jenkinsfile</scriptPath>
  </factory>
</org.jenkinsci.plugins.workflow.multibranch.WorkflowMultiBranchProject>
EOF
}

# Create Jenkins jobs
create_jenkins_jobs() {
    local services=(
        "user-service:8081"
        "product-service:8082"
        "order-service:8083"
        "payment-service:8084"
        "shipping-service:8085"
        "favourite-service:8086"
    )
    
    log_step "Creating Jenkins jobs for all microservices..."
    
    for service_info in "${services[@]}"; do
        IFS=':' read -r service_name service_port <<< "$service_info"
        
        log_info "Creating job for $service_name..."
        
        # Create simple pipeline job
        create_job_config "$service_name" "$service_port"
        
        # Create the job in Jenkins
        java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
            create-job "$service_name-pipeline" < "${service_name}-pipeline-config.xml" 2>/dev/null || \
        java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
            update-job "$service_name-pipeline" < "${service_name}-pipeline-config.xml"
        
        # Create multibranch pipeline
        create_multibranch_config "$service_name"
        
        java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
            create-job "$service_name-multibranch" < "${service_name}-multibranch-config.xml" 2>/dev/null || \
        java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
            update-job "$service_name-multibranch" < "${service_name}-multibranch-config.xml"
        
        log_info "✅ Created jobs for $service_name"
        
        # Cleanup config files
        rm -f "${service_name}-pipeline-config.xml" "${service_name}-multibranch-config.xml"
    done
}

# Create a master pipeline that runs all services
create_master_pipeline() {
    log_step "Creating master pipeline to run all services..."
    
    cat > "master-pipeline-config.xml" << EOF
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@2.40">
  <actions/>
  <description>Master Pipeline - Runs all microservices pipelines - Taller 2</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2.80">
    <script>
pipeline {
    agent any
    
    stages {
        stage('Trigger All Service Pipelines') {
            parallel {
                stage('User Service') {
                    steps {
                        build job: 'user-service-pipeline', wait: false
                    }
                }
                stage('Product Service') {
                    steps {
                        build job: 'product-service-pipeline', wait: false
                    }
                }
                stage('Order Service') {
                    steps {
                        build job: 'order-service-pipeline', wait: false
                    }
                }
                stage('Payment Service') {
                    steps {
                        build job: 'payment-service-pipeline', wait: false
                    }
                }
                stage('Shipping Service') {
                    steps {
                        build job: 'shipping-service-pipeline', wait: false
                    }
                }
                stage('Favourite Service') {
                    steps {
                        build job: 'favourite-service-pipeline', wait: false
                    }
                }
            }
        }
        
        stage('Wait for All Pipelines') {
            steps {
                script {
                    def services = ['user-service', 'product-service', 'order-service', 'payment-service', 'shipping-service', 'favourite-service']
                    
                    services.each { service ->
                        build job: "\${service}-pipeline", wait: true
                    }
                }
            }
        }
        
        stage('Generate Consolidated Report') {
            steps {
                script {
                    echo "All microservice pipelines completed!"
                    echo "Check individual pipeline results for details."
                }
            }
        }
    }
    
    post {
        always {
            echo 'Master pipeline completed.'
        }
        success {
            echo 'All microservice pipelines succeeded!'
            emailext (
                subject: "SUCCESS: All Microservice Pipelines - Build \${BUILD_NUMBER}",
                body: "All microservice pipelines have completed successfully.\\n\\nBuild: \${BUILD_NUMBER}\\n\\nView the build: \${BUILD_URL}",
                to: "devops@company.com"
            )
        }
        failure {
            echo 'One or more microservice pipelines failed!'
            emailext (
                subject: "FAILURE: Microservice Pipelines - Build \${BUILD_NUMBER}",
                body: "One or more microservice pipelines have failed.\\n\\nBuild: \${BUILD_NUMBER}\\n\\nView the build: \${BUILD_URL}",
                to: "devops@company.com"
            )
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

    # Create the master pipeline job
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
        create-job "ecommerce-master-pipeline" < "master-pipeline-config.xml" 2>/dev/null || \
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
        update-job "ecommerce-master-pipeline" < "master-pipeline-config.xml"
    
    rm -f "master-pipeline-config.xml"
    log_info "✅ Master pipeline created"
}

# Create dashboard view
create_dashboard_view() {
    log_step "Creating dashboard view..."
    
    cat > "dashboard-view-config.xml" << EOF
<?xml version='1.1' encoding='UTF-8'?>
<hudson.model.ListView>
  <name>E-commerce Microservices Dashboard</name>
  <description>Dashboard for all e-commerce microservice pipelines - Taller 2</description>
  <filterExecutors>false</filterExecutors>
  <filterQueue>false</filterQueue>
  <properties class="hudson.model.View\$PropertyList"/>
  <jobNames>
    <comparator class="hudson.util.CaseInsensitiveComparator"/>
    <string>ecommerce-master-pipeline</string>
    <string>user-service-pipeline</string>
    <string>product-service-pipeline</string>
    <string>order-service-pipeline</string>
    <string>payment-service-pipeline</string>
    <string>shipping-service-pipeline</string>
    <string>favourite-service-pipeline</string>
    <string>user-service-multibranch</string>
    <string>product-service-multibranch</string>
    <string>order-service-multibranch</string>
    <string>payment-service-multibranch</string>
    <string>shipping-service-multibranch</string>
    <string>favourite-service-multibranch</string>
  </jobNames>
  <jobFilters/>
  <columns>
    <hudson.views.StatusColumn/>
    <hudson.views.WeatherColumn/>
    <hudson.views.JobColumn/>
    <hudson.views.LastSuccessColumn/>
    <hudson.views.LastFailureColumn/>
    <hudson.views.LastDurationColumn/>
    <hudson.views.BuildButtonColumn/>
  </columns>
  <recurse>false</recurse>
</hudson.model.ListView>
EOF

    # Create the dashboard view
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
        create-view < "dashboard-view-config.xml" 2>/dev/null || \
    java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
        update-view "E-commerce Microservices Dashboard" < "dashboard-view-config.xml"
    
    rm -f "dashboard-view-config.xml"
    log_info "✅ Dashboard view created"
}

# Trigger initial builds
trigger_initial_builds() {
    log_step "Triggering initial builds for all pipelines..."
    
    local services=(
        "user-service-pipeline"
        "product-service-pipeline"
        "order-service-pipeline"
        "payment-service-pipeline"
        "shipping-service-pipeline"
        "favourite-service-pipeline"
    )
    
    for service in "${services[@]}"; do
        log_info "Triggering build for $service..."
        java -jar jenkins-cli.jar -s "$JENKINS_URL" -auth "$JENKINS_USER:$JENKINS_PASSWORD" \
            build "$service" 2>/dev/null || log_warn "Could not trigger $service (may not exist yet)"
    done
    
    log_info "✅ All builds triggered"
}

# Display instructions
show_instructions() {
    log_step "Setup completed! Here's how to run your pipelines:"
    echo ""
    echo "🌐 Jenkins Dashboard: $JENKINS_URL"
    echo "📊 Microservices View: $JENKINS_URL/view/E-commerce%20Microservices%20Dashboard/"
    echo ""
    echo "🚀 Ways to run pipelines:"
    echo ""
    echo "1️⃣  Run Master Pipeline (runs all services):"
    echo "   👆 Click: $JENKINS_URL/job/ecommerce-master-pipeline/"
    echo "   🖥️  CLI: java -jar jenkins-cli.jar -s $JENKINS_URL build ecommerce-master-pipeline"
    echo ""
    echo "2️⃣  Run Individual Services:"
    echo "   👆 Click on any service in the dashboard"
    echo "   🖥️  CLI: java -jar jenkins-cli.jar -s $JENKINS_URL build product-service-pipeline"
    echo ""
    echo "3️⃣  Multibranch Pipelines (for different branches):"
    echo "   👆 Use the *-multibranch jobs for branch-specific builds"
    echo ""
    echo "📋 Available Jobs:"
    echo "   • ecommerce-master-pipeline (runs all)"
    echo "   • user-service-pipeline"
    echo "   • product-service-pipeline"
    echo "   • order-service-pipeline"
    echo "   • payment-service-pipeline"
    echo "   • shipping-service-pipeline"
    echo "   • favourite-service-pipeline"
    echo ""
    echo "🔍 Monitor builds in real-time at the dashboard!"
}

# Main execution
main() {
    log_info "Starting Jenkins Pipeline Setup for E-commerce Microservices..."
    
    check_jenkins
    setup_jenkins_cli
    create_jenkins_jobs
    create_master_pipeline
    create_dashboard_view
    
    log_info "Setup completed successfully!"
    echo ""
    show_instructions
}

# Execute main function
main "$@" 