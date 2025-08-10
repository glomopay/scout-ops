local createAlertRuleGroup(
  title,
  folderUid,
  interval
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
  pendingPeriod,
  keepFiringFor,
  ruleGroup='',
  labels,
  annotations,
  noDataState='NoData',
  execErrState='Error',
  condition='C',
  summary='',
  description='',
  runbookURL='',
  customAnnotations={},
  orgId=1
) = {
  title: title,
  condition: condition,
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