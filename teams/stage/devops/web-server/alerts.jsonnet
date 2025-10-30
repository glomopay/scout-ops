
// DevOps team web-server alerts for stage environment
local alertGroups = [
{
  name: 'per5MinuteEval',
  interval: 300,
  folderUid: 'beu35l1zpl7uoa',
  alertRules: [
  {
    title: "Web Server High Response Time - Stage",
    labels: { severity: "warning", team: "devops" },
    evaluator: { type: "gt", params: [500] },
    annotations: {
      summary: "Web server response time is high in stage environment",
      description: "Web server average response time has been above 500ms for more than 5 minutes.",
      runbook_url: "https://example.com/runbooks/web-server-latency",
    },
    relativeTimeRange: { from: 600, to: 0 },
    dateTimeColDataType: "TimeUnix",
    dateTimeType: "DATETIME64",
    format: "time_series",
    table: "otel_metrics_gauge",
 
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['service.name'] AS service,
        avg(Value) AS response_time_ms
      FROM
        $table
      WHERE
        $timeFilter
        AND MetricName = 'http.server.duration'
        AND ResourceAttributes['service.name'] = 'web-server'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY
        t, service
      ORDER BY t
    |||,
  },
]
}
];

{
  alertGroups: alertGroups
}