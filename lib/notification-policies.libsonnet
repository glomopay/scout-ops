 local createNotificationPolicy(name, receiver, objectMatchers=[], groupBy=["grafana_folder",
                "alertname"], groupWait='10s', groupInterval='5m', repeatInterval='1h') = {
            apiVersion: 'grizzly.grafana.com/v1alpha1',
            kind: 'AlertNotificationPolicy',
            metadata: {
                name: name,
            },
            spec: {
                receiver: receiver,
                object_matchers: objectMatchers,
                group_by: groupBy,
                group_wait: groupWait,
                group_interval: groupInterval,
                repeat_interval: repeatInterval,
            },
        };