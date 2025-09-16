# GraphHopper Docker Deployment

This repository has been configured to automatically build and deploy a Docker container for the GraphHopper routing engine.

## Automatic Deployment

The GitHub Actions workflow `docker-deploy.yml` will automatically:

1. Build the GraphHopper application using Maven
2. Create a Docker image named `ghmpdnl`
3. Push the image to GitHub Container Registry (`ghcr.io/xanox-org/ghmpdnl`)
4. Deploy it to the configured Docker host by pulling from the registry

## Docker Container Details

- **Container Name**: `ghmpdnl`
- **Port**: 8989 (HTTP API)
- **Admin Port**: 8990 (Admin interface)
- **Volume**: 
  - `graphhopper:/app/volume` - Persistent volume containing:
    - `config.yml` - Application configuration
    - `custom_models/` - Directory for custom routing models
      - `moped_nl_model.json` - Moped routing model for Netherlands
    - `graph-cache/` - Directory for processed graph data
    - `logs/` - Directory for application logs
    - `netherlands-latest.osm.pbf` - Netherlands map data file

## Configuration

The container uses the `docker-config.yml` configuration file which:
- Binds to all interfaces (0.0.0.0)
- Sets up car and moped routing profiles
- Uses RAM storage for the graph
- Configures console and file logging to `/app/volume/logs/`
- References the Netherlands map file (`/app/volume/netherlands-latest.osm.pbf`)
- Stores graph cache in the persistent volume (`/app/volume/graph-cache`)
- Uses custom models from `/app/volume/custom_models/`

## Usage

Once deployed, the GraphHopper API will be available at:
- **API Endpoint**: `http://<your-host>:8989/`
- **Health Check**: `http://<your-host>:8989/health`
- **Admin Interface**: `http://<your-host>:8990/`

## Adding Data

To use the routing engine, you need to:

1. Place the Netherlands OSM PBF file in the volume root
2. The configuration is set to look for `/app/volume/netherlands-latest.osm.pbf`
3. Restart the container to import the data

Example:
```bash
# Copy your Netherlands OSM file to the volume (using a temporary container)
docker run --rm -v graphhopper:/volume -v "$(pwd)":/host alpine:latest \
  cp /host/netherlands-latest.osm.pbf /volume/netherlands-latest.osm.pbf

# Restart the container to process the new data
docker restart ghmpdnl

# Check logs to see the import progress
docker logs -f ghmpdnl
```

## Volume File Structure

The volume follows this structure:
```
/app/volume/
├── config.yml                      # Application configuration
├── custom_models/                  # Custom routing models
│   └── moped_nl_model.json         # Moped routing model for Netherlands
├── graph-cache/                    # Processed graph data (auto-generated)
│   ├── edgekv_keys
│   ├── edgekv_vals
│   ├── edges
│   ├── geometry
│   ├── location_index
│   ├── nodes
│   ├── nodes_ch_moped_nl
│   ├── properties
│   ├── properties.txt
│   └── shortcuts_moped_nl
├── logs/                           # Application logs
│   └── graphhopper.log
└── netherlands-latest.osm.pbf      # Netherlands map data
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

**Note**: Docker registry authentication is handled automatically using GitHub Container Registry (ghcr.io) with built-in GitHub Actions authentication. No additional registry secrets are required.

## Docker Registry Setup

The workflow uses GitHub Container Registry (ghcr.io) for storing and distributing Docker images:

### GitHub Container Registry (Current Setup)
- **Registry URL**: `ghcr.io`
- **Authentication**: Automatic using GitHub Actions built-in authentication
- **Image Location**: `ghcr.io/xanox-org/ghmpdnl`
- **Permissions**: Uses the `GITHUB_TOKEN` with automatic package write permissions
- **Username**: Uses `github.actor` (the user who triggered the workflow)

The workflow automatically:
1. Authenticates with GitHub Container Registry using built-in credentials
2. Builds the Docker image with the `ghcr.io/xanox-org/ghmpdnl` tag
3. Pushes both `:latest` and `:sha` tagged versions
4. Deploys from the registry to the target host

### Alternative Registry Options (if needed)
If you need to use a different registry, you would need to:

1. **Docker Hub**:
   - Add `DOCKER_REGISTRY_URL` secret: `docker.io`
   - Add `DOCKER_REGISTRY_USERNAME` secret: your Docker Hub username
   - Add `DOCKER_REGISTRY_PASSWORD` secret: your Docker Hub password or access token

2. **Private Registry**:
   - Add `DOCKER_REGISTRY_URL` secret: your registry URL (e.g., `registry.example.com`)
   - Add credentials according to your registry's authentication method