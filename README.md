# Harper Tools

**What it is:** Batteries-included developer toolbox for Harper.

**Why it matters:** Get Harper running with monitoring in under a minute.

**The bottom line:** Everything works out of the box.

**Why it matters:** Get Harper running with monitoring in under a minute.

**The bottom line:** Everything works out of the box ✅

## 🚀 Quick Start

```bash
git clone https://github.com/yourusername/harper-tools.git
cd harper-tools/docker
docker-compose up -d
```

**Harper:** http://localhost:9925 (admin/HarperRocks!)
**Grafana:** http://localhost:3000 (admin/HarperRocks!) 📊

## What's Included

**Docker environment** with two modes:
- **Single node** - Development and testing
- **3-node cluster** - Replication and HA testing

**Key features:**
- Zero configuration
- Auto-provisioned monitoring
- Persistent data volumes
- Health checks included

## Requirements

- Docker & Docker Compose 2.0+
- 4GB RAM (8GB for cluster)
- Ports: 3000, 9925-9946

## Deployment Options

### Single Node
```bash
docker-compose --profile single up -d
```
Best for: Development, API testing, learning

### Cluster (3 nodes)
```bash
docker-compose --profile cluster up -d
```
Best for: Replication testing, HA scenarios, performance testing

## Documentation

- [Docker Setup](docker/README.md)
- [Usage Guide](docker/USAGE_GUIDE.md)
- [Data Formats](docker/docs/DATA-FORMAT-ANALYSIS.md)

## Use Cases

- **Developers** - Local development with monitoring
- **DevOps** - Test deployments and clustering
- **Architects** - Evaluate Harper capabilities
- **QA** - Consistent test environments
- **Learning** - Explore Harper features

## Contributing

Contributions welcome:
- New deployment configurations
- Monitoring improvements
- Utility scripts
- Documentation

## License

Apache 2.0 - See [LICENSE](LICENSE)

## Resources

- [Harper Docs](https://docs.harperdb.io)
- [Docker Hub](https://hub.docker.com/r/harperdb/harperdb)
- [Grafana](https://grafana.com/docs)
