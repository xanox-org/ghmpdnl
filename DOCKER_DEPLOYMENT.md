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
- **Volume**: 
  - `graphhopper:/app/volume` - Persistent volume containing:
    - `config.yml` - Application configuration
    - `data/` - Directory for input data files (OSM PBF files)
    - `graph-cache/` - Directory for processed graph data

## Configuration

The container uses the `docker-config.yml` configuration file which:
- Binds to all interfaces (0.0.0.0)
- Sets up basic car routing profile
- Uses RAM storage for the graph
- Configures console logging
- References data files in the persistent volume (`/app/volume/data/map.osm.pbf`)
- Stores graph cache in the persistent volume (`/app/volume/graph-cache`)

## Usage

Once deployed, the GraphHopper API will be available at:
- **API Endpoint**: `http://<your-host>:8989/`
- **Health Check**: `http://<your-host>:8989/health`
- **Admin Interface**: `http://<your-host>:8990/`

## Adding Data

To use the routing engine, you need to:

1. Place OSM PBF files in the volume's data directory
2. The configuration is already set to look for `/app/volume/data/map.osm.pbf`
3. Restart the container to import the data

Example:
```bash
# Copy your OSM file to the volume (using a temporary container)
docker run --rm -v graphhopper:/volume -v "$(pwd)":/host alpine:latest \
  cp /host/some-region.osm.pbf /volume/data/map.osm.pbf

# Restart the container to process the new data
docker restart ghmpdnl

# Check logs to see the import progress
docker logs -f ghmpdnl
```

## Managing the Volume

You can inspect or modify the volume contents:

```bash
# Browse the volume contents
docker run --rm -it -v graphhopper:/volume alpine:latest ls -la /volume

# Access volume for maintenance
docker run --rm -it -v graphhopper:/volume alpine:latest sh
```

## Secrets Required

The deployment workflow requires these organization secrets:
- `SSH_HOST` - The hostname/IP of your Docker host
- `SSH_USER` - SSH username for the Docker host
- `SSH_PRIVATE_KEY` - SSH private key for authentication