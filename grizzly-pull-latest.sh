#!/bin/bash

set -e

# CONFIGURATION
RESOURCE_DIR="./resources"

# INIT GRIZZLY
# IMPORTANT: You need to set these environment variables before running the script:
# export GRAFANA_URL="https://your-grafana-instance.com"
# export GRAFANA_TOKEN="your-grafana-api-token"
grr config create-context scout
grr config use-context scout
grr config set grafana.url "${GRAFANA_URL}"
grr config set grafana.token "${GRAFANA_TOKEN}"

mkdir -p "$RESOURCE_DIR"
grr pull --output=json --continue-on-error "$RESOURCE_DIR"