#!/bin/bash
set -e

echo "=== Grafana Setup Script ==="
echo ""

# Wait for harper to be ready
echo "1. Waiting for harper to be ready..."
until curl -s http://172.20.0.30:9925 > /dev/null 2>&1; do
  sleep 2
done
echo "   ✓ harper is ready"
echo ""

# Wait for analytics to be collected (first minute)
# echo "2. Waiting 60 seconds for harper analytics aggregation..."
# sleep 60
# echo "   ✓ Analytics should be available"
# echo ""

# Delete and Recreate Harper Data Source
echo "3. Deleting existing Harper datasource if it exists..."
curl -s -X DELETE "http://172.20.0.20:3000/api/datasources/uid/harper" \
  -u "admin:HarperRocks!" \
  -H "Content-Type: application/json" 2>/dev/null || true

echo ""
echo "4. Creating harper datasource via API..."
RESPONSE=$(curl -s -X POST "http://172.20.0.20:3000/api/datasources" \
  -u "admin:HarperRocks!" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Harper",
    "type": "harperfast-harper-datasource",
    "uid": "harper",
    "url": "http://172.20.0.30:9925",
    "access": "proxy",
    "isDefault": true,
    "jsonData": {
      "opsAPIURL": "http://172.20.0.30:9925",
      "url": "http://172.20.0.30:9925",
      "username": "admin"
    },
    "secureJsonData": {
      "password": "HarperRocks!"
    }
  }')

echo "$RESPONSE"
echo ""
echo "✅ Datasource configured!"

# Create the Dashboard
echo "5. Creating harper monitoring dashboard..."

curl -s -X POST "http://172.20.0.20:3000/api/dashboards/db" \
  -u "admin:HarperRocks!" \
  -H "Content-Type: application/json" \
  -d '{
  "dashboard": {
    "title": "Harper System Monitoring",
    "uid": "harper-monitoring",
    "tags": ["harper", "monitoring", "performance"],
    "timezone": "browser",
    "schemaVersion": 39,
    "refresh": "5s",
    "time": {"from": "now-5m", "to": "now"},
    "panels": [
      {
        "id": 1, "type": "gauge", "title": "CPU Utilization",
        "gridPos": {"h": 5, "w": 4, "x": 0, "y": 0},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "resource-usage",
            "attributes": ["node", "metric", "id", "cpuUtilization"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {
          "defaults": {
            "unit": "percentunit", "min": 0, "max": 1,
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 0.7},
                {"color": "red", "value": 0.9}
              ]
            }
          }
        },
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ],
        "options": {
          "reduceOptions": {"values": false, "calcs": ["lastNotNull"], "fields": ""},
          "orientation": "auto", "showThresholdLabels": false, "showThresholdMarkers": true
        }
      },
      {
        "id": 2, "type": "gauge", "title": "Thread Utilization",
        "gridPos": {"h": 5, "w": 4, "x": 4, "y": 0},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "utilization",
            "attributes": ["node", "metric", "id", "utilization"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {
          "defaults": {
            "unit": "percentunit", "min": 0, "max": 1,
            "thresholds": {
              "mode": "absolute",
              "steps": [
                {"color": "green", "value": null},
                {"color": "yellow", "value": 0.75},
                {"color": "red", "value": 0.9}
              ]
            }
          }
        },
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ],
        "options": {
          "reduceOptions": {"values": false, "calcs": ["lastNotNull"], "fields": ""},
          "orientation": "auto", "showThresholdLabels": false, "showThresholdMarkers": true
        }
      },
      {
        "id": 3, "type": "timeseries", "title": "CPU Utilization",
        "gridPos": {"h": 5, "w": 8, "x": 8, "y": 0},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "resource-usage",
            "attributes": ["node", "metric", "id", "cpuUtilization"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "percentunit"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 4, "type": "timeseries", "title": "User CPU Time",
        "gridPos": {"h": 5, "w": 8, "x": 16, "y": 0},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "resource-usage",
            "attributes": ["node", "metric", "id", "userCPUTime"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "µs"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 5, "type": "timeseries", "title": "System CPU Time",
        "gridPos": {"h": 5, "w": 8, "x": 0, "y": 5},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "resource-usage",
            "attributes": ["node", "metric", "id", "systemCPUTime"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "µs"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 6, "type": "timeseries", "title": "Memory RSS",
        "gridPos": {"h": 5, "w": 8, "x": 8, "y": 5},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "main-thread-utilization",
            "attributes": ["node", "metric", "id", "rss"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "bytes"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 7, "type": "timeseries", "title": "Heap Total",
        "gridPos": {"h": 5, "w": 8, "x": 16, "y": 5},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "main-thread-utilization",
            "attributes": ["node", "metric", "id", "heapTotal"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "bytes"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 8, "type": "timeseries", "title": "Heap Used",
        "gridPos": {"h": 5, "w": 8, "x": 0, "y": 10},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "main-thread-utilization",
            "attributes": ["node", "metric", "id", "heapUsed"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "bytes"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 9, "type": "timeseries", "title": "External Memory",
        "gridPos": {"h": 5, "w": 8, "x": 8, "y": 10},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "main-thread-utilization",
            "attributes": ["node", "metric", "id", "external"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "bytes"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 10, "type": "timeseries", "title": "Array Buffers",
        "gridPos": {"h": 5, "w": 8, "x": 16, "y": 10},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "main-thread-utilization",
            "attributes": ["node", "metric", "id", "arrayBuffers"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "bytes"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 11, "type": "timeseries", "title": "Main Thread Idle",
        "gridPos": {"h": 5, "w": 8, "x": 0, "y": 15},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "main-thread-utilization",
            "attributes": ["node", "metric", "id", "idle"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "percentunit"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 12, "type": "timeseries", "title": "Main Thread Active",
        "gridPos": {"h": 5, "w": 8, "x": 8, "y": 15},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "main-thread-utilization",
            "attributes": ["node", "metric", "id", "active"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "percentunit"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 13, "type": "timeseries", "title": "Task Queue Latency",
        "gridPos": {"h": 5, "w": 8, "x": 16, "y": 15},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "main-thread-utilization",
            "attributes": ["node", "metric", "id", "taskQueueLatency"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "ms"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 14, "type": "timeseries", "title": "Storage Volume Available",
        "gridPos": {"h": 5, "w": 8, "x": 0, "y": 20},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "storage-volume",
            "attributes": ["node", "metric", "id", "available"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "bytes"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 15, "type": "timeseries", "title": "Storage Volume Free",
        "gridPos": {"h": 5, "w": 8, "x": 8, "y": 20},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "storage-volume",
            "attributes": ["node", "metric", "id", "free"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "bytes"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      },
      {
        "id": 16, "type": "timeseries", "title": "Storage Volume Size",
        "gridPos": {"h": 5, "w": 8, "x": 16, "y": 20},
        "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
        "targets": [{
          "refId": "A",
          "datasource": {"type": "harperfast-harper-datasource", "uid": "harper"},
          "operation": "get_analytics",
          "queryAttrs": {
            "metric": "storage-volume",
            "attributes": ["node", "metric", "id", "size"],
            "from": "${__from}",
            "to": "${__to}",
            "order": "asc"
          }
        }],
        "fieldConfig": {"defaults": {"unit": "bytes"}},
        "transformations": [
          {
            "id": "labelsToFields",
            "options": {
              "valueLabel": "node"
            }
          }
        ]
      }
    ]
  },
  "overwrite": true
}'

echo ""
echo "✅ Dashboard created!"
echo "🌐 Access at: http://localhost:3000/d/harper-monitoring"

echo "=== Setup Complete! ==="
echo ""
echo "📊 Dashboard: http://localhost:3000/d/harper-monitoring"
echo "🔐 Login: admin / HarperRocks! (or use anonymous access)"
echo ""
