# Set up Grafana resources with Grizzly

This repository manages Grafana resources (dashboards, alerts, datasources) as code using [Grizzly](https://github.com/grafana/grizzly).

## Prerequisites

- [Grizzly CLI](https://github.com/grafana/grizzly#installation) (for local development)
- Grafana instance with API access

### Pulling Resources from Grafana

1. Set up environment variables:
   ```bash
   export GRAFANA_URL="https://your-grafana-instance.com"
   export GRAFANA_TOKEN="your-grafana-api-token"
   ```

2. Run the pull script:
   ```bash
   chmod +x grizzly-pull-latest.sh
   ./grizzly-pull-latest.sh
   ```

   This will pull all resources from your Grafana instance into the `resources/` directory.

### Updating Resources

1. Make your changes to the resource files in the `resources/` directory.

2. Preview changes:
   ```bash
   grr diff ./resources/
   ```

## GitHub Actions Pipeline

The repository includes a GitHub Actions workflow that automates the deployment of Grafana resources.

### Workflow Triggers

- **Manual Trigger**: Go to Actions → Grizzly Grafana Deployment → Run workflow
  - **Action**: `diff` (preview changes) or `apply` (apply changes)
  - **Branch**: Branch to deploy from (default: current branch)

- **Automatic Triggers**:
  - Push to `main` branch: Automatically applies changes

### Manual Deployment

1. Go to the "Actions" tab in your GitHub repository
2. Select "Grizzly Grafana Deployment"
3. Click "Run workflow"
4. Choose the action (`diff` or `apply`)
5. Select the branch to deploy from
6. Click "Run workflow"

## Best Practices

1. **Always preview changes** with `diff` before applying
2. **Use pull requests** for review before merging to `main`
3. **Never commit sensitive data** in resource files

## Troubleshooting

- **Authentication issues**: Verify your `GRAFANA_TOKEN` has the correct permissions
- **Resource conflicts**: Check for duplicate UIDs or names in your resource files
