# Docker Setup Usage Guide

## Files Recreated

✅ **docker-compose.clean.yml** - Simplified, working configuration
✅ **docker-compose.backup.yml** - Backup of removed configurations
✅ **grafana/provisioning/datasources/harperdb.yml** - Datasource config

## Key Features

### Consistent Naming
- Both single and cluster mode use `harper-0` as the primary node
- This allows the same Grafana datasource to work for both modes
- No configuration changes needed when switching between modes

### How to Use

#### Single Node Mode:
```bash
# Stop any existing containers
docker-compose down

# Use the clean compose file
cp docker-compose.clean.yml docker-compose.yml

# Start single node
docker-compose --profile single up -d
```

#### Cluster Mode (3 nodes):
```bash
# Stop any existing containers
docker-compose down

# Use the clean compose file
cp docker-compose.clean.yml docker-compose.yml

# Start cluster
docker-compose --profile cluster up -d
```

#### Default Mode (also single node):
```bash
docker-compose up -d
```

## Access Points

- **HarperDB**: http://localhost:9925
  - Username: `admin`
  - Password: `HarperRocks!`

- **Grafana**: http://localhost:3000
  - Username: `admin`
  - Password: `admin`

## Verify Setup

Run the test script:
```bash
./test-clean-setup.sh
```

## Container Names

| Mode | Container Names | Hostnames |
|------|----------------|-----------|
| Single | `harper-0`, `grafana` | `harper-0`, `grafana` |
| Cluster | `harper-0`, `harper-1`, `harper-2`, `grafana` | `harper-0`, `harper-1`, `harper-2`, `grafana` |

## Why This Works

1. **Same primary node name** - `harper-0` exists in both modes
2. **Consistent hostname** - Datasource always points to `http://harper-0:9925`
3. **Auto-provisioned** - Datasource configured automatically on Grafana startup
4. **No manual changes** - Switch between modes without reconfiguration

## Troubleshooting

If containers are running from a previous setup:
```bash
# Stop and remove all containers
docker-compose down

# Remove old containers if they exist
docker rm -f harper-cluster-node-0 harper-cluster-node-1 harper-cluster-node-2 harper-solo grafana

# Start fresh
docker-compose -f docker-compose.clean.yml --profile single up -d
# OR
docker-compose -f docker-compose.clean.yml --profile cluster up -d
```