local alertGroups = [
{
  name: 'per1MinuteEval',
  interval: 60,
  folderUid: 'cf2ok0qyq5ipsd',
  alertRules: [
  {
    title: "High CPU Utilization",
    labels: { severity: "critical" },
    evaluator: { type: "gt", params: [85] },
    annotations: {
      summary: "High CPU Utilization",
      description: "CPU Utilization has been above 85% for more than 5 minutes."
    },
    relativeTimeRange: { from: 600, to: 0 },
    dateTimeColDataType: "TimeUnix",
    dateTimeType: "DATETIME64",
    format: "time_series",
    table: "otel_metrics_gauge",
    pendingPeriod: "5m",
    query: |||
      SELECT toStartOfMinute(toDateTime(TimeUnix, 'Asia/Kolkata')) as t,  max(Value) * 100 as Value, ResourceAttributes['host.name'] as hostname FROM $table WHERE $timeFilter
      AND ServiceName = 'hostmetrics' 
      AND MetricName = 'system.cpu.utilization' 
      AND Attributes['state'] != 'idle'
      AND ResourceAttributes['deployment.environment'] = 'staging-sandbox'
      GROUP BY t, hostname 
    |||
  },

]
}
];

{
  alertGroups: alertGroups
}