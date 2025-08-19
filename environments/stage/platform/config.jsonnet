// Platform team configuration for stage environment
{
  team: 'platform',
  environment: 'stage',
  
  // Team-specific alerting defaults
  alerting: {
    defaultSeverity: 'warning',
    escalationTimeout: '5m',
    evaluationInterval: '1m',
    pendingPeriod: '5m',
    // Default labels applied to all alerts from this team
    defaultLabels: {
      team: 'platform',
      environment: 'stage',
      criticality: 'medium'
    }
  },
  
  // Notification preferences
  notifications: {
    slack: {
      channel: '#platform-alerts-stage',
      mentions: ['@platform-oncall'],
      template: 'Platform Alert: {{.CommonAnnotations.summary}}'
    },
    pagerduty: {
      service: 'platform-stage',
      urgency: 'low',
      escalationPolicy: 'platform-escalation'
    },
    // Routing rules - which alerts go where
    routing: {
      critical: ['slack', 'pagerduty'],
      warning: ['slack'],
      info: []
    }
  },
  
  // Team services and their default thresholds (alert files are auto-discovered)
  services: {
    'api-gw': {
      displayName: 'API Gateway',
      defaultThresholds: {
        cpu: 80,
        memory: 85,
        latency: 500
      }
    },
    'database': {
      displayName: 'Database',
      defaultThresholds: {
        cpu: 70,
        memory: 90,
        connections: 100
      }
    },
    'redis': {
      displayName: 'Redis Cache',
      defaultThresholds: {
        memory: 85,
        connections: 500,
        hit_rate: 80
      }
    }
  }
}