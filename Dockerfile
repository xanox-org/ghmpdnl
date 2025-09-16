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
COPY docker-config.yml config.yml

# Create directories for data and cache
RUN mkdir -p /app/data /app/graph-cache && \
    chown -R graphhopper:graphhopper /app

# Switch to non-root user
USER graphhopper

# Expose the default port
EXPOSE 8989

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8989/health || exit 1

# Set JVM options for container environment
ENV JAVA_OPTS="-Xmx2g -Xms1g"

# Default command to run the application
CMD ["sh", "-c", "java $JAVA_OPTS -jar app.jar server config.yml"]