// Configuration for API Gateway alerts in stage environment
// Only specify what differs from defaults
local alertConfigs = [
  {
    title: "API Gateway High CPU - Stage",
    labels: { severity: "warning" },
    evaluator: { type: "gt", params: [80] },
    annotations: {
      summary: "API Gateway CPU usage is high in stage environment",
      description: "API Gateway CPU usage has been above 80% for more than 5 minutes in stage environment.",
    },
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
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY
        t, service
      ORDER BY t
    |||,
    folderUid: 'stage-monitoring'
  },
  {
    title: "API Gateway Memory Usage - Stage",
    labels: { severity: "warning" },
    query: "SELECT $timeSeries AS t, avg(memory_usage) FROM metrics WHERE service='api-gw' AND environment='stage'",
    folderUid: 'stage-monitoring'
  }
];

// Export the configuration for main.jsonnet to import
{
  alertConfigs: alertConfigs
}