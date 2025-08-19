// Custom naming: main.jsonnet
// Just like Terraform's main.tf, you can use any logical filename
// The system discovers and processes ALL .jsonnet files automatically

local alertConfigs = [
  {
    title: "Web Server Connection Pool Exhausted",
    labels: { severity: "critical", alert_type: "resource" },
    evaluator: { type: "gt", params: [95] },
    annotations: {
      summary: "Web server connection pool is nearly full",
      description: "Web server is using more than 95% of available connections.",
    },
    query: "SELECT $timeSeries AS t, (active_connections/max_connections)*100 AS usage_percentage FROM connections WHERE service='web-server'",
    folderUid: 'stage-devops'
  },
  {
    title: "Web Server Queue Backup",
    labels: { severity: "warning", alert_type: "queue" },
    evaluator: { type: "gt", params: [50] },
    annotations: {
      summary: "Request queue is backing up",
      description: "Web server request queue has more than 50 pending requests.",
    },
    query: "SELECT $timeSeries AS t, count() AS queue_size FROM request_queue WHERE service='web-server' AND status='pending'",
    folderUid: 'stage-devops'
  }
];

// Just like Terraform, one file can contain multiple resource types
local contactPointUtils = import '../../../../lib/notification-channel-utils.libsonnet';

local contactPoints = [
  contactPointUtils.createContactPoint(
    name='web-team-alerts',
    type='email',
    settings={
      addresses: 'web-team@company.com;devops@company.com'
    }
  )
];

// Export everything
{
  alertConfigs: alertConfigs,
  contactPoints: contactPoints  
}