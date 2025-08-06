// Default values for alert configuration
local defaultLabels = {
  severity: 'warning',
  team: 'sre',
  env: std.extVar('ENVIRONMENT') || 'stage',  // Dynamic environment 
};


// Default evaluation configuration
local defaultEvalConfig = {
  interval: 300, 
  pendingPeriod: '5m', 
  keepFiringFor: '', 
};


local createAlertRuleGroup(
  title,
  folderUid,
  interval=defaultEvalConfig.interval,
  rules=[],
) = {
  apiVersion: 'grizzly.grafana.com/v1alpha1',
  kind: 'AlertRuleGroup',
  metadata: {
    name: folderUid + '.' + title,
  },
  spec: {
    interval: interval,
    title: title,
    rules: rules,
    folderUid: folderUid,
  },
};


local makeAlert(
  title,
  data,
  folderUid,
  pendingPeriod=defaultEvalConfig.pendingPeriod,
  keepFiringFor=defaultEvalConfig.keepFiringFor,
  ruleGroup='',
  labels=defaultLabels,
  annotations={},
  noDataState='NoData',
  execErrState='Error',
  condition='C',
  summary='',
  description='',
  runbookURL='',
  customAnnotations={},
  orgId=1
) = {
  local defaultAnnotations = {
    summary: summary,
    description: description,
    runbook_url: runbookURL
  },

  local annotations = defaultAnnotations + customAnnotations,
    
    title: title,
    condition: condition,   // Support multiple conditions
    'for': pendingPeriod,
    keepFiringFor: keepFiringFor,
    noDataState: noDataState,
    execErrState: execErrState,
    orgId: orgId,
    ruleGroup: ruleGroup,
    data: data,
    folderUid: folderUid,
    labels: labels,
    annotations: annotations,
  };

{
  createAlertRuleGroup: createAlertRuleGroup,
  makeAlert: makeAlert,
}