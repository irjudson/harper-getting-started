# HarperDB Docker Compose Setup - Design Document

**Date:** 2025-11-18
**Status:** Approved
**Author:** Design session with user

## Overview

A flexible Docker Compose setup for running HarperDB locally with full observability. Supports both single-node and 3-node cluster configurations using Docker Compose profiles.

## Architecture

### Profiles

**Default Profile (no flag needed)**
- Single HarperDB instance on ports 9925 (Operations API) and 9926 (HTTP)
- Grafana on port 3000 for visualization
- Prometheus on port 9090 for metrics collection
- Full observability for single-node development

**Cluster Profile (`--profile cluster`)**
- 3 HarperDB nodes with clustering enabled
- Private Docker network (`harperdb-net`) for inter-node communication
- External access via different host ports:
  - node1: 9925/9926
  - node2: 9935/9936
  - node3: 9945/9946
- Each node uses default ports (9925/9926) internally
- Same Grafana and Prometheus, configured to monitor all 3 nodes

### Usage Commands

```bash
cd docker
docker-compose up                    # single node + observability
docker-compose --profile cluster up   # 3 nodes + observability
```

## Network Configuration

**Docker Network:** `harperdb-net`
- Custom bridge network for all services
- Provides DNS resolution (services find each other by name)
- Isolated from other Docker containers
- Each container gets its own IP

## Service Configuration

### HarperDB Single Node

- **Service name:** `harperdb`
- **Image:** `harperdb/harperdb:latest`
- **Ports:** `9925:9925`, `9926:9926`
- **Volume:** `./data/harperdb:/home/harperdb/hdb`
- **Environment:**
  - `HDB_ADMIN_USERNAME` (default: admin)
  - `HDB_ADMIN_PASSWORD` (default: HarperRocks!)
  - `OPERATIONSAPI_NETWORK_PORT=9925`
  - `HTTP_PORT=9926`

### HarperDB Cluster Nodes

- **Services:** `harperdb-node1`, `harperdb-node2`, `harperdb-node3`
- **Profile:** `cluster`
- **Image:** `harperdb/harperdb:latest`
- **Ports:**
  - node1: `9925:9925`, `9926:9926`
  - node2: `9935:9925`, `9936:9926`
  - node3: `9945:9925`, `9946:9926`
- **Volumes:** `./data/harperdb-node[1-3]:/home/harperdb/hdb`
- **Environment:** (in addition to single node vars)
  - `CLUSTERING_ENABLED=true`
  - `CLUSTERING_USER` (default: admin)
  - `CLUSTERING_PASSWORD` (default: HarperRocks!)
  - `CLUSTERING_NODENAME=node[1-3]`

### Prometheus

- **Image:** `prom/prometheus:latest`
- **Port:** `9090:9090`
- **Volumes:**
  - `./config/prometheus.yml:/etc/prometheus/prometheus.yml:ro`
  - `./data/prometheus:/prometheus`
- **Configuration:**
  - Scrape interval: 15 seconds
  - Single mode: scrapes `harperdb:9925`
  - Cluster mode: scrapes all 3 nodes at `:9925`

### Grafana

- **Image:** `grafana/grafana:latest`
- **Port:** `3000:3000`
- **Volumes:**
  - `./data/grafana:/var/lib/grafana`
  - `./config/grafana/provisioning:/etc/grafana/provisioning:ro`
- **Environment:**
  - `GF_SECURITY_ADMIN_USER` (default: admin)
  - `GF_SECURITY_ADMIN_PASSWORD` (default: admin)
- **Provisioning:**
  - Prometheus datasource auto-configured
  - Dashboard provider configured

## Configuration Management

### Environment Variables (.env)

```env
# HarperDB Configuration
HDB_ADMIN_USERNAME=admin
HDB_ADMIN_PASSWORD=HarperRocks!

# Cluster Configuration
CLUSTERING_USER=admin
CLUSTERING_PASSWORD=HarperRocks!

# Grafana Configuration
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin
```

All variables have defaults in `docker-compose.yml` using `${VAR:-default}` syntax.

### Directory Structure

```
harper-getting-started/
├── docs/
│   └── plans/
│       └── 2025-11-18-harperdb-docker-compose-design.md
└── docker/
    ├── docker-compose.yml
    ├── .env
    ├── .env.example          # Template (committed to git)
    ├── .gitignore            # Ignore .env and data/
    ├── README.md             # User documentation
    ├── init.sh               # Optional: creates directories
    ├── config/
    │   ├── prometheus.yml
    │   └── grafana/
    │       └── provisioning/
    │           ├── datasources/
    │           │   └── prometheus.yml
    │           └── dashboards/
    │               └── default.yml
    └── data/                 # Git-ignored, created on first run
        ├── harperdb/
        ├── harperdb-node1/
        ├── harperdb-node2/
        ├── harperdb-node3/
        ├── grafana/
        └── prometheus/
```

## Health Checks and Dependencies

### HarperDB Health Check

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:9925"]
  interval: 10s
  timeout: 5s
  retries: 5
  start_period: 30s
```

### Service Dependencies

- Prometheus depends on HarperDB services being healthy
- Grafana depends on Prometheus being healthy
- Cluster nodes start independently (clustering handles discovery)

### Startup Order

- **Single mode:** `harperdb` → `prometheus` → `grafana`
- **Cluster mode:** `harperdb-node[1-3]` (parallel) → `prometheus` → `grafana`

### Lifecycle Settings

- **Restart policy:** `unless-stopped` (survives reboots)
- **Stop grace period:** 30s (allows clean shutdown)

## Testing and Verification

### Single Mode Tests

1. Start: `docker-compose up -d`
2. Verify HarperDB: `curl http://localhost:9925`
3. Verify Grafana: Open `http://localhost:3000`
4. Verify Prometheus: Check `http://localhost:9090/targets`

### Cluster Mode Tests

1. Start: `docker-compose --profile cluster up -d`
2. Verify all nodes:
   - `curl http://localhost:9925` (node1)
   - `curl http://localhost:9935` (node2)
   - `curl http://localhost:9945` (node3)
3. Check clustering status via API
4. Verify Prometheus scraping all 3 targets

### Data Persistence Test

1. Create table/data in HarperDB
2. Stop containers: `docker-compose down`
3. Restart containers
4. Verify data persists

## Documentation Deliverables

### README.md

Will include:
- Quick start guide
- Profile usage examples
- Service access URLs
- Default credentials
- Customization via `.env`
- Troubleshooting tips
- Data backup/restore guidance

### Additional Files

- `.gitignore` - excludes `.env` and `data/`
- `.env.example` - documented template
- `init.sh` - optional directory creation helper

## Implementation Notes

- Use TDD approach with verification at each step
- Test both profiles independently
- Verify data persistence across restarts
- Confirm Prometheus scraping works in both modes
- Ensure Grafana can visualize data from all nodes
