// Terraform-style numbered file: 01-alerts.jsonnet
// This file will be automatically discovered just like Terraform .tf files

local alertConfigs = [
  {
    title: "API Gateway Service Down",
    labels: { severity: "critical", alert_type: "availability" },
    evaluator: { type: "lt", params: [1] },
    annotations: {
      summary: "API Gateway service is down",
      description: "No healthy API Gateway instances detected.",
      runbook_url: "https://runbooks.example.com/api-gw-down"
    },
    "for": "1m",
    query: |||
      SELECT
        $timeSeries AS t,
        count() AS healthy_instances
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'up'
        AND ResourceAttributes['service.name'] = 'api-gateway'
        AND ResourceAttributes['environment'] = 'stage'
        AND Value = 1
      GROUP BY t
    |||,
    folderUid: 'stage-platform'
  }
];

// Export in the standard format
{
  alertConfigs: alertConfigs
}