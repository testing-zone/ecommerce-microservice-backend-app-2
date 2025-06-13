#!/bin/bash

echo "🧪 Testing User Service Pipeline Locally..."

# Navigate to user-service directory
cd user-service

echo "📦 Step 1: Clean and compile..."
mvn clean compile -DskipTests
if [ $? -ne 0 ]; then
    echo "❌ Compilation failed!"
    exit 1
fi

echo "✅ Compilation successful!"

echo "🧪 Step 2: Running tests..."
mvn test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed!"
    exit 1
fi

echo "✅ Tests passed!"

echo "📦 Step 3: Packaging..."
mvn package -DskipTests
if [ $? -ne 0 ]; then
    echo "❌ Packaging failed!"
    exit 1
fi

echo "✅ Packaging successful!"

echo "🐳 Step 4: Building Docker image..."
docker build -t user-service-ecommerce:test .
if [ $? -ne 0 ]; then
    echo "❌ Docker build failed!"
    exit 1
fi

echo "✅ Docker image built successfully!"

echo "📊 Step 5: Checking test reports..."
if [ -f "target/surefire-reports/TEST-*.xml" ]; then
    echo "✅ Test reports generated"
    ls -la target/surefire-reports/
else
    echo "⚠️ No test reports found"
fi

if [ -f "target/site/jacoco/jacoco.xml" ]; then
    echo "✅ JaCoCo coverage report generated"
else
    echo "⚠️ No JaCoCo coverage report found"
fi

echo "🎉 All steps completed successfully!"
echo "📋 Summary:"
echo "   - Compilation: ✅"
echo "   - Tests: ✅"
echo "   - Packaging: ✅"
echo "   - Docker Build: ✅"
echo ""
echo "🚀 Ready for Jenkins pipeline!" 