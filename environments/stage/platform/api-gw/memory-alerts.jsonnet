// Memory-specific alerts for API Gateway
local alertConfigs = [
  {
    title: "API Gateway High Memory Usage",
    labels: { severity: "warning", alert_type: "resource" },
    evaluator: { type: "gt", params: [85] },
    annotations: {
      summary: "API Gateway memory usage is high",
      description: "API Gateway memory usage has been above 85% for more than 3 minutes.",
      runbook_url: "https://runbooks.example.com/api-gw-memory"
    },
    "for": "3m",
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['service.name'] AS service,
        avg(Value) AS memory_percentage
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'system.memory.utilization'
        AND ResourceAttributes['service.name'] = 'api-gateway'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, service
    |||,
    folderUid: 'stage-platform'
  },
  {
    title: "API Gateway Memory Leak Detection",
    labels: { severity: "warning", alert_type: "anomaly" },
    evaluator: { type: "gt", params: [20] },
    annotations: {
      summary: "Potential memory leak in API Gateway",
      description: "API Gateway memory usage has increased by more than 20% in the last hour.",
    },
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['service.name'] AS service,
        (avg(Value) - lag(avg(Value), 60)) AS memory_growth_percentage
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'system.memory.utilization'
        AND ResourceAttributes['service.name'] = 'api-gateway'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, service
    |||,
    folderUid: 'stage-platform'
  }
];

{
  alertConfigs: alertConfigs
}