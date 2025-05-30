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
        lsb-release && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli && \
    rm -rf /var/lib/apt/lists/*

# Add jenkins user to docker group and fix permissions
RUN groupadd -g 999 docker && usermod -aG docker jenkins
RUN usermod -aG root jenkins

# Install suggested plugins as jenkins user
USER jenkins
RUN jenkins-plugin-cli --plugins \
    ant:511.v0a_a_1a_334f41b_ \
    build-timeout:1.33 \
    credentials-binding:681.vf91669a_32e45 \
    email-ext:1844.v3ea_a_b_842374a_ \
    git:5.5.2 \
    github-branch-source:1807.v50351eb_7dd13 \
    gradle:2.15 \
    ldap:725.v3cb_b_711b_1a_ef \
    mailer:488.v0c9639c1a_eb_3 \
    matrix-auth:3.2.2 \
    pam-auth:1.11 \
    pipeline-github-lib:61.v629f2cc41d83 \
    pipeline-stage-view:2.34 \
    ssh-slaves:2.973.v0fa_8c0dea_f9f \
    timestamper:1.27 \
    workflow-aggregator:600.vb_57cdd26fdd7 \
    ws-cleanup:0.47 \
    docker-workflow:580.vc0c340686b_54

# Switch back to root for runtime
USER root 