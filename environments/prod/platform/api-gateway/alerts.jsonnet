// Configuration for API Gateway alerts in production environment
// Production has more aggressive thresholds and shorter timeouts
local alertConfigs = [
  {
    title: "API Gateway High CPU - Production",
    "for": "2m",
    labels: { severity: "critical" },
    evaluator: { type: "gt", params: [70] },
    annotations: {
      summary: "API Gateway CPU usage is critical in production environment",
      description: "API Gateway CPU usage has been above 70% for more than 2 minutes in production environment.",
      runbook_url: "https://example.com/runbooks/api-gw-cpu",
    },
    interval: 30,
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['service.name'] AS service,
        avg(Value) AS cpu_usage
      FROM
        stable
      WHERE
        $timeFilter
        AND MetricName = 'system.cpu.utilization'
        AND ResourceAttributes['service.name'] = 'api-gateway'
        AND ResourceAttributes['environment'] = 'prod'
      GROUP BY
        t, service
    |||,
    folderUid: 'prod-monitoring'
  },
  {
    title: "API Gateway 5xx Errors - Production",
    labels: { severity: "critical" },
    evaluator: { type: "gt", params: [10] },
    annotations: {
      summary: "High error rate detected in API Gateway",
      description: "API Gateway is experiencing elevated 5xx error rates in production.",
      runbook_url: "https://example.com/runbooks/api-gw-errors",
    },
    query: "SELECT $timeSeries AS t, count(*) FROM errors WHERE status >= 500 AND service = 'api-gw' AND environment = 'prod'",
    folderUid: 'prod-monitoring'
  }
];

// Export the configuration for main.jsonnet to import
{
  alertConfigs: alertConfigs
}