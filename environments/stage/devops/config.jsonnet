// DevOps team configuration for stage environment
{
  team: 'devops',
  environment: 'stage',
  
  // Team-specific settings
  alerting: {
    defaultSeverity: 'warning',
    escalationTimeout: '10m',
    resources: ['web-server', 'worker', 'queue']
  },
  
  // Contact preferences
  contactPoints: {
    slack: {
      channel: '#devops-alerts-stage',
      mentions: ['@devops-team']
    },
    pagerduty: {
      service: 'devops-stage',
      urgency: 'low'
    }
  }
}