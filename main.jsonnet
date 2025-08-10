local folderTemplate = import 'templates/folder-template.jsonnet';
local notificationTemplate = import 'templates/notification-channel-template.jsonnet';
local notificationPolicyTemplate = import 'templates/notification-policy-template.jsonnet';

// Import environment-specific alerts
local stageAlerts = import 'environments/stage/stage-alerts.jsonnet';
local prodAlerts = import 'environments/prod/prod-alerts.jsonnet';

// local environments = ['stage', 'prod'];
local environments = ['stage'];
// Secrets map: values pulled from extVars supplied at runtime
local secrets = {
  stage: {
    slackUrl: std.extVar('STAGE_SLACK_URL'),
    pagerDutyKey: std.extVar('STAGE_PAGERDUTY_KEY'),
  },
  prod: {
    slackUrl: std.extVar('PROD_SLACK_URL'),
    pagerDutyKey: std.extVar('PROD_PAGERDUTY_KEY'),
  },
};

// Create all resources
std.flattenArrays([
  [
    // Create folder for each environment
    folderTemplate.createFolder(env),
    // Create notification policy for each environment
    notificationPolicyTemplate.createGlobalPolicy(env),
  ] + 
  // Create contact points for each environment
  notificationTemplate.createContactPointWithIntegrations(env, secrets)
  for env in environments
]) + [
  // Add environment-specific alerts
  stageAlerts,
  // prodAlerts,
]