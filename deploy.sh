#!/bin/bash

# Real Terraform-like deployment script that scans actual directories
# This script finds all .jsonnet files in service directories and passes them to main.jsonnet

set -e

# Configuration
ENVIRONMENT="${1:-stage}"
TEAMS="${2:-platform}"
SERVICES="${3:-api-gw}"

echo "🚀 Deploying Grafana Resources via main.jsonnet"
echo "Entry Point: main.jsonnet"
echo "Environment: $ENVIRONMENT"
echo "Teams: $TEAMS"
echo "Services: $SERVICES"
echo

# Function to scan a service directory for all .jsonnet files
scan_service_files() {
    local env="$1"
    local team="$2" 
    local service="$3"
    local service_dir="environments/$env/$team/$service"
    
    if [ -d "$service_dir" ]; then
        # Find all .jsonnet files in the service directory
        find "$service_dir" -maxdepth 1 -name "*.jsonnet" -type f -printf '%f\n' 2>/dev/null | tr '\n' ',' | sed 's/,$//'
    else
        echo ""
    fi
}

# Build external variables for jsonnet
JSONNET_ARGS=""
JSONNET_ARGS="$JSONNET_ARGS --ext-str ENVIRONMENT='$ENVIRONMENT'"
JSONNET_ARGS="$JSONNET_ARGS --ext-str TEAMS='$TEAMS'"
JSONNET_ARGS="$JSONNET_ARGS --ext-str SERVICES='$SERVICES'"

# Add team secrets (you'd normally pass these securely)
if [[ "$ENVIRONMENT" == "stage" ]]; then
    JSONNET_ARGS="$JSONNET_ARGS --ext-str STAGE_PLATFORM_SLACK_URL='https://hooks.slack.com/stage-platform'"
    JSONNET_ARGS="$JSONNET_ARGS --ext-str STAGE_PLATFORM_PAGERDUTY_KEY='stage-platform-key'"
    JSONNET_ARGS="$JSONNET_ARGS --ext-str STAGE_DEVOPS_SLACK_URL='https://hooks.slack.com/stage-devops'"
    JSONNET_ARGS="$JSONNET_ARGS --ext-str STAGE_DEVOPS_PAGERDUTY_KEY='stage-devops-key'"
fi

# Scan each team/service combination for .jsonnet files
IFS=',' read -ra TEAM_ARRAY <<< "$TEAMS"
IFS=',' read -ra SERVICE_ARRAY <<< "$SERVICES"

echo "📁 Scanning directories for .jsonnet files:"
for team in "${TEAM_ARRAY[@]}"; do
    for service in "${SERVICE_ARRAY[@]}"; do
        files=$(scan_service_files "$ENVIRONMENT" "$team" "$service")
        if [ -n "$files" ]; then
            ext_var_name="${ENVIRONMENT^^}_${team^^}_${service^^}_FILES"
            JSONNET_ARGS="$JSONNET_ARGS --ext-str $ext_var_name='$files'"
            echo "  $ENVIRONMENT/$team/$service: $files"
        fi
    done
done

echo
echo "🔧 Generated jsonnet command:"
echo "jsonnet $JSONNET_ARGS main.jsonnet"
echo

echo "📋 Executing main.jsonnet with discovered files:"
jsonnet $JSONNET_ARGS main.jsonnet

echo
echo "✅ Deployment completed!"