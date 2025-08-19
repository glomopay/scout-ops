// Contact points specific to API Gateway service
local contactPointUtils = import '../../../../lib/notification-channel-utils.libsonnet';

local contactPoints = [
  contactPointUtils.createContactPoint(
    name='api-gw-critical-alerts',
    type='slack',
    settings={
      url: std.extVar('STAGE_PLATFORM_SLACK_URL'),
      title: 'API Gateway Critical Alert',
      text: 'API Gateway Alert: {{range .Alerts}}{{.Annotations.summary}}{{end}}',
      channel: '#api-gw-alerts'
    }
  ),
  contactPointUtils.createContactPoint(
    name='api-gw-performance-alerts',
    type='email',
    settings={
      addresses: 'api-team@company.com;platform-team@company.com'
    }
  )
];

{
  contactPoints: contactPoints
}