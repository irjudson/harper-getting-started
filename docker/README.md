# Harper Docker Monitoring Stack

A Docker Compose setup for running Harper with Grafana monitoring dashboards.

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
├── .env.example                 # Environment variables template
├── scripts/                     # Utility scripts
│   └── setup-grafana.sh        # Grafana dashboard setup script
├── data/                       # Transient data for Docker containers (auto-created)
│   ├── harper/                 # Harper single node data
│   ├── harper-node-0/          # Cluster node 0 data
│   ├── harper-node-1/          # Cluster node 1 data
│   ├── harper-node-2/          # Cluster node 2 data
│   └── grafana/                # Grafana data
├── docs/                       # Documentation
│   └── DATA-FORMAT-ANALYSIS.md # Harper data format documentation
├── README.md                   # This file
└── USAGE_GUIDE.md              # Detailed usage instructions
```

## Documentation

- **[Usage Guide](USAGE_GUIDE.md)** - Detailed usage instructions
- **[Data Format Analysis](docs/DATA-FORMAT-ANALYSIS.md)** - Understanding Harper data formats

## Services

### Harper
- **Single Node**: http://localhost:9925
- **Cluster Node 0**: http://localhost:9925
- **Cluster Node 1**: http://localhost:9935
- **Cluster Node 2**: http://localhost:9945
- **Credentials**: admin / HarperRocks!

### Grafana
- **URL**: http://localhost:3000
- **Credentials**: admin / admin

## Requirements

- Docker & Docker Compose
- 4GB+ RAM for cluster mode
- Available ports:
  - 3000 (Grafana)
  - 9925, 9926 (Harper single node or cluster node 0)
  - 9935, 9936 (Harper cluster node 1)
  - 9945, 9946 (Harper cluster node 2)