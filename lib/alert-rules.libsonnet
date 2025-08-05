// alert-rules.libsonnet

// Reusable helper function to create alert rule group
local createAlertRuleGroup(name, folderUid, interval, rules=[]) = {
  apiVersion: 'grizzly.grafana.com/v1alpha1',
  kind: 'AlertRuleGroup',
  metadata: {
    name: folderUid + '.' + name,
  },
  spec: {
    interval: std.parseInt(std.strReplace(interval, "m", "")) * 60,
    title: name,
    rules: rules,
    folderUid: folderUid,
  },
};

// Make Alerts
local makeAlert(title, forDuration='5m0s', data=[], ruleGroup='', folderUid='') = {
  title: title,
  condition: 'C',
  'for': forDuration,
  noDataState: 'NoData',
  execErrState: 'Error',
  orgID: 1,
  ruleGroup: ruleGroup,
  data: data,
  folderUid: folderUid
};

{
  createAlertRuleGroup: createAlertRuleGroup,
  makeAlert: makeAlert
}