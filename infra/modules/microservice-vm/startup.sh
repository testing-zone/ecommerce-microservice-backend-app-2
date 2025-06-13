#!/bin/bash
set -e

# Log all output
exec > >(tee -a /var/log/startup-script.log)
exec 2>&1

echo "Starting VM setup..."

# Update system first
apt-get update -y

# Install necessary packages
apt-get install -y sudo curl wget git nano htop

# Create user account
USERNAME="${username}"
PASSWORD="${password}"

echo "Creating user: $USERNAME"

# Create user if it doesn't exist
if ! id "$USERNAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USERNAME"
    echo "$USERNAME:$PASSWORD" | chpasswd
    usermod -aG sudo "$USERNAME"
    echo "User $USERNAME created successfully"
else
    echo "User $USERNAME already exists, updating password"
    echo "$USERNAME:$PASSWORD" | chpasswd
fi

# Configure SSH for password authentication
echo "Configuring SSH for password authentication..."
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config

# Add these lines if they don't exist
if ! grep -q "PasswordAuthentication yes" /etc/ssh/sshd_config; then
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
fi

# Restart SSH service
echo "Restarting SSH service..."
systemctl restart ssh
systemctl enable ssh

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker "$USERNAME"

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Wait for Docker to be ready
sleep 10

echo "Setting up microservices..."

# Create application directory
APP_DIR="/home/${username}/microservices"
mkdir -p $APP_DIR

# Create docker-compose.yml for microservices
cat > $APP_DIR/docker-compose.yml << 'EOF'
version: '3.8'
services:
%{ for service in microservices ~}
  ${service.name}:
    image: ${service.image}
    ports:
      - "${service.port}:${service.port}"
    environment:
      - PORT=${service.port}
      - SERVICE_NAME=${service.name}
    restart: unless-stopped
    networks:
      - microservices-net

%{ endfor ~}
networks:
  microservices-net:
    driver: bridge
EOF

# Set proper ownership
chown -R ${username}:${username} $APP_DIR

# Create startup script for microservices
cat > $APP_DIR/start-services.sh << 'EOF'
#!/bin/bash
cd /home/${username}/microservices
docker-compose pull
docker-compose up -d
EOF

chmod +x $APP_DIR/start-services.sh
chown ${username}:${username} $APP_DIR/start-services.sh

# Create systemd service for microservices
cat > /etc/systemd/system/microservices.service << EOF
[Unit]
Description=Microservices Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
User=${username}
Group=${username}
WorkingDirectory=/home/${username}/microservices
ExecStart=/bin/bash /home/${username}/microservices/start-services.sh
ExecStop=/usr/local/bin/docker-compose down

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the microservices
systemctl daemon-reload
systemctl enable microservices
systemctl start microservices

# Create a welcome message
cat > /home/${username}/README.txt << EOF
Welcome to your Microservices VM!

Connection Details:
- Username: ${username}
- Use the password provided in Terraform output

Useful Commands:
- Check microservices: docker ps
- View logs: docker-compose -f ~/microservices/docker-compose.yml logs
- Restart services: sudo systemctl restart microservices

Your microservices are running on ports 8001-8010
EOF

chown ${username}:${username} /home/${username}/README.txt

echo "VM setup completed successfully!"
echo "User: $USERNAME"
echo "SSH configuration updated for password authentication"