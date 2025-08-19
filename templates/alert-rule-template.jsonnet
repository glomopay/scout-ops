local alertUtils = import '../lib/alert-utils.libsonnet';

// Default values for alert configuration
local defaultLabels = {
  severity: 'warning',
  team: 'sre',
  env: 'stage',
};

// Default evaluation configuration
local defaultEvalConfig = {
  interval: 300, 
  pendingPeriod: '5m', 
  keepFiringFor: '', 
};

// Default data query configuration
local defaultDataConfig = {
  database: 'kulu',
  interval: 60,
  maxDataPoints: 43200,
  queryType: '',
  relativeTimeRange: { from: 600, to: 0 },
  datasource: {
    type: "vertamedia-clickhouse-datasource",
    uid: "ds-scout-altinity-ch"
  }
};

// Default evaluator configuration
local defaultEvaluator = {
  type: 'gt',
  params: [70]
};

// Template function that creates alert rule groups from config
local createAlertRuleGroup(env, alertConfigs) = 
  local rules = [
    local mergedConfig = defaultDataConfig + defaultEvaluator + defaultEvalConfig + config;
    
    alertUtils.makeAlert(
      title=mergedConfig.title,
      data=[
        {
          refId: 'A',
          queryType: mergedConfig.queryType,
          relativeTimeRange: mergedConfig.relativeTimeRange,
          datasource: mergedConfig.datasource,
          rawQuery: true,
          query: mergedConfig.query,
          interval: mergedConfig.interval + 's',
          maxDataPoints: mergedConfig.maxDataPoints
        },
        {
          refId: 'B',
          queryType: '',
          relativeTimeRange: {
            from: 0,
            to: 0
          },
          datasource: {
            name: 'Expression',
            type: '__expr__',
            uid: '__expr__'
          },
          conditions: [
            {
              evaluator: mergedConfig.evaluator,
              operator: {
                type: 'and'
              },
              query: {
                params: ['A']
              },
              reducer: {
                params: [],
                type: 'last'
              },
              type: 'query'
            }
          ],
          expression: 'A',
          intervalMs: 1000,
          maxDataPoints: mergedConfig.maxDataPoints
        }
        {
           refId: "C",
           relativeTimeRange: mergedConfig.relativeTimeRange,
           datasourceUid: "__expr__",
           model: {
            conditions: [
            {
                evaluator: {
                    params: mergedConfig.params,
                    type: mergedConfig.evaluator.type
                },
                operator: {
                    type: "and"
                },
                query: {
                    params: ['C'] 
                },
                reducer: {
                    params: [],
                    type: "last"
                },
                type: "query"
            }
        ],
        datasource: {
            type: "__expr__",
            uid: "__expr__"
        },
        expression: 'B',
        intervalMs: 1000,
        maxDataPoints: mergedConfig.maxDataPoints,
        refId: "C",
        type: "threshold"
    }
        }
      ],
      folderUid=config.folderUid,
      pendingPeriod=mergedConfig.for,
      labels=defaultLabels + mergedConfig.labels,
      annotations= defaultAnnotations + mergedConfig.annotations,
      condition='B'
    )
    for config in alertConfigs
  ];

  alertUtils.createAlertRuleGroup(
    title=mergedConfig.title,
    folderUid=mergedConfig.folderUid,
    interval=mergedConfig.interval,
    rules=rules
  );

{
  createAlertRuleGroup: createAlertRuleGroup
}