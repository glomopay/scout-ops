# Grizzly Grafana Alerts Workflow

This project provides an automated way to create  Grafana alerts using Grizzly and GitHub Actions. It allows teams to define their alerting rules as code and deploy them automatically to Grafana.

## Project Structure

```
├── .github/workflows/
│   └── grizzly-alerts.yml      # GitHub Actions workflow
├── teams/                      # Team configurations and alerts
│   └── {environment}/          # Environment (stage, prod)
│       └── {team}/             # Team name (devops, platform)
│           ├── config.jsonnet  # Team-level configuration
│           └── {service}/      # Service/resource name
│               └── alerts.jsonnet  # Alert definitions
├── templates/                  # Jsonnet templates
├── lib/                        # Utility libraries
├── main.jsonnet               # Main entry point
└── Makefile                   # Build commands
```

## Getting Started

### 1. Prerequisites

- Access to a Grafana instance
- GitHub repository with Actions enabled
- Grafana service account token with alert management permissions

### 2. Setup GitHub Secrets

Configure these secrets in your GitHub repository:

- `GRAFANA_URL`: Your Grafana instance URL (e.g., `https://your-grafana.com/`)
- `GRAFANA_TOKEN`: Grafana service account token editor role

### 3. Team Configuration

Each team needs a configuration file at `teams/{environment}/{team}/config.jsonnet`:

```jsonnet
{
  folderUid: 'your-grafana-folder-uid',
  labels: {
    team: 'your-team-name',
    env: 'environment-name'
  },
  contactPoint: 'your-notification-channel'
}
```

**Required fields:**

| Field | Description |
|-------|-------------|
| `folderUid` | The Grafana folder where alerts will be created |
| `labels` | Labels applied to all team alerts |
| `contactPoint` | Notification channel for alerts |

### 4. Alert Definitions

Create alert rules at `teams/{environment}/{team}/{service}/alerts.jsonnet`:

```jsonnet
{
  alertGroups: [
    {
      name: 'MyServiceAlerts',
      interval: 300,
      alertRules: [
        {
          title: "High CPU Usage",
          labels: { severity: "warning" },
          evaluator: { type: "gt", params: [80] },
          annotations: {
            summary: "CPU usage is high",
            description: "CPU usage has been above 80% for 5 minutes"
          },
          query: "your_sql_query_here",
          relativeTimeRange: { from: 600, to: 0 },
          format: "time_series",
          table: "your_table_name"
        }
      ]
    }
  ]
}
```

**Alert Rule Fields:**

| Field | Description |
|-------|-------------|
| `title` | Alert name |
| `labels` | Alert-specific labels (merged with team labels) |
| `evaluator` | Threshold condition (`gt`, `lt`, `eq` with params) |
| `annotations` | Alert description and summary |
| `query` | Your monitoring query (ClickHouse, SQL, etc.) |
| `relativeTimeRange` | Time window for the query |
| `format` | Query result format |
| `table` | Source table name |

## Running the Workflow

### Manual Trigger (Workflow Dispatch)

1. Go to your GitHub repository
2. Navigate to **Actions** tab
3. Select **Grizzly Alert Management** workflow
4. Click **Run workflow**
5. Fill in the required parameters:

| Parameter | Options/Format | Description |
|-----------|----------------|-------------|
| **Environment** | `stage` or `prod` | Target environment |
| **Team** | Your team name | Team identifier (e.g., `devops`, `platform`) |
| **Service** | Your service name | Service identifier (e.g., `web-server`, `api-gateway`) |
| **Action** | `diff` or `apply` | Choose `diff` to preview or `apply` to deploy |

### Available Actions

| Action | Description |
|--------|-------------|
| **diff** | Preview what changes will be made (safe, read-only) |
| **apply** | Deploy the alerts to Grafana |

## Local Development

You can test your configurations locally using the Makefile:

```bash
# Generate alert resources
make generate ENVIRONMENT=stage TEAM=devops SERVICE=web-server

# Preview changes
make diff ENVIRONMENT=stage TEAM=devops SERVICE=web-server

# Apply changes (requires Grafana access)
make apply ENVIRONMENT=stage TEAM=devops SERVICE=web-server
```

## Default Configurations

The project comes with pre-configured defaults that you don't need to worry about:

| Field  |  Configuration | Default Value | Description |
|---------------|---------------|-------------|-------------|
| **Data Source** | `datasource` | `ClickHouse (vertamedia-clickhouse-datasource)` | Pre-configured datasource for queries |
| **Database** | `database` | `your-database` | Default database name |
| **Query Format** | `format` | `time_series` | Standard format for alert queries |
| **Evaluation Interval** | `interval` | `60` seconds (1 minute) | How often alerts are evaluated |
| **Pending Period** | `pendingPeriod` | `5m` | How long condition must be true before firing |
| **Time Range** | `relativeTimeRange` | `{ from: 300, to: 0 }` | Default 5-minute |
| **No Data State** | `noDataState` | `Ignore` | Alert state when no data is available |
| **Execution Error State** | `execErrState` | `Alerting` | Alert state when query execution fails |
| **Default Reducer** | `reducerType` | `last` | Default data reduction method for queries |
| **DateTime Column** | `dateTimeColDataType` | `TimeUnix` | Default timestamp column format |
| **DateTime Type** | `dateTimeType` | `DATETIME64` | ClickHouse datetime type |

These defaults ensure consistency across all teams and reduce setup complexity.
You can override any of these defaults in your `alerts.jsonnet` file by specifying the corresponding field:



## Best Practices

- Always run `diff` first to preview changes before applying
- Use descriptive alert titles and annotations
- Set appropriate severity labels for your alerts
- Test your queries in Grafana before adding them to the config
- Keep team configurations consistent across environments
