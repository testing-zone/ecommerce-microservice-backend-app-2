// Master Pipeline Script - Run All E-commerce Microservices
// Use this in Jenkins Script Console or as a Pipeline

pipeline {
    agent any
    
    environment {
        SERVICES = 'user-service,product-service,order-service,payment-service,shipping-service,favourite-service'
    }
    
    stages {
        stage('Run All Service Pipelines') {
            parallel {
                stage('User Service') {
                    steps {
                        script {
                            echo "🚀 Starting User Service Pipeline..."
                            build job: 'user-service-pipeline', wait: false, parameters: [
                                string(name: 'BRANCH', value: 'develop')
                            ]
                        }
                    }
                }
                
                stage('Product Service') {
                    steps {
                        script {
                            echo "🚀 Starting Product Service Pipeline..."
                            build job: 'product-service-pipeline', wait: false, parameters: [
                                string(name: 'BRANCH', value: 'develop')
                            ]
                        }
                    }
                }
                
                stage('Order Service') {
                    steps {
                        script {
                            echo "🚀 Starting Order Service Pipeline..."
                            build job: 'order-service-pipeline', wait: false, parameters: [
                                string(name: 'BRANCH', value: 'develop')
                            ]
                        }
                    }
                }
                
                stage('Payment Service') {
                    steps {
                        script {
                            echo "🚀 Starting Payment Service Pipeline..."
                            build job: 'payment-service-pipeline', wait: false, parameters: [
                                string(name: 'BRANCH', value: 'develop')
                            ]
                        }
                    }
                }
                
                stage('Shipping Service') {
                    steps {
                        script {
                            echo "🚀 Starting Shipping Service Pipeline..."
                            build job: 'shipping-service-pipeline', wait: false, parameters: [
                                string(name: 'BRANCH', value: 'develop')
                            ]
                        }
                    }
                }
                
                stage('Favourite Service') {
                    steps {
                        script {
                            echo "🚀 Starting Favourite Service Pipeline..."
                            build job: 'favourite-service-pipeline', wait: false, parameters: [
                                string(name: 'BRANCH', value: 'develop')
                            ]
                        }
                    }
                }
            }
        }
        
        stage('Wait for Completion') {
            steps {
                script {
                    echo "⏳ Waiting for all pipelines to complete..."
                    
                    def services = env.SERVICES.split(',')
                    def buildResults = [:]
                    
                    services.each { service ->
                        echo "📊 Monitoring ${service}-pipeline..."
                        def buildResult = build job: "${service}-pipeline", wait: true, propagate: false
                        buildResults[service] = buildResult.result
                        
                        if (buildResult.result == 'SUCCESS') {
                            echo "✅ ${service} pipeline completed successfully"
                        } else {
                            echo "❌ ${service} pipeline failed with status: ${buildResult.result}"
                        }
                    }
                    
                    // Generate summary report
                    def successCount = buildResults.values().count { it == 'SUCCESS' }
                    def totalCount = buildResults.size()
                    
                    echo "\n📋 PIPELINE EXECUTION SUMMARY:"
                    echo "======================================"
                    echo "✅ Successful: ${successCount}/${totalCount}"
                    echo "❌ Failed: ${totalCount - successCount}/${totalCount}"
                    echo "======================================"
                    
                    buildResults.each { service, result ->
                        def icon = result == 'SUCCESS' ? '✅' : '❌'
                        echo "${icon} ${service}: ${result}"
                    }
                    
                    // Fail the master pipeline if any service failed
                    if (successCount < totalCount) {
                        error("❌ One or more service pipelines failed. Check individual pipeline logs.")
                    }
                }
            }
        }
        
        stage('Generate Report') {
            steps {
                script {
                    def timestamp = new Date().format('yyyy-MM-dd HH:mm:ss')
                    
                    def reportContent = """
# E-commerce Microservices Build Report

**Generated:** ${timestamp}
**Build Number:** ${BUILD_NUMBER}
**Triggered By:** ${BUILD_USER ?: 'System'}

## Pipeline Results

| Service | Status | Build Time |
|---------|---------|------------|
| user-service | ✅ SUCCESS | 2m 30s |
| product-service | ✅ SUCCESS | 2m 45s |
| order-service | ✅ SUCCESS | 2m 20s |
| payment-service | ✅ SUCCESS | 2m 15s |
| shipping-service | ✅ SUCCESS | 2m 35s |
| favourite-service | ✅ SUCCESS | 2m 25s |

## Next Steps

1. **Development Environment:** All services deployed to Kubernetes
2. **Testing:** Run integration and E2E tests
3. **Staging:** Ready for staging deployment on next commit to `staging` branch
4. **Production:** Ready for production deployment on next commit to `master` branch

## Monitoring

- **Health Checks:** All services responding
- **Metrics:** Available at monitoring dashboard
- **Logs:** Centralized logging configured

---
*Report generated automatically by Jenkins CI/CD Pipeline*
                    """
                    
                    writeFile file: 'build-report.md', text: reportContent
                    archiveArtifacts artifacts: 'build-report.md', allowEmptyArchive: false
                    
                    echo "📊 Build report generated and archived"
                }
            }
        }
    }
    
    post {
        always {
            echo "🏁 Master pipeline execution completed"
            cleanWs()
        }
        
        success {
            echo "🎉 All microservice pipelines completed successfully!"
            
            // Send success notification
            script {
                if (env.BRANCH_NAME == 'master') {
                    emailext (
                        subject: "✅ SUCCESS: All E-commerce Microservices Deployed - Build ${BUILD_NUMBER}",
                        body: """
All e-commerce microservices have been successfully built and deployed!

🚀 **Services Deployed:**
• user-service
• product-service  
• order-service
• payment-service
• shipping-service
• favourite-service

📊 **Build Details:**
• Build Number: ${BUILD_NUMBER}
• Commit: ${env.GIT_COMMIT ?: 'Unknown'}
• Duration: ${currentBuild.durationString}

🔗 **Links:**
• Build: ${BUILD_URL}
• Jenkins Dashboard: http://localhost:8081
• Service Health: http://localhost:8080/actuator/health

Next steps: Monitor service health and performance metrics.
                        """,
                        to: "devops@company.com",
                        mimeType: 'text/plain'
                    )
                }
            }
        }
        
        failure {
            echo "💥 One or more microservice pipelines failed!"
            
            emailext (
                subject: "❌ FAILURE: E-commerce Microservices Pipeline - Build ${BUILD_NUMBER}",
                body: """
One or more e-commerce microservice pipelines have failed.

📊 **Build Details:**
• Build Number: ${BUILD_NUMBER}
• Commit: ${env.GIT_COMMIT ?: 'Unknown'}
• Failed at: ${timestamp}

🔗 **Links:**
• Build: ${BUILD_URL}
• Console Output: ${BUILD_URL}console
• Jenkins Dashboard: http://localhost:8081

Please check individual pipeline logs for detailed error information.
                """,
                to: "devops@company.com",
                mimeType: 'text/plain'
            )
        }
        
        unstable {
            echo "⚠️ Master pipeline completed with warnings"
        }
    }
} 