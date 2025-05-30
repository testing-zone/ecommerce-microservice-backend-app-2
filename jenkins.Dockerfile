FROM jenkins/jenkins:2.440.3-lts

# Switch to root user to install Docker
USER root

# Install Docker CLI for ARM64 architecture
RUN apt-get update && \
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        maven && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Add jenkins user to docker group and fix permissions
RUN groupadd -g 999 docker && usermod -aG docker jenkins
RUN usermod -aG root jenkins

# Switch back to jenkins user
USER jenkins

# Skip initial setup wizard
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Create admin user automatically
COPY --chown=jenkins:jenkins jenkins-config/ /usr/share/jenkins/ref/init.groovy.d/

# Switch back to root for runtime
USER root 