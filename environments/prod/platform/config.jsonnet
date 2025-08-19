// Platform team configuration for production environment
{
  team: 'platform',
  environment: 'prod',
  
  // Team-specific settings
  alerting: {
    defaultSeverity: 'critical',
    escalationTimeout: '2m',
    resources: ['api-gw', 'database', 'cache']
  },
  
  // Contact preferences  
  contactPoints: {
    slack: {
      channel: '#platform-alerts-prod',
      mentions: ['@platform-oncall', '@platform-lead']
    },
    pagerduty: {
      service: 'platform-prod',
      urgency: 'high'
    }
  }
}