local folderTemplate = import 'templates/folder-template.jsonnet';
local notificationTemplate = import 'templates/notification-channel-template.jsonnet';
local notificationPolicyTemplate = import 'templates/notification-policy-template.jsonnet';
local alertTemplate = import 'templates/alert-rule-template.jsonnet';

// Get configuration from user via extVars
local environment = if std.extVar('ENVIRONMENT') != '' then std.extVar('ENVIRONMENT') else 'stage';
local team = if std.extVar('TEAM') != '' then std.extVar('TEAM') else 'platform';
local service = if std.extVar('SERVICE') != '' then std.extVar('SERVICE') else 'api-gateway';


// Simplified - just for alerts

// Function to get team configuration - hardcoded for now
local getTeamConfig(env, team) = std.parseJson(std.extVar('TEAM_CONFIGS'));

// Functions removed - only creating alerts now

// Import alert utils
local alertUtils = import 'lib/alert-utils.libsonnet';

// Import the alert configurations directly

// Get team config and alert configs
local teamConfig = getTeamConfig(environment, team);
local importedResource = std.parseJson(std.extVar('ALERT_CONFIGS'));

// Get config from team
local folderUid = teamConfig.folderUid;
local contactPoint = teamConfig.contactPoint;

// Create Grizzly AlertRuleGroup using alert template
[
alertTemplate.createAlertRuleGroup(
  title=alertGroup.name,
  folderUid=folderUid,
  alertRules= alertGroup.alertRules,
  interval=300,
  teamConfig=teamConfig
)

for alertGroup in importedResource.alertGroups 
]

