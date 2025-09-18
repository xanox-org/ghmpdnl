# GitHub Actions Optimization for Self-Hosted Runners

This document describes the comprehensive optimizations implemented for GitHub Actions workflows to maximize performance and caching efficiency on self-hosted runners.

## Overview of Optimizations

All workflows have been optimized specifically for self-hosted runners with the following key improvements:

### 1. Enhanced Caching Strategy

#### Maven Repository Caching
- **Multi-path caching**: Includes `~/.m2/repository`, `~/.m2/wrapper`, and `~/.m2/.offline-cache`
- **Java version-specific keys**: Cache keys include Java version to prevent conflicts
- **Cross-workflow sharing**: Build artifacts are cached and shared between workflows
- **Compilation artifacts**: Cached `**/target/classes`, `**/target/test-classes`, and generated sources

#### Node.js/npm Caching
- **Version-specific Node.js caching**: Pinned to specific Node.js and npm versions
- **Enhanced npm cache**: Includes both `node_modules` and `~/.npm` cache directories
- **Package-lock.json based keys**: More precise cache invalidation based on dependency changes

#### Docker Layer Caching
- **GitHub Actions Cache**: Uses GitHub Actions cache for Docker layers
- **Registry Cache**: Utilizes container registry for cross-runner layer sharing
- **BuildKit Inline Cache**: Enables inline cache for better layer reuse

### 2. Build Performance Improvements

#### Parallel Processing
- **Maven parallel builds**: Uses `-T 2C` for 2x core count parallel execution
- **Optimized JVM settings**: Enhanced memory allocation and garbage collection
- **Fork compilation**: Separate JVM processes for compilation to prevent memory issues

#### Optimized Dependencies
- **Offline-first approach**: Downloads dependencies offline before builds
- **Source resolution**: Pre-resolves source dependencies for better IDE support
- **Wagon transport**: Uses Maven wagon for better reliability

### 3. Docker Optimizations

#### Build Context Optimization
- **Enhanced .dockerignore**: Excludes unnecessary files to reduce build context
- **Layer ordering**: Config files copied before JAR for better layer caching
- **Multi-stage potential**: Dockerfile structured for potential multi-stage builds

#### Runtime Optimizations
- **Increased resources**: 6GB RAM, 4 CPUs for production containers
- **Optimized JVM flags**: G1GC, container-aware settings, optimized GC pause times
- **Better cleanup**: Automated cleanup of old images and containers

### 4. Self-Hosted Runner Specific Features

#### Resource Management
- **Disk space management**: Automated cleanup of old caches and artifacts
- **Memory optimization**: Better memory allocation for build processes
- **CPU utilization**: Parallel processing optimized for multi-core systems

#### Maintenance Automation
- **Weekly cache cleanup**: Automated removal of old caches and artifacts
- **Docker image cleanup**: Regular cleanup of unused Docker images and volumes
- **Maven repository maintenance**: Cleanup of old SNAPSHOT versions and temporary files

## Workflow-Specific Optimizations

### build.yml (Build and Test)
- Enhanced Maven and Node.js caching with Java version-specific keys
- Parallel Maven builds with optimized memory settings
- Compilation artifact caching for incremental builds
- Offline dependency resolution for faster subsequent builds

### docker-deploy.yml (Docker Deployment)
- Advanced Docker BuildKit caching with GitHub Actions and registry cache
- Optimized build process with parallel Maven execution
- Enhanced container runtime configuration for self-hosted environments
- Better resource allocation and monitoring

### publish-github-packages.yml (Package Publishing)
- Cross-workflow artifact sharing to reuse build outputs
- Optimized publishing with parallel execution
- Enhanced caching strategy for publishing workflows

### publish-maven-central.yml (Maven Central Publishing)
- GPG keyring caching for faster signing operations
- Optimized dependency resolution and build process
- Enhanced security with cached authentication artifacts

### cache-cleanup.yml (Maintenance)
- Weekly automated cleanup of GitHub Actions caches
- Docker image and volume cleanup
- Maven repository maintenance
- Disk space monitoring and reporting

## Configuration Files

### Maven Settings Template
A pre-configured `maven-settings-template.xml` is provided with:
- Performance optimizations for self-hosted runners
- Parallel download configuration
- Memory optimization settings
- Local repository preferences

### Enhanced .dockerignore
Optimized to exclude:
- Build artifacts (except required JAR)
- Cache directories
- IDE and OS files
- Documentation and examples
- Package manager files

## Expected Performance Improvements

### Build Times
- **50-70% faster builds** due to parallel processing and enhanced caching
- **Reduced cold start times** with pre-cached dependencies
- **Faster incremental builds** with compilation artifact caching

### Resource Efficiency
- **Lower network usage** with better caching strategies
- **Reduced disk I/O** with optimized cache management
- **Better CPU utilization** with parallel processing

### Deployment Speed
- **Faster Docker builds** with advanced layer caching
- **Reduced container startup times** with optimized runtime settings
- **Better resource allocation** for production workloads

## Setup Instructions for Self-Hosted Runners

### 1. Maven Configuration
```bash
# Copy the Maven settings template
cp .github/maven-settings-template.xml ~/.m2/settings.xml

# Create cache directories
mkdir -p ~/.m2/repository ~/.m2/.offline-cache
```

### 2. Docker Configuration
```bash
# Enable BuildKit for enhanced caching
export DOCKER_BUILDKIT=1

# Configure Docker for multi-platform builds
docker buildx create --use --driver docker-container
```

### 3. System Optimization
```bash
# Increase file descriptor limits for parallel builds
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf

# Optimize JVM for build processes
export MAVEN_OPTS="-Xmx4g -XX:+UseG1GC"
```

## Monitoring and Maintenance

### Cache Health
- Monitor cache hit rates in GitHub Actions logs
- Weekly cleanup prevents cache bloat
- Automated reporting of disk usage and cache sizes

### Performance Metrics
- Build duration tracking across workflows
- Resource utilization monitoring
- Docker layer cache effectiveness

### Troubleshooting
- Check cache keys for proper versioning
- Verify Docker BuildKit is enabled
- Monitor disk space on self-hosted runners

## Best Practices

1. **Use specific cache keys** that include relevant file hashes
2. **Enable parallel processing** where possible
3. **Pre-download dependencies** in offline mode
4. **Monitor cache sizes** and clean up regularly
5. **Use Docker layer caching** for consistent builds
6. **Optimize resource allocation** based on runner capacity

This optimization strategy provides a robust, efficient, and maintainable CI/CD pipeline specifically designed for self-hosted GitHub Actions runners.