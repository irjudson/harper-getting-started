# HarperDB Docker Monitoring Stack

A Docker Compose setup for running HarperDB with Grafana monitoring dashboards.

## Quick Start

### Single Node
```bash
docker-compose --profile single up -d
```

### 3-Node Cluster
```bash
docker-compose --profile cluster up -d
```

### Access Grafana
- **URL**: http://localhost:3000
- **Login**: admin / admin
- **Dashboard**: http://localhost:3000/d/harperdb-monitoring

## Project Structure

```
.
├── docker-compose.yml           # Main orchestration file
├── grafana/                     # Grafana configuration
│   └── provisioning/
│       ├── dashboards/         # Dashboard JSON files
│       └── datasources/        # Datasource configurations
├── harperdb/                   # HarperDB configuration
│   └── config.yaml             # HarperDB settings
├── docs/                       # Documentation
│   ├── README.md               # Detailed documentation
│   ├── SCRIPTS_GUIDE.md        # Scripts reference
│   └── TROUBLESHOOTING.md      # Common issues & solutions
└── scripts/                    # Utility scripts
    ├── setup/                  # Initial setup scripts
    ├── testing/                # Test and debug scripts
    ├── queries/                # HarperDB query utilities
    └── fixes/                  # Dashboard fix utilities
```

## Documentation

- **[Full Documentation](docs/README.md)** - Complete project documentation
- **[Scripts Guide](docs/SCRIPTS_GUIDE.md)** - How to use utility scripts
- **[Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and fixes

## Current Status

⚠️ **Known Issue**: Multi-node display showing "missing time field" errors with Infinity datasource. See [Troubleshooting](docs/TROUBLESHOOTING.md) for workarounds.

## Services

### HarperDB
- **Single Node**: http://localhost:9925
- **Cluster Node 0**: http://localhost:9925
- **Cluster Node 1**: http://localhost:9926
- **Cluster Node 2**: http://localhost:9927
- **Credentials**: admin / HarperRocks!

### Grafana
- **URL**: http://localhost:3000
- **Credentials**: admin / admin

## Requirements

- Docker & Docker Compose
- 4GB+ RAM for cluster mode
- Ports 3000, 9925-9927 available