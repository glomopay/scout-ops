// DevOps team web-server alerts for stage environment
local alertConfigs = [
  {
    title: "Web Server High Response Time - Stage",
    labels: { severity: "warning", team: "devops" },
    evaluator: { type: "gt", params: [500] },
    annotations: {
      summary: "Web server response time is high in stage environment",
      description: "Web server average response time has been above 500ms for more than 5 minutes.",
      runbook_url: "https://example.com/runbooks/web-server-latency",
    },
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['service.name'] AS service,
        avg(Value) AS response_time_ms
      FROM
        stable
      WHERE
        $timeFilter
        AND MetricName = 'http.server.duration'
        AND ResourceAttributes['service.name'] = 'web-server'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY
        t, service
      ORDER BY t
    |||,
    folderUid: 'stage-devops'
  },
  {
    title: "Web Server High Error Rate - Stage",
    labels: { severity: "warning", team: "devops" },
    evaluator: { type: "gt", params: [5] },
    annotations: {
      summary: "Web server error rate is elevated",
      description: "Web server is experiencing elevated error rates in stage environment.",
    },
    query: "SELECT $timeSeries AS t, count(*) FROM http_requests WHERE status >= 400 AND service = 'web-server' AND environment = 'stage'",
    folderUid: 'stage-devops'
  }
];

// Export the configuration for main.jsonnet to import
{
  alertConfigs: alertConfigs
}