// Notification policies specific to API Gateway service
local policyUtils = import '../../../../lib/notification-policy-utils.libsonnet';

local notificationPolicies = [
  policyUtils.createNotificationPolicy(
    name='api-gw-critical-policy',
    receiver='api-gw-critical-alerts',
    objectMatchers=[
      ['service', '=', 'api-gw'],
      ['severity', '=', 'critical'],
      ['environment', '=', 'stage']
    ],
    groupBy=['alertname', 'service'],
    groupWait='30s',
    groupInterval='2m',
    repeatInterval='30m'
  ),
  policyUtils.createNotificationPolicy(
    name='api-gw-warning-policy', 
    receiver='api-gw-performance-alerts',
    objectMatchers=[
      ['service', '=', 'api-gw'],
      ['severity', '=', 'warning'],
      ['environment', '=', 'stage']
    ],
    groupBy=['alertname', 'service'],
    groupWait='5m',
    groupInterval='10m',
    repeatInterval='2h'
  )
];

{
  notificationPolicies: notificationPolicies
}