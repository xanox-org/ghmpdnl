# Use Eclipse Temurin 17 runtime as base image
FROM eclipse-temurin:17-jre

# Set working directory
WORKDIR /app

# Install curl for health check
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create user for security
RUN groupadd -r graphhopper && useradd -r -g graphhopper graphhopper

# Copy the fat JAR file
COPY web/target/graphhopper-web-*.jar app.jar

# Copy configuration file
COPY docker-config.yml /tmp/config.yml

# Create directories for data and cache  
RUN mkdir -p /app/volume && \
    chown -R graphhopper:graphhopper /app

# Switch to non-root user
USER graphhopper

# Expose the default port
EXPOSE 8989

# Health check - wait for application to be ready
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8989/info || exit 1

# Set JVM options for container environment
ENV JAVA_OPTS="-Xmx2g -Xms1g"

# Default command to run the application
CMD ["sh", "-c", "cp -n /tmp/config.yml /app/volume/config.yml 2>/dev/null || true && java $JAVA_OPTS -jar app.jar server /app/volume/config.yml"]