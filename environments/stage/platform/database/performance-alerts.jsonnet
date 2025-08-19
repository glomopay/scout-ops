// Database performance alerts for Platform team
local alertConfigs = [
  {
    title: "Database High CPU Usage",
    labels: { severity: "warning", alert_type: "resource" },
    evaluator: { type: "gt", params: [75] },
    annotations: {
      summary: "Database CPU usage is high",
      description: "Database server CPU usage has been above 75% for more than 3 minutes.",
      runbook_url: "https://runbooks.example.com/db-cpu"
    },
    "for": "3m",
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['service.name'] AS service,
        avg(Value) AS cpu_percentage
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'system.cpu.utilization'
        AND ResourceAttributes['service.name'] LIKE '%database%'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, service
    |||,
    folderUid: 'stage-platform'
  },
  {
    title: "Database Disk I/O High",
    labels: { severity: "warning", alert_type: "disk" },
    evaluator: { type: "gt", params: [1000] },
    annotations: {
      summary: "Database disk I/O is high",
      description: "Database is experiencing high disk I/O operations.",
    },
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['device'] AS device,
        sum(Value) AS disk_ops_per_sec
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'system.disk.operations'
        AND ResourceAttributes['service.name'] LIKE '%database%'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, device
    |||,
    folderUid: 'stage-platform'
  }
];

{
  alertConfigs: alertConfigs
}