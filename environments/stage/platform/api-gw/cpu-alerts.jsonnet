// CPU-specific alerts for API Gateway
local alertConfigs = [
  {
    title: "API Gateway High CPU Usage",
    labels: { severity: "warning", alert_type: "performance" },
    evaluator: { type: "gt", params: [80] },
    annotations: {
      summary: "API Gateway CPU usage is high",
      description: "API Gateway CPU usage has been above 80% for more than 5 minutes.",
      runbook_url: "https://runbooks.example.com/api-gw-cpu",
      dashboard_url: "https://grafana.example.com/d/api-gw-cpu"
    },
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['service.name'] AS service,
        avg(Value) AS cpu_percentage
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'system.cpu.utilization'
        AND ResourceAttributes['service.name'] = 'api-gateway'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, service
    |||,
    folderUid: 'stage-platform'
  },
  {
    title: "API Gateway Critical CPU Usage",
    labels: { severity: "critical", alert_type: "performance" },
    evaluator: { type: "gt", params: [95] },
    annotations: {
      summary: "API Gateway CPU usage is critical",
      description: "API Gateway CPU usage has exceeded 95%. Immediate action required.",
      runbook_url: "https://runbooks.example.com/api-gw-cpu-critical"
    },
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['service.name'] AS service,
        avg(Value) AS cpu_percentage
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'system.cpu.utilization'
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