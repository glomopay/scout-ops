// Terraform-style numbered file: 02-contacts.jsonnet
// This file will be automatically discovered and processed

local contactPointUtils = import '../../../../lib/notification-channel-utils.libsonnet';

local contactPoints = [
  contactPointUtils.createContactPoint(
    name='api-gw-oncall-team',
    type='slack',
    settings={
      url: std.extVar('STAGE_PLATFORM_SLACK_URL'),
      title: 'API Gateway On-Call Alert',
      text: 'Service Alert: {{range .Alerts}}{{.Annotations.summary}}{{end}}',
      channel: '#api-gw-oncall'
    }
  )
];

// Export contact points
{
  contactPoints: contactPoints
}