local folderTemplate = import 'templates/folder-template.jsonnet';
local notificationTemplate = import 'templates/notification-channel-template.jsonnet';
local notificationPolicyTemplate = import 'templates/notification-policy-template.jsonnet';
local alertTemplate = import 'templates/alert-rule-template.jsonnet';

// Get configuration from user via extVars
local environment = std.extVar('ENVIRONMENT') default 'stage';
local teamsStr = std.extVar('TEAMS') default 'platform';
local servicesStr = std.extVar('SERVICES') default 'api-gw';

// Parse comma-separated user inputs
local userTeams = std.split(teamsStr, ',');
local userServices = std.split(servicesStr, ',');

// Function to get team secrets from environment variables
local getTeamSecrets(env, team) = {
  slackUrl: std.extVar(std.asciiUpper(env) + '_' + std.asciiUpper(team) + '_SLACK_URL') default 'https://hooks.slack.com/default',
  pagerDutyKey: std.extVar(std.asciiUpper(env) + '_' + std.asciiUpper(team) + '_PAGERDUTY_KEY') default 'default-key',
};

// // Function to validate that requested services exist for a team
// local validateServices(env, team, requestedServices) = 
//   [
//     service for service in requestedServices
//     if (
//       try
//         // Check if service directory exists by trying to import any alert file from it
//         (import ('environments/' + env + '/' + team + '/' + service + '/alerts.jsonnet')) != null ||
//         (import ('environments/' + env + '/' + team + '/' + service + '/cpu-alerts.jsonnet')) != null ||
//         (import ('environments/' + env + '/' + team + '/' + service + '/api-alerts.jsonnet')) != null ||
//         (import ('environments/' + env + '/' + team + '/' + service + '/db-alerts.jsonnet')) != null ||
//         (import ('environments/' + env + '/' + team + '/' + service + '/memory-alerts.jsonnet')) != null ||
//         (import ('environments/' + env + '/' + team + '/' + service + '/performance-alerts.jsonnet')) != null
//       catch
//         false
//     )
//   ];

// Function to get actual .jsonnet files in a service directory from external variable
local getServiceJsonnetFiles(env, team, service) = 
  // Get the file list passed from command line via external variable
  // Format: SERVICE_NAME_FILES="file1.jsonnet,file2.jsonnet,file3.jsonnet"
  local extVarName = std.asciiUpper(env) + '_' + std.asciiUpper(team) + '_' + std.asciiUpper(service) + '_FILES';
  local filesStr = std.extVar(extVarName) default '';
  
  if filesStr == '' then
    // No files specified for this service
    []
  else
    // Split the comma-separated file list
    std.split(filesStr, ',');

// Function to validate that requested services exist for a team (by checking for any .jsonnet files)
local validateServices(env, team, requestedServices) = 
  [
    service for service in requestedServices
    if std.length(getServiceJsonnetFiles(env, team, service)) > 0
  ];

// Function to get all resources for a service by importing all existing .jsonnet files (Real filesystem scanning)
local getAllServiceResources(env, team, service, teamConfig) = 
  local resourceFiles = getServiceJsonnetFiles(env, team, service);
  local allResources = std.flattenArrays([
    local resourcePath = 'environments/' + env + '/' + team + '/' + service + '/' + resourceFile;
    try 
      local importedResource = import resourcePath;
      // Handle different resource types
      if std.objectHas(importedResource, 'alertConfigs') then
        // Alert resources - apply team defaults and create alert rule groups
        local teamDefaults = if std.objectHas(teamConfig, 'alerting') then teamConfig.alerting else {};
        local processedAlerts = [
          config + {
            labels: (if std.objectHas(teamDefaults, 'defaultLabels') then teamDefaults.defaultLabels else {}) + 
                    (if std.objectHas(config, 'labels') then config.labels else {}),
            'for': if std.objectHas(config, 'for') then config.for 
                   else if std.objectHas(teamDefaults, 'pendingPeriod') then teamDefaults.pendingPeriod 
                   else '5m'
          }
          for config in importedResource.alertConfigs
        ];
        if std.length(processedAlerts) > 0 then
          [alertTemplate.createAlertRuleGroup(env + '-' + team + '-' + service, processedAlerts)]
        else []
      else if std.objectHas(importedResource, 'contactPoints') then
        // Contact point resources
        importedResource.contactPoints
      else if std.objectHas(importedResource, 'notificationPolicies') then
        // Notification policy resources
        importedResource.notificationPolicies
      else if std.objectHas(importedResource, 'dashboards') then
        // Dashboard resources
        importedResource.dashboards
      else if std.objectHas(importedResource, 'datasources') then
        // Data source resources
        importedResource.datasources
      else if std.objectHas(importedResource, 'folders') then
        // Folder resources
        importedResource.folders
      else
        // Unknown resource type - return as-is
        [importedResource]
    catch 
      []
    for resourceFile in resourceFiles
  ]);
  
  allResources;

// Function to get team configuration (contact points, policies, etc.)
local getTeamConfig(env, team) = 
  local configPath = 'environments/' + env + '/' + team + '/config.jsonnet';
  try 
    (import configPath)
  catch 
    {
      resources: [],
      contactPoints: [],
      notificationPolicies: []
    };

// Function to validate that requested teams exist in the environment
local validateTeams(env, requestedTeams) = 
  [
    team for team in requestedTeams
    if (
      try
        (import ('environments/' + env + '/' + team + '/config.jsonnet')) != null
      catch
        false
    )
  ];

// Create all resources for a single team with user-specified services
local createTeamResources(env, team, requestedServices) = 
  local teamSecrets = getTeamSecrets(env, team);
  local teamConfig = getTeamConfig(env, team);
  local validServices = validateServices(env, team, requestedServices);
  
  [
    // Create team folder
    folderTemplate.createFolder(
      name=env + '-' + team,
      title=std.asciiUpper(env) + ' ' + std.asciiUpper(team) + ' Team'
    ),
    // Create team notification policy
    notificationPolicyTemplate.createGlobalPolicy(
      name='policy-' + env + '-' + team,
      receiver='slack-' + env + '-' + team
    ),
  ] + 
  // Create team contact points
  notificationTemplate.createContactPointWithIntegrations(env + '-' + team, { [env + '-' + team]: teamSecrets }) +
  // Create all resources for user-specified services (loop through each service and discover all its resources)
  std.flattenArrays([
    getAllServiceResources(env, team, service, teamConfig)
    for service in validServices
  ]);

// Main execution with user-provided configuration
local env = environment;
local validTeams = validateTeams(env, userTeams);

// Create environment folder + all team resources
[
  // Create main environment folder
  folderTemplate.createFolder(
    name=env + '-monitoring',
    title=std.asciiUpper(env) + ' Environment Overview'
  ),
] +
// Create all resources for user-specified teams and services
std.flattenArrays([
  createTeamResources(env, team, userServices)
  for team in validTeams
])