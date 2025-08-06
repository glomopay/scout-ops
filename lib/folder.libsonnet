// Helper function to create a Grafana dashboard folder
local createFolder(name, title) = {
  apiVersion: 'grizzly.grafana.com/v1alpha1',
  kind: 'DashboardFolder',
  metadata: {
    name: name,
  },
  spec: {
    title: title,
  },
};

{
  createFolder: createFolder,
}
