// Contact points specific to Database service
local contactPointUtils = import '../../../../lib/notification-channel-utils.libsonnet';

local contactPoints = [
  contactPointUtils.createContactPoint(
    name='database-emergency-alerts',
    type='pagerduty',
    settings={
      integrationKey: std.extVar('STAGE_PLATFORM_PAGERDUTY_KEY'),
      severity: 'critical',
      component: 'database',
      group: 'platform-database'
    }
  ),
  contactPointUtils.createContactPoint(
    name='database-dba-team',
    type='slack',
    settings={
      url: std.extVar('STAGE_PLATFORM_SLACK_URL'),
      title: 'Database Alert - DBA Team',
      text: 'Database Issue: {{range .Alerts}}{{.Annotations.description}}{{end}}',
      channel: '#dba-team'
    }
  )
];

{
  contactPoints: contactPoints
}