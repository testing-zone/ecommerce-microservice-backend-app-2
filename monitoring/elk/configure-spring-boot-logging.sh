#!/bin/bash

# Script para configurar logging en microservicios Spring Boot para ELK Stack
# Autor: Sistema de Monitoreo E-commerce

set -e

echo "🔧 Configurando logging para ELK Stack en microservicios..."

# Servicios a configurar
SERVICES=("user-service" "product-service" "order-service" "payment-service" "shipping-service" "favourite-service" "api-gateway" "service-discovery" "proxy-client")

# Función para agregar configuración de logging a application.yml
configure_logging() {
    local service=$1
    local config_file="${service}/src/main/resources/application.yml"
    
    if [[ ! -f "$config_file" ]]; then
        echo "⚠️  No se encontró $config_file, saltando..."
        return
    fi
    
    echo "📝 Configurando logging para $service..."
    
    # Backup del archivo original
    cp "$config_file" "${config_file}.backup"
    
    # Agregar configuración de logging si no existe
    if ! grep -q "logstash" "$config_file"; then
        cat >> "$config_file" << EOF

# Configuración de Logging para ELK Stack
logging:
  level:
    com.selimhorri: DEBUG
    org.springframework.web: INFO
    org.springframework.security: DEBUG
    feign: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level [%logger{36}] - %msg%n"
    file: "%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level [%logger{36}] - %msg%n"
  file:
    name: logs/${service}.log
    max-size: 100MB
    max-history: 30

# Configuración para envío a Logstash
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,loggers,logfile
  endpoint:
    health:
      show-details: always
    logfile:
      enabled: true

# Configuración adicional para métricas de logs
spring:
  application:
    name: ${service}
  sleuth:
    zipkin:
      base-url: http://jaeger:9411
    sampler:
      probability: 1.0
  boot:
    admin:
      client:
        url: http://localhost:8080
        instance:
          service-base-url: http://localhost:\${server.port}
EOF
    else
        echo "✅ Configuración de logging ya existe en $service"
    fi
}

# Función para agregar dependencias de logging a pom.xml
add_logging_dependencies() {
    local service=$1
    local pom_file="${service}/pom.xml"
    
    if [[ ! -f "$pom_file" ]]; then
        echo "⚠️  No se encontró $pom_file, saltando..."
        return
    fi
    
    echo "📦 Agregando dependencias de logging a $service..."
    
    # Backup del archivo original
    cp "$pom_file" "${pom_file}.backup"
    
    # Verificar si ya existen las dependencias
    if ! grep -q "logstash-logback-encoder" "$pom_file"; then
        # Buscar la sección de dependencies y agregar antes del cierre
        sed -i.tmp '/<\/dependencies>/i\
        <!-- Logging para ELK Stack -->\
        <dependency>\
            <groupId>net.logstash.logback</groupId>\
            <artifactId>logstash-logback-encoder</artifactId>\
            <version>7.3</version>\
        </dependency>\
        <dependency>\
            <groupId>ch.qos.logback</groupId>\
            <artifactId>logback-classic</artifactId>\
        </dependency>\
        <dependency>\
            <groupId>org.springframework.boot</groupId>\
            <artifactId>spring-boot-starter-actuator</artifactId>\
        </dependency>' "$pom_file"
        
        rm "${pom_file}.tmp" 2>/dev/null || true
        echo "✅ Dependencias agregadas a $service"
    else
        echo "✅ Dependencias de logging ya existen en $service"
    fi
}

# Función para crear configuración de Logback
create_logback_config() {
    local service=$1
    local logback_file="${service}/src/main/resources/logback-spring.xml"
    
    echo "📄 Creando configuración Logback para $service..."
    
    mkdir -p "${service}/src/main/resources"
    
    cat > "$logback_file" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <include resource="org/springframework/boot/logging/logback/defaults.xml"/>
    
    <!-- Console Appender -->
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>\${CONSOLE_LOG_PATTERN}</pattern>
        </encoder>
    </appender>
    
    <!-- File Appender -->
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/${service}.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/${service}.%d{yyyy-MM-dd}.%i.log</fileNamePattern>
            <maxFileSize>100MB</maxFileSize>
            <maxHistory>30</maxHistory>
            <totalSizeCap>3GB</totalSizeCap>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level [%logger{36}] - %msg%n</pattern>
        </encoder>
    </appender>
    
    <!-- Logstash TCP Appender -->
    <appender name="LOGSTASH" class="net.logstash.logback.appender.LogstashTcpSocketAppender">
        <destination>logstash:5000</destination>
        <encoder class="net.logstash.logback.encoder.LoggingEventCompositeJsonEncoder">
            <providers>
                <timestamp/>
                <logLevel/>
                <loggerName/>
                <message/>
                <mdc/>
                <arguments/>
                <stackTrace/>
                <pattern>
                    <pattern>
                        {
                            "service_name": "${service}",
                            "environment": "\${spring.profiles.active:-default}",
                            "host": "\${HOSTNAME:-localhost}"
                        }
                    </pattern>
                </pattern>
            </providers>
        </encoder>
        <connectionTimeout>5000</connectionTimeout>
        <reconnectionDelay>1000</reconnectionDelay>
    </appender>
    
    <!-- Async Logstash Appender -->
    <appender name="ASYNC_LOGSTASH" class="ch.qos.logback.classic.AsyncAppender">
        <appender-ref ref="LOGSTASH"/>
        <queueSize>512</queueSize>
        <discardingThreshold>0</discardingThreshold>
    </appender>
    
    <!-- Root Logger -->
    <root level="INFO">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="FILE"/>
        <appender-ref ref="ASYNC_LOGSTASH"/>
    </root>
    
    <!-- Specific Loggers -->
    <logger name="com.selimhorri" level="DEBUG"/>
    <logger name="org.springframework.web" level="INFO"/>
    <logger name="org.springframework.security" level="DEBUG"/>
    <logger name="feign" level="DEBUG"/>
    <logger name="org.springframework.cloud.sleuth" level="DEBUG"/>
    
    <!-- Performance Logger -->
    <logger name="performance" level="INFO" additivity="false">
        <appender-ref ref="ASYNC_LOGSTASH"/>
    </logger>
    
    <!-- Error Logger -->
    <logger name="error" level="ERROR" additivity="false">
        <appender-ref ref="CONSOLE"/>
        <appender-ref ref="ASYNC_LOGSTASH"/>
    </logger>
</configuration>
EOF
    
    echo "✅ Configuración Logback creada para $service"
}

# Función principal
main() {
    echo "🚀 Iniciando configuración de ELK Stack para microservicios..."
    
    for service in "${SERVICES[@]}"; do
        if [[ -d "$service" ]]; then
            echo ""
            echo "🔧 Procesando $service..."
            configure_logging "$service"
            add_logging_dependencies "$service"
            create_logback_config "$service"
            
            # Crear directorio de logs
            mkdir -p "${service}/logs"
            echo "📁 Directorio de logs creado para $service"
        else
            echo "⚠️  Directorio $service no encontrado, saltando..."
        fi
    done
    
    echo ""
    echo "✅ Configuración completada!"
    echo ""
    echo "📋 Próximos pasos:"
    echo "1. Desplegar ELK Stack: kubectl apply -f monitoring/elk/"
    echo "2. Verificar que Elasticsearch esté funcionando: curl http://localhost:30920"
    echo "3. Acceder a Kibana: http://localhost:30601"
    echo "4. Recompilar y redesplegar los microservicios"
    echo "5. Configurar índices en Kibana: ecommerce-logs-*"
    echo ""
    echo "🔍 URLs de acceso:"
    echo "- Kibana: http://localhost:30601"
    echo "- Elasticsearch: http://localhost:30920"
    echo "- Logstash TCP: localhost:30500"
    echo "- Logstash HTTP: http://localhost:30580"
}

# Ejecutar función principal
main "$@" 