// Redis cache alerts for Platform team
local alertConfigs = [
  {
    title: "Redis Memory Usage High",
    labels: { severity: "warning", alert_type: "cache" },
    evaluator: { type: "gt", params: [85] },
    annotations: {
      summary: "Redis memory usage is high",
      description: "Redis is using more than 85% of available memory.",
      runbook_url: "https://runbooks.example.com/redis-memory"
    },
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['redis.instance'] AS instance,
        (Value / ResourceAttributes['redis.maxmemory']) * 100 AS memory_percentage
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'redis.memory.used'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, instance
    |||,
    folderUid: 'stage-platform'
  },
  {
    title: "Redis High Connection Count",
    labels: { severity: "critical", alert_type: "connections" },
    evaluator: { type: "gt", params: [500] },
    annotations: {
      summary: "Redis has too many connections",
      description: "Redis connection count is approaching the maximum limit.",
    },
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['redis.instance'] AS instance,
        Value AS connection_count
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'redis.clients.connected'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, instance
    |||,
    folderUid: 'stage-platform'
  },
  {
    title: "Redis Cache Hit Rate Low",
    labels: { severity: "warning", alert_type: "performance" },
    evaluator: { type: "lt", params: [80] },
    annotations: {
      summary: "Redis cache hit rate is low",
      description: "Redis cache hit rate has dropped below 80%.",
    },
    query: |||
      SELECT
        $timeSeries AS t,
        ResourceAttributes['redis.instance'] AS instance,
        (countIf(MetricName = 'redis.keyspace.hits') / 
         (countIf(MetricName = 'redis.keyspace.hits') + countIf(MetricName = 'redis.keyspace.misses'))) * 100 AS hit_rate_percentage
      FROM stable
      WHERE $timeFilter
        AND MetricName IN ('redis.keyspace.hits', 'redis.keyspace.misses')
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t, instance
    |||,
    folderUid: 'stage-platform'
  }
];

{
  alertConfigs: alertConfigs
}