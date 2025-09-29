# ENVIRONMENT ?= stage
# TEAM ?= platform
# SERVICE ?= api-gateway

generate:
	jsonnet \
		--ext-str ENVIRONMENT="$(ENVIRONMENT)" \
		--ext-str TEAM="$(TEAM)" \
		--ext-str SERVICE="$(SERVICE)" \
		--ext-str ALERT_CONFIGS="$$(jsonnet teams/$(ENVIRONMENT)/$(TEAM)/$(SERVICE)/alerts.jsonnet)" \
		--ext-str TEAM_CONFIGS="$$(jsonnet teams/$(ENVIRONMENT)/$(TEAM)/config.jsonnet)"\
		main.jsonnet > resources.json

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