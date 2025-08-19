// CPU Alert using JSON configuration
local cpuTemplate = import '../templates/alerts/cpu-monitoring.libsonnet';

// Load configuration from JSON file
local config = std.parseJson(importstr 'cpu-alert-config.json');

// Generate the alert using the template
cpuTemplate.template(config).result