# GraphHopper Docker Deployment

This repository has been configured to automatically build and deploy a Docker container for the GraphHopper routing engine.

## Automatic Deployment

The GitHub Actions workflow `docker-deploy.yml` will automatically:

1. Build the GraphHopper application using Maven
2. Create a Docker image named `ghmpdnl`
3. Deploy it to the configured Docker host using SSH

## Docker Container Details

- **Container Name**: `ghmpdnl`
- **Port**: 8989 (HTTP API)
- **Admin Port**: 8990 (Admin interface)
- **Volumes**:
  - `~/ghmpdnl/data:/app/data` - For input data files (OSM PBF files)
  - `~/ghmpdnl/graph-cache:/app/graph-cache` - For processed graph data

## Configuration

The container uses the `docker-config.yml` configuration file which:
- Binds to all interfaces (0.0.0.0)
- Sets up basic car routing profile
- Uses RAM storage for the graph
- Configures console logging

## Usage

Once deployed, the GraphHopper API will be available at:
- **API Endpoint**: `http://<your-host>:8989/`
- **Health Check**: `http://<your-host>:8989/health`
- **Admin Interface**: `http://<your-host>:8990/`

## Adding Data

To use the routing engine, you need to:

1. Place OSM PBF files in the `~/ghmpdnl/data/` directory on your Docker host
2. Update the configuration to point to your data file
3. Restart the container to import the data

Example:
```bash
# Place your OSM file
cp some-region.osm.pbf ~/ghmpdnl/data/

# Restart container with data file
docker stop ghmpdnl
docker run -d \
  --name ghmpdnl \
  --restart unless-stopped \
  -p 8989:8989 \
  -v ~/ghmpdnl/data:/app/data \
  -v ~/ghmpdnl/graph-cache:/app/graph-cache \
  -e JAVA_OPTS="-Xmx4g -Xms2g -Ddw.graphhopper.datareader.file=/app/data/some-region.osm.pbf" \
  ghmpdnl:latest
```

## Secrets Required

The deployment workflow requires these organization secrets:
- `SSH_HOST` - The hostname/IP of your Docker host
- `SSH_USER` - SSH username for the Docker host
- `SSH_PRIVATE_KEY` - SSH private key for authentication