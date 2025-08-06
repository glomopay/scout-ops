 local lib = import '../lib/alert-rules.libsonnet';

  // Create CPU alert
  local cpuAlert = lib.makeAlert(
    title='High CPU Usage',
    pendingPeriod='5m0s',
    data=[
    {
      "refId": "A",
      "relativeTimeRange": {
          "from": 3600,
          "to": 0
      },

"datasourceUid": "ds-scout-altinity-ch",
    "model": {
        "adHocFilters": [],
        "adHocValuesQuery": "",
        "add_metadata": true,
        "contextWindowSize": "10",
        "database": "kulu",
        "datasource": {
            "type": "vertamedia-clickhouse-datasource",
            "uid": "ds-scout-altinity-ch"
        },
        "dateTimeColDataType": "TimeUnix",
        "dateTimeType": "DATETIME64",
        "editorMode": "sql",
        "extrapolate": true,
        "format": "time_series",
        "formattedQuery": "SELECT $timeSeries as t, count() FROM $table WHERE $timeFilter GROUP BY t ORDER BY t",
        "instant": false,
        "interval": "",
        "intervalFactor": 1,
        "intervalMs": 1000,
        "maxDataPoints": 43200,
        "nullifySparse": false,
        "query": "select $timeSeries t, ResourceAttributes[\'k8s.node.name\'] as node, max(Value) from $table where $timeFilter and ResourceAttributes[\'environment\'] = \'stage\' and ServiceName = \'scout-apps-eks\' and MetricName = \'k8s.node.cpu.utilization\' Group by t, node Order by t",
        "range": true,
        "rawQuery": "/* grafana dashboard=$__dashboard, user='4' */\nSELECT (intDiv(toFloat64(TimeUnix) * 1000, (5 * 1000)) * (5 * 1000)) as t, max(Value), ResourceAttributes['k8s.node.name'] as node\nFROM infraspec.otel_metrics_gauge \nWHERE TimeUnix >= toDateTime64(1753683380,3) AND TimeUnix <= toDateTime64(1753686980,3) \nAND MetricName = 'k8s.node.cpu.utilization'\nAND ServiceName = 'scout-apps-eks' and ResourceAttributes['environment'] = 'stage'\nGROUP BY t, node\nORDER BY t",
        "refId": "A",
        "round": "0s",
        "skip_comments": true,
        "table": "otel_metrics_gauge",
        "useWindowFuncForMacros": true
    }
    },
    {
    "refId": "B",
    "relativeTimeRange": {
        "from": 0,
        "to": 0
    },
    "datasourceUid": "__expr__",
    "model": {
        "conditions": [
            {
                "evaluator": {
                    "params": [],
                    "type": "gt"
                },
                "operator": {
                    "type": "and"
                },
                "query": {
                    "params": [
                        "B"
                    ]
                },
                "reducer": {
                    "params": [],
                    "type": "last"
                },
                "type": "query"
            }
        ],
        "datasource": {
            "type": "__expr__",
            "uid": "__expr__"
        },
        "expression": "A",
        "intervalMs": 1000,
        "maxDataPoints": 43200,
        "reducer": "last",
        "refId": "B",
        "settings": {
            "mode": ""
        },
        "type": "reduce"
    }
    },
    {
    "refId": "C",
    "relativeTimeRange": {
        "from": 0,
        "to": 0
    },
    "datasourceUid": "__expr__",
    "model": {
        "conditions": [
            {
                "evaluator": {
                    "params": [
                        80
                    ],
                    "type": "gt"
                },
                "operator": {
                    "type": "and"
                },
                "query": {
                    "params": [
                        "C"
                    ]
                },
                "reducer": {
                    "params": [],
                    "type": "last"
                },
                "type": "query"
            }
        ],
        "datasource": {
            "type": "__expr__",
            "uid": "__expr__"
        },
        "expression": "B",
        "intervalMs": 1000,
        "maxDataPoints": 43200,
        "refId": "C",
        "type": "threshold"
    }
}
    ],
    folderUid='fetdh3jpthwjka',
    ruleGroup='cpu-monitoring',
    summary='High CPU Usage',
    description='High CPU Usage',
    runbookURL='https://runbooks.company.com/cpu-high',
    customAnnotations={
      metric_type: 'cpu',
      alert_type: 'threshold',    
    },
    labels={
      severity: 'warning',
      team: 'platform-team',
      environment: 'stage',
      service: 'scout-apps-eks',
    }
  );

  // Create alert group
  local alertGroup = lib.createAlertRuleGroup(
    title='cpu-monitoring',
    folderUid='fetdh3jpthwjka',
    interval=300,  // Check every  5 minute
    rules=[cpuAlert]
  );


  // Output
  {
    cpuAlertGroup: alertGroup,
  }