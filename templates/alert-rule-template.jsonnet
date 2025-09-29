local alertUtils = import '../lib/alert-utils.libsonnet';

// Default evaluation configuration
local defaultEvalConfig = {
  interval: 60, 
  pendingPeriod: '5m', 
  keepFiringFor: '', 
};

// Default data query configuration
local defaultDataConfig = {
  database: 'oteldemo1',
  datasource: {
    type: "vertamedia-clickhouse-datasource",
    uid: "ds-scout-altinity-ch"
  }
};

// Default evaluator configuration
local defaultEvaluator = {
  type: 'gt',
  params: []
};

local defaultReducer = {
  type: 'last',
  params: []
};

local defaultRelativeTimeRange = {
  from: 300,
  to: 0
};

// Template function that creates alert rule groups from config
local createAlertRuleGroup(title, folderUid, alertRules, interval=300, teamConfig = null) =
  local rules = [
    {
      ruleGroup: title,
      title: rule.title,
      condition: 'C',
      data: [
        {
          refId: 'A',
          queryType: '',
          relativeTimeRange: defaultRelativeTimeRange,
          datasourceUid: defaultDataConfig.datasource.uid,
          model: {
            database: defaultDataConfig.database  ,
            datasource: defaultDataConfig.datasource,
            rawQuery: true,
            query: rule.query,
            interval: interval,
            relativeTimeRange: if std.objectHas(rule, 'relativeTimeRange') && rule.relativeTimeRange != null then rule.relativeTimeRange else defaultRelativeTimeRange,
            dateTimeColDataType: rule.dateTimeColDataType,
            dateTimeType: rule.dateTimeType,
            format: rule.format,
            table: rule.table,
          }
        },
        {
          refId: 'B',
          datasourceUid: '__expr__',
          model: {
            conditions: [
              {
                evaluator: defaultEvaluator,
                operator: { type: 'and' },
                query: { params: ['B'] },
                reducer: defaultReducer,
                type: 'query'
              }
            ],
            datasource: { type: '__expr__', uid: '__expr__' },
            expression: 'A',
            intervalMs: 1000,
            maxDataPoints: 43200,
            type: 'reduce',
            refId: 'B',
            reducer : if std.objectHas(rule, 'reducerType') && rule.reducerType != null then rule.reducerType else defaultReducer.type
          }
        },
      {
          refId: 'C',
          datasourceUid: '__expr__',
          model: {
            conditions: [
              {
                evaluator: rule.evaluator,
                operator: { type: 'and' },
                query: { params: ['C'] },
                reducer: defaultReducer,
                type: 'query'
              }
            ],
            datasource: { type: '__expr__', uid: '__expr__' },
            expression: 'B',
            intervalMs: 1000,
            maxDataPoints: 43200,
            type: 'threshold',
            refId: 'C'
       
          }
        }

      ],
      noDataState:  if std.objectHas(rule, 'noDataState') && rule.noDataState != null then rule.noDataState else 'NoData',
      execErrState: if std.objectHas(rule, 'execErrState') && rule.execErrState != null then rule.execErrState else 'Alerting',
      'for': if std.objectHas(rule, 'for') && rule.pendingPeriod != null then rule.pendingPeriod else defaultEvalConfig.pendingPeriod,
      keepFiringFor: if std.objectHas(rule, 'keepFiringFor') && rule.keepFiringFor != null then rule.keepFiringFor else defaultEvalConfig.keepFiringFor,
      annotations: rule.annotations,
      labels: teamConfig.labels + rule.labels,
      folderUID: if std.objectHas(rule, 'folderUid') && rule.folderUid != null then rule.folderUid else teamConfig.folderUid,
      notification_settings: {
        receiver: if std.objectHas(rule, 'contactPoint') && rule.contactPoint != null 
             then rule.contactPoint 
             else teamConfig.contactPoint
      },
    } for rule in alertRules
  ];

  alertUtils.createOrUpdateAlertRuleGroup(
    title=title,
    folderUid=folderUid,
    interval=interval,
    rules=rules,
  );

// Export the createAlertGroup function
{
  createAlertRuleGroup: createAlertRuleGroup
}