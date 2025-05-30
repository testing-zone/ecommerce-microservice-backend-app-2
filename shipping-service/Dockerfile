# Multi-stage build for shipping-service
FROM maven:3.9.9-openjdk-17-slim AS build

# Set working directory
WORKDIR /app

# Copy parent pom.xml and shipping-service specific files
COPY ../pom.xml ./parent-pom.xml
COPY pom.xml ./
COPY src/ ./src/

# Build the application
RUN mvn clean package -DskipTests

# Production stage
FROM openjdk:17.0.2-jdk-slim

# Install curl for health checks
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy the built jar from build stage
COPY --from=build /app/target/*.jar shipping-service.jar

# Create non-root user for security
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8085

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8085/shipping-service/actuator/health || exit 1

# Run the application
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "shipping-service.jar"]


