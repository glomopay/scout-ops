// Database-specific alerts for Platform team
local alertConfigs = [
  {
    title: "Database High Connection Count",
    labels: { severity: "warning", alert_type: "database" },
    evaluator: { type: "gt", params: [80] },
    annotations: {
      summary: "Database connection count is high",
      description: "Database has more than 80 active connections.",
      runbook_url: "https://runbooks.example.com/db-connections"
    },
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['db.name'] AS database,
        count() AS active_connections
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'db.client.connections.usage'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, database
    |||,
    folderUid: 'stage-platform'
  },
  {
    title: "Database Slow Query Detection",
    labels: { severity: "critical", alert_type: "performance" },
    evaluator: { type: "gt", params: [5000] },
    annotations: {
      summary: "Database slow queries detected",
      description: "Database queries taking longer than 5 seconds detected.",
    },
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['db.operation'] AS operation,
        avg(Value) AS avg_duration_ms
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'db.client.operation.duration'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, operation
    |||,
    folderUid: 'stage-platform'
  }
];

{
  alertConfigs: alertConfigs
}