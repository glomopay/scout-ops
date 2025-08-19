// API-specific alerts for API Gateway
local alertConfigs = [
  {
    title: "API Gateway High Response Time",
    labels: { severity: "warning", alert_type: "latency" },
    evaluator: { type: "gt", params: [1000] },
    annotations: {
      summary: "API Gateway response time is high",
      description: "API Gateway average response time has been above 1000ms for more than 2 minutes.",
      runbook_url: "https://runbooks.example.com/api-gw-latency"
    },
    "for": "2m",
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['http.route'] AS route,
        avg(Value) AS response_time_ms
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'http.server.duration'
        AND ResourceAttributes['service.name'] = 'api-gateway'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, route
    |||,
    folderUid: 'stage-platform'
  },
  {
    title: "API Gateway High Error Rate",
    labels: { severity: "critical", alert_type: "availability" },
    evaluator: { type: "gt", params: [5] },
    annotations: {
      summary: "API Gateway error rate is high",
      description: "API Gateway is experiencing more than 5% error rate.",
      runbook_url: "https://runbooks.example.com/api-gw-errors"
    },
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['http.route'] AS route,
        (countIf(ResourceAttributes['http.status_code'] >= 400) / count()) * 100 AS error_rate_percentage
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'http.server.duration'
        AND ResourceAttributes['service.name'] = 'api-gateway'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, route
    |||,
    folderUid: 'stage-platform'
  },
  {
    title: "API Gateway Rate Limit Exceeded",
    labels: { severity: "warning", alert_type: "throttling" },
    evaluator: { type: "gt", params: [10] },
    annotations: {
      summary: "API Gateway rate limits are being exceeded",
      description: "Multiple clients are hitting API Gateway rate limits.",
    },
    query: |||
      SELECT
        $timeSeries AS t,
        count() AS rate_limit_hits
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'http.server.duration'
        AND ResourceAttributes['http.status_code'] = '429'
        AND ResourceAttributes['service.name'] = 'api-gateway'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t
    |||,
    folderUid: 'stage-platform'
  }
];

{
  alertConfigs: alertConfigs
}