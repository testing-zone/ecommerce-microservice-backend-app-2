FROM openjdk:11-jre-slim

# Metadata
LABEL maintainer="ecommerce-team"
LABEL version="0.1.0"
LABEL description="Payment Service for E-commerce Microservices"

# Arguments
ARG PROJECT_VERSION=0.1.0
ARG JAR_FILE=target/payment-service-v${PROJECT_VERSION}.jar

# Create app directory
RUN mkdir -p /home/app
WORKDIR /home/app

# Environment variables
ENV SPRING_PROFILES_ACTIVE=dev
ENV JAVA_OPTS="-Xmx512m -Xms256m"

# Copy the jar file
COPY ${JAR_FILE} payment-service.jar

# Create non-root user
RUN groupadd -r appgroup && useradd -r -g appgroup appuser
RUN chown -R appuser:appgroup /home/app
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:8084/actuator/health || exit 1

# Expose port
EXPOSE 8084

# Entry point
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE} -jar payment-service.jar"]


