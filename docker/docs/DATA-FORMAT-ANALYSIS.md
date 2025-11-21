# Data Format Analysis - HarperDB to Grafana

## Current Situation

### What HarperDB Returns:
```json
[
  {"node": "harper-0", "time": 1763577333205, "cpuUtilization": 0.07},
  {"node": "harper-1", "time": 1763577398816, "cpuUtilization": 0.08},
  {"node": "harper-0", "time": 1763577483204, "cpuUtilization": 0.02},
  ...
]
```

**Key characteristics:**
- **Long format**: All nodes mixed in single array
- **Asynchronous timestamps**: Each node reports at different times
- **Flat structure**: No grouping by node
- **Field names**: `node` is a data field, not a label/tag

### What Grafana Timeseries Expects:

**Option 1 - Multiple Series (Preferred):**
```json
{
  "harper-0": [
    {"time": 1763577333205, "value": 0.07},
    {"time": 1763577483204, "value": 0.02}
  ],
  "harper-1": [
    {"time": 1763577398816, "value": 0.08},
    {"time": 1763577548809, "value": 0.02}
  ],
  "harper-2": [
    {"time": 1763578053964, "value": 0.09},
    {"time": 1763578201447, "value": 0.07}
  ]
}
```

**Option 2 - Wide Format (Time-aligned):**
```json
[
  {"time": 1763577333000, "harper-0": 0.07, "harper-1": null, "harper-2": null},
  {"time": 1763577398000, "harper-0": null, "harper-1": 0.08, "harper-2": null}
]
```

**Option 3 - Tagged/Label Format (Prometheus-style):**
```json
[
  {"time": 1763577333205, "value": 0.07, "__labels": {"node": "harper-0"}},
  {"time": 1763577398816, "value": 0.08, "__labels": {"node": "harper-1"}}
]
```

## The Gap

### Primary Issues:
1. **No Series Separation**: HarperDB returns all nodes in one flat array
2. **No Label System**: The `node` field is treated as data, not as a series identifier
3. **Async Timestamps**: Each node has different timestamps (not aligned)
4. **Field Naming**: Grafana expects the metric in a field called `value` or named by series

### Why Current Transformations Fail:
- `partitionByValues` expects the datasource to already support series concept
- `groupBy` aggregates data instead of creating separate series
- `organize` just renames/reorders fields, doesn't restructure data
- The HarperDB datasource plugin doesn't recognize `node` as a grouping field

## Solution Options

### Option 1: Fix in Datasource Plugin (Best but Complex)
- Modify the HarperDB Grafana datasource to recognize `node` as a series field
- Would require forking and updating the plugin code

### Option 2: Custom Transform Plugin (Good)
- Create a custom Grafana transformation that splits data by node
- Would be reusable for all panels

### Option 3: Query Restructuring (Workaround)
- Use multiple queries (one per node) with filtering
- Each query becomes a separate series
- Dashboard becomes more complex but works with existing tools

### Option 4: Preprocessing Layer (Alternative)
- Add a service between HarperDB and Grafana to transform data
- Could be a simple Node.js proxy that restructures the data

## Recommended Approach

### Immediate Fix: Multiple Queries Per Panel
Instead of one query getting all nodes, use three queries:
- Query A: Filter for node='harper-0'
- Query B: Filter for node='harper-1'
- Query C: Filter for node='harper-2'

Each query becomes a separate series that Grafana can display.

### Long-term Fix:
Fork and fix the HarperDB datasource plugin to properly handle multi-series data.

## Next Steps

1. ✅ Understand the data format mismatch (DONE)
2. 🔄 Implement multiple-query workaround
3. 📝 Document the solution
4. 🚀 Consider long-term plugin fix