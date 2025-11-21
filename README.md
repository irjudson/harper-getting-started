# Harper Tools

A batteries-included developer toolbox for working with Harper. This repository provides everything you need to quickly spin up Harper instances with monitoring, whether for development, testing, or evaluation purposes.

## 🚀 Quick Start

Get Harper running with monitoring in under a minute:

```bash
# Clone the repository
git clone https://github.com/yourusername/harper-tools.git
cd harper-tools

# Start Harper with Grafana monitoring
cd docker
docker-compose up -d

# Access the services
# Harper: http://localhost:9925 (admin/HarperRocks!)
# Grafana: http://localhost:3000 (admin/admin)
```

## 🎁 What's Included

### Docker Environment (`/docker`)
Complete Docker Compose setup with multiple deployment options:
- **Single Node Mode** - Perfect for development and testing
- **3-Node Cluster Mode** - Test replication and clustering features
- **Pre-configured Grafana** - Monitoring dashboards auto-provisioned
- **Automatic Setup** - Grafana datasources and dashboards configured automatically

### Key Features
- **Zero Configuration** - Everything works out of the box
- **Consistent Naming** - Seamlessly switch between single and cluster modes
- **Health Checks** - All services include proper health monitoring
- **Graceful Shutdown** - Proper stop procedures for data safety
- **Persistent Data** - Data volumes preserved between restarts

## 📁 Project Structure

```
harper-tools/
├── docker/                    # Docker-based Harper environment
│   ├── docker-compose.yml     # Main orchestration file
│   ├── scripts/               # Setup and utility scripts
│   ├── data/                  # Persistent data volumes (auto-created)
│   └── docs/                  # Detailed docker documentation
└── docs/                      # General project documentation
```

## 🛠 Available Configurations

### Single Node Deployment
Perfect for:
- Local development
- API testing
- Learning Harper
- Quick prototypes

```bash
cd docker
docker-compose --profile single up -d
```

### 3-Node Cluster Deployment
Perfect for:
- Testing replication
- High availability scenarios
- Performance testing
- Production-like environments

```bash
cd docker
docker-compose --profile cluster up -d
```

## 📊 Monitoring & Observability

Grafana comes pre-configured with Harper monitoring dashboards:
- Real-time metrics visualization
- Query performance monitoring
- Resource utilization tracking
- Cluster health overview (in cluster mode)

Access Grafana at http://localhost:3000 and navigate to the Harper dashboard.

## 🔧 Requirements

- Docker & Docker Compose (v2.0+)
- 4GB RAM minimum (8GB recommended for cluster mode)
- Available ports:
  - 3000 (Grafana)
  - 9925-9927 (Harper Operations API)
  - 9926-9946 (Harper Application API)

## 📚 Documentation

- [Docker Setup Guide](docker/README.md) - Detailed Docker environment documentation
- [Usage Guide](docker/USAGE_GUIDE.md) - How to use the Docker setup
- [Data Format Analysis](docker/docs/DATA-FORMAT-ANALYSIS.md) - Understanding Harper data formats

## 🎯 Use Cases

This toolbox is designed for:

- **Developers** - Quick local development environment with monitoring
- **DevOps Engineers** - Test deployment configurations and clustering
- **Solution Architects** - Evaluate Harper capabilities
- **QA Engineers** - Consistent test environments
- **Learning** - Explore Harper features with a complete setup

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Add new deployment configurations
- Improve monitoring dashboards
- Add utility scripts
- Enhance documentation

## 📝 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources

- [Harper Documentation](https://docs.harperdb.io)
- [Harper Docker Hub](https://hub.docker.com/r/harperdb/harperdb)
- [Grafana Documentation](https://grafana.com/docs)

---

Built with ❤️ for the Harper developer community