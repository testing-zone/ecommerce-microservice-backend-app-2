#!/bin/bash

# Setup Performance Tests with Locust
# Taller 2: Pruebas y Lanzamiento

set -e

echo "=== Setting up Performance Tests Environment ==="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

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

# Check if Python is installed
check_python() {
    log_info "Checking Python installation..."
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        log_info "Python 3 found: $PYTHON_VERSION"
    else
        log_error "Python 3 is not installed. Please install Python 3.7 or higher."
        exit 1
    fi
}

# Check if pip is installed
check_pip() {
    log_info "Checking pip installation..."
    if command -v pip3 &> /dev/null; then
        PIP_VERSION=$(pip3 --version | cut -d' ' -f2)
        log_info "pip found: $PIP_VERSION"
    else
        log_error "pip3 is not installed. Please install pip3."
        exit 1
    fi
}

# Install Locust
install_locust() {
    log_info "Installing Locust..."
    
    # Create virtual environment if it doesn't exist
    if [ ! -d "venv" ]; then
        log_info "Creating virtual environment..."
        python3 -m venv venv
    fi
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip
    
    # Install Locust and dependencies
    pip install locust==2.17.0
    pip install requests==2.31.0
    pip install faker==19.12.0
    pip install pytest==7.4.3
    pip install pytest-html==4.1.1
    
    log_info "Locust installed successfully!"
    
    # Verify installation
    locust --version
}

# Create performance test directory structure
setup_directories() {
    log_info "Setting up directory structure..."
    
    mkdir -p src/test/performance
    mkdir -p src/test/performance/reports
    mkdir -p src/test/performance/config
    mkdir -p src/test/performance/data
    mkdir -p src/test/performance/scripts
    
    log_info "Directory structure created."
}

# Create configuration files
create_config_files() {
    log_info "Creating configuration files..."
    
    # Create Locust configuration file
    cat > src/test/performance/config/locust.conf << EOF
# Locust Configuration File
# Default settings for performance tests

[locust]
# Web UI settings
web-host = 0.0.0.0
web-port = 8089

# Default test settings
users = 50
spawn-rate = 5
run-time = 300s
host = http://localhost:8080

# Logging
loglevel = INFO
logfile = reports/locust.log

# Output settings
html = reports/performance-report.html
csv = reports/performance-data
EOF

    # Create test data generator
    cat > src/test/performance/data/test_data_generator.py << 'EOF'
import random
import json
from faker import Faker

fake = Faker()

def generate_user_data():
    """Generate realistic user data for testing"""
    return {
        "firstName": fake.first_name(),
        "lastName": fake.last_name(),
        "email": fake.email(),
        "phone": fake.phone_number()[:15],
        "credentialDto": {
            "username": fake.user_name(),
            "password": fake.password(length=12),
            "roleBasedAuthority": random.choice(["ROLE_USER", "ROLE_ADMIN"]),
            "isEnabled": True,
            "isAccountNonExpired": True,
            "isAccountNonLocked": True,
            "isCredentialsNonExpired": True
        }
    }

def generate_product_data():
    """Generate realistic product data for testing"""
    categories = ["Electronics", "Clothing", "Books", "Home & Garden", "Sports"]
    
    return {
        "productTitle": fake.catch_phrase(),
        "imageUrl": fake.image_url(),
        "sku": fake.ean8(),
        "priceUnit": round(random.uniform(10.0, 999.99), 2),
        "quantity": random.randint(1, 100),
        "categoryDto": {
            "categoryTitle": random.choice(categories),
            "imageUrl": fake.image_url()
        }
    }

def generate_order_data():
    """Generate realistic order data for testing"""
    return {
        "orderDate": fake.date_time_this_year().isoformat(),
        "orderDesc": f"Order for {fake.catch_phrase()}",
        "orderFee": round(random.uniform(10.0, 500.0), 2)
    }

if __name__ == "__main__":
    # Generate sample data files
    with open("users_sample.json", "w") as f:
        users = [generate_user_data() for _ in range(100)]
        json.dump(users, f, indent=2)
    
    with open("products_sample.json", "w") as f:
        products = [generate_product_data() for _ in range(50)]
        json.dump(products, f, indent=2)
    
    with open("orders_sample.json", "w") as f:
        orders = [generate_order_data() for _ in range(30)]
        json.dump(orders, f, indent=2)
    
    print("Sample data files generated successfully!")
EOF

    # Create run script
    cat > src/test/performance/scripts/run_performance_tests.sh << 'EOF'
#!/bin/bash

# Performance Test Runner Script

set -e

# Configuration
HOST=${HOST:-"http://localhost:8080"}
USERS=${USERS:-50}
SPAWN_RATE=${SPAWN_RATE:-5}
RUN_TIME=${RUN_TIME:-300}
LOCUSTFILE=${LOCUSTFILE:-"../locustfile.py"}

echo "=== Running Performance Tests ==="
echo "Host: $HOST"
echo "Users: $USERS"
echo "Spawn Rate: $SPAWN_RATE"
echo "Run Time: $RUN_TIME"
echo "================================"

# Activate virtual environment if it exists
if [ -d "../../../venv" ]; then
    source ../../../venv/bin/activate
fi

# Run Locust in headless mode
locust \
    --config ../config/locust.conf \
    --locustfile $LOCUSTFILE \
    --headless \
    --users $USERS \
    --spawn-rate $SPAWN_RATE \
    --run-time $RUN_TIME \
    --host $HOST

echo "Performance tests completed!"
echo "Reports available in: ../reports/"
EOF

    chmod +x src/test/performance/scripts/run_performance_tests.sh
    
    log_info "Configuration files created."
}

# Create Jenkins integration script
create_jenkins_integration() {
    log_info "Creating Jenkins integration script..."
    
    cat > scripts/jenkins-performance-tests.sh << 'EOF'
#!/bin/bash

# Jenkins Performance Tests Integration
# Run performance tests as part of CI/CD pipeline

set -e

echo "=== Jenkins Performance Tests Integration ==="

# Variables
WORKSPACE=${WORKSPACE:-$(pwd)}
BUILD_NUMBER=${BUILD_NUMBER:-"local"}
SERVICE_URL=${SERVICE_URL:-"http://localhost:8080"}
PERFORMANCE_THRESHOLD_RESPONSE_TIME=${PERFORMANCE_THRESHOLD_RESPONSE_TIME:-500}
PERFORMANCE_THRESHOLD_ERROR_RATE=${PERFORMANCE_THRESHOLD_ERROR_RATE:-1}

# Navigate to workspace
cd $WORKSPACE

# Setup Python virtual environment
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

source venv/bin/activate
pip install -q locust requests faker

# Wait for service to be ready
echo "Waiting for service to be ready..."
for i in {1..30}; do
    if curl -f $SERVICE_URL/actuator/health > /dev/null 2>&1; then
        echo "Service is ready!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 10
done

# Run performance tests
echo "Running performance tests..."
cd src/test/performance

locust \
    --locustfile locustfile.py \
    --headless \
    --users 20 \
    --spawn-rate 2 \
    --run-time 60s \
    --host $SERVICE_URL \
    --html reports/performance-report-$BUILD_NUMBER.html \
    --csv reports/performance-data-$BUILD_NUMBER \
    --loglevel INFO

# Parse results and check thresholds
echo "Analyzing performance results..."
python3 << PYTHON_SCRIPT
import csv
import sys

# Read performance data
try:
    with open('reports/performance-data-${BUILD_NUMBER}_stats.csv', 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row['Name'] == 'Aggregated':
                avg_response_time = float(row['Average Response Time'])
                error_rate = float(row['Failure Count']) / float(row['Request Count']) * 100 if float(row['Request Count']) > 0 else 0
                
                print(f"Average Response Time: {avg_response_time:.2f}ms")
                print(f"Error Rate: {error_rate:.2f}%")
                
                # Check thresholds
                if avg_response_time > $PERFORMANCE_THRESHOLD_RESPONSE_TIME:
                    print(f"ERROR: Average response time ({avg_response_time:.2f}ms) exceeds threshold ($PERFORMANCE_THRESHOLD_RESPONSE_TIME ms)")
                    sys.exit(1)
                
                if error_rate > $PERFORMANCE_THRESHOLD_ERROR_RATE:
                    print(f"ERROR: Error rate ({error_rate:.2f}%) exceeds threshold ($PERFORMANCE_THRESHOLD_ERROR_RATE%)")
                    sys.exit(1)
                
                print("Performance tests passed all thresholds!")
                break
        else:
            print("ERROR: Could not find aggregated results")
            sys.exit(1)
            
except FileNotFoundError:
    print("ERROR: Performance results file not found")
    sys.exit(1)
except Exception as e:
    print(f"ERROR: Failed to parse performance results: {e}")
    sys.exit(1)
PYTHON_SCRIPT

echo "Performance tests completed successfully!"
EOF

    chmod +x scripts/jenkins-performance-tests.sh
    
    log_info "Jenkins integration script created."
}

# Create monitoring script
create_monitoring_script() {
    log_info "Creating monitoring script..."
    
    cat > scripts/monitor-performance.sh << 'EOF'
#!/bin/bash

# Performance Monitoring Script
# Monitor real-time performance metrics

echo "=== Performance Monitoring ==="

# Check if services are running
check_service() {
    local service_name=$1
    local port=$2
    
    if curl -f http://localhost:$port/actuator/health > /dev/null 2>&1; then
        echo "✓ $service_name (port $port) - Healthy"
    else
        echo "✗ $service_name (port $port) - Not responding"
    fi
}

echo "Checking service health..."
check_service "API Gateway" 8080
check_service "User Service" 8081
check_service "Product Service" 8082
check_service "Order Service" 8083
check_service "Payment Service" 8084
check_service "Shipping Service" 8085
check_service "Favourite Service" 8086
check_service "Service Discovery" 8761

echo ""
echo "Starting Locust web interface..."
echo "Access the performance testing dashboard at: http://localhost:8089"

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
fi

cd src/test/performance
locust --config config/locust.conf --locustfile locustfile.py
EOF

    chmod +x scripts/monitor-performance.sh
    
    log_info "Monitoring script created."
}

# Main execution
main() {
    log_info "Starting performance testing setup..."
    
    check_python
    check_pip
    install_locust
    setup_directories
    create_config_files
    create_jenkins_integration
    create_monitoring_script
    
    log_info "Performance testing environment setup completed!"
    echo ""
    echo "Next steps:"
    echo "1. Copy the locustfile.py to src/test/performance/"
    echo "2. Run performance tests: ./scripts/monitor-performance.sh"
    echo "3. For Jenkins integration: ./scripts/jenkins-performance-tests.sh"
    echo ""
    echo "Available commands:"
    echo "- Start Locust web UI: ./scripts/monitor-performance.sh"
    echo "- Run headless tests: cd src/test/performance && ./scripts/run_performance_tests.sh"
    echo "- Generate test data: cd src/test/performance/data && python3 test_data_generator.py"
}

# Execute main function
main "$@" 