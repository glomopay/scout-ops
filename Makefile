# ENVIRONMENT ?= stage
# TEAM ?= platform
# SERVICE ?= api-gateway

# Pull existing alert rule groups from Grafana
pull-existing:
	@echo "=== Pulling existing alert rule groups from Grafana ==="
	@mkdir -p existing-alerts
	@grr pull AlertRuleGroup --format json existing-alerts/ || echo "  (No existing alert groups found in Grafana)"
	@echo "✅ Existing alerts pulled to existing-alerts/"

# Generate new alert resources
generate-new:
	@echo "=== Generating new alerts ==="
	jsonnet \
		--ext-str ENVIRONMENT="$(ENVIRONMENT)" \
		--ext-str TEAM="$(TEAM)" \
		--ext-str SERVICE="$(SERVICE)" \
		--ext-str ALERT_CONFIGS="$$(jsonnet teams/$(ENVIRONMENT)/$(TEAM)/$(SERVICE)/alerts.jsonnet)" \
		--ext-str TEAM_CONFIGS="$$(jsonnet teams/$(ENVIRONMENT)/$(TEAM)/config.jsonnet)"\
		main.jsonnet > resources.json

# Merge existing and new alert rules
merge:
	@echo "=== Merging existing and new alert rules ==="
	python3 scripts/merge-alerts.py

# Full generate workflow: pull -> generate -> merge
generate: pull-existing generate-new merge
	@echo ""
	@echo "✅ resources.json ready for diff/apply"

diff: generate
	grr diff resources.json

apply: generate
	grr apply resources.json

config:
	grr config use-context scout
	grr config set grafana.url "${GRAFANA_URL}"
	grr config set grafana.token "${GRAFANA_TOKEN}"

clean:
	rm -f resources.json
	rm -rf existing-alerts/