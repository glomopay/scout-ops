// Natural naming: monitoring.jsonnet  
// Just like Terraform, you can name your files whatever makes sense
// The system will find and process this file automatically

local alertConfigs = [
  {
    title: "API Gateway Request Rate Anomaly", 
    labels: { severity: "warning", alert_type: "anomaly" },
    evaluator: { type: "gt", params: [200] },
    annotations: {
      summary: "Unusual request rate pattern detected",
      description: "API Gateway request rate is significantly different from normal patterns.",
    },
    query: |||
      SELECT
        $timeSeries AS t,
        count() AS request_rate
      FROM stable
      WHERE $timeFilter
        AND MetricName = 'http.server.requests'
        AND ResourceAttributes['service.name'] = 'api-gateway'
        AND ResourceAttributes['environment'] = 'stage'
      GROUP BY t
    |||,
    folderUid: 'stage-platform'
  }
];

// Can mix different resource types in one file (just like Terraform)
local notificationPolicyUtils = import '../../../../lib/notification-policy-utils.libsonnet';

local notificationPolicies = [
  notificationPolicyUtils.createNotificationPolicy(
    name='api-gw-anomaly-routing',
    receiver='api-gw-oncall-team',
    objectMatchers=[
      ['service', '=', 'api-gw'],
      ['alert_type', '=', 'anomaly']
    ]
  )
];

// Export multiple resource types from one file (like Terraform)
{
  alertConfigs: alertConfigs,
  notificationPolicies: notificationPolicies
}