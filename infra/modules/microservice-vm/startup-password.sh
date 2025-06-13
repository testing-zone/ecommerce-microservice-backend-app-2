#!/bin/bash
set -e

# Log all output
exec > >(tee -a /var/log/startup-script.log)
exec 2>&1

echo "Starting VM setup with FORCED password authentication..."

# Update system first
apt-get update -y

# Install necessary packages
apt-get install -y sudo curl wget git nano htop

# Create user account
USERNAME="${username}"
PASSWORD="${password}"

echo "Creating user: $USERNAME with password authentication"

# Remove the user if exists and recreate
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME exists, removing..."
    userdel -r "$USERNAME" 2>/dev/null || true
fi

# Create user with home directory
useradd -m -s /bin/bash "$USERNAME"
echo "$USERNAME:$PASSWORD" | chpasswd
usermod -aG sudo "$USERNAME"

# Ensure user has proper shell
chsh -s /bin/bash "$USERNAME"

echo "User $USERNAME created with password: $PASSWORD"

# FORCE SSH configuration for password authentication
echo "Configuring SSH for password authentication..."

# Backup original config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Create new SSH config that FORCES password authentication
cat > /etc/ssh/sshd_config << 'EOF'
# Custom SSH config for password authentication
Port 22
Protocol 2

# Authentication
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication yes
UsePAM yes

# Disable key-based auth temporarily to force password
PubkeyAuthentication no

# Security settings
PermitRootLogin no
MaxAuthTries 3
LoginGraceTime 60

# Allow our user
AllowUsers REPLACE_USERNAME

# Logging
SyslogFacility AUTH
LogLevel INFO

# Other settings
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

# Replace the username placeholder
sed -i "s/REPLACE_USERNAME/$USERNAME/g" /etc/ssh/sshd_config

# Restart SSH service multiple times to ensure it takes
echo "Restarting SSH service..."
systemctl stop ssh
sleep 5
systemctl start ssh
systemctl enable ssh

# Verify SSH is running
systemctl status ssh

# Also disable OS Login metadata if it exists
echo "Disabling OS Login..."
curl -X PUT http://metadata.google.internal/computeMetadata/v1/instance/attributes/enable-oslogin \
  -H "Metadata-Flavor: Google" \
  -d "FALSE" 2>/dev/null || echo "Could not disable OS Login via metadata"

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
APP_DIR="/home/$USERNAME/microservices"
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
chown -R $USERNAME:$USERNAME $APP_DIR

# Create startup script for microservices
cat > $APP_DIR/start-services.sh << EOF
#!/bin/bash
cd /home/$USERNAME/microservices
docker-compose pull
docker-compose up -d
EOF

chmod +x $APP_DIR/start-services.sh
chown $USERNAME:$USERNAME $APP_DIR/start-services.sh

# Create systemd service for microservices
cat > /etc/systemd/system/microservices.service << EOF
[Unit]
Description=Microservices Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=true
User=$USERNAME
Group=$USERNAME
WorkingDirectory=/home/$USERNAME/microservices
ExecStart=/bin/bash /home/$USERNAME/microservices/start-services.sh
ExecStop=/usr/local/bin/docker-compose down

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the microservices
systemctl daemon-reload
systemctl enable microservices
systemctl start microservices

# Create a connection info file
cat > /home/$USERNAME/connection_info.txt << EOF
VM Connection Information
========================

Username: $USERNAME
Password: $PASSWORD
IP: $(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")

Connection command:
ssh $USERNAME@$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip -H "Metadata-Flavor: Google")

Note: SSH is configured for PASSWORD authentication only.
PubkeyAuthentication is DISABLED to force password auth.
EOF

chown $USERNAME:$USERNAME /home/$USERNAME/connection_info.txt

# Final SSH restart
echo "Final SSH service restart..."
systemctl restart ssh

echo "VM setup completed!"
echo "Username: $USERNAME"
echo "Password: $PASSWORD"
echo "SSH configured for password authentication"
echo "PubkeyAuthentication is DISABLED to force password auth"
