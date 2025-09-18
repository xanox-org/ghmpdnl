# Use Eclipse Temurin 17 runtime as base image
FROM eclipse-temurin:17-jre

# Set working directory
WORKDIR /app

# Install curl for health check in one layer
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

# Create user for security in one layer
RUN groupadd -r graphhopper && useradd -r -g graphhopper graphhopper

# Copy configuration files first (they change less frequently)
COPY docker-config.yml /tmp/config.yml
COPY moped_nl_model.json /tmp/moped_nl_model.json

# Copy the fat JAR file (most likely to change, so put it later for better caching)
COPY web/target/graphhopper-web-*.jar app.jar

# Create directories and set permissions in one layer
RUN mkdir -p /app/volume && \
    chown -R graphhopper:graphhopper /app

# Switch to non-root user
USER graphhopper

# Expose the default port
EXPOSE 8989

# Health check - wait for application to be ready
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8989/info || exit 1

# Set optimized JVM options for container environment
ENV JAVA_OPTS="-Xmx2g -Xms1g -XX:+UseG1GC -XX:+UseContainerSupport -XX:MaxGCPauseMillis=100"

# Default command to run the application
CMD ["sh", "-c", "cp -n /tmp/config.yml /app/volume/config.yml 2>/dev/null || true && java $JAVA_OPTS -jar app.jar server /app/volume/config.yml"]