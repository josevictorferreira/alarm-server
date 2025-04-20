TARGETS := $(shell grep -E '^[a-zA-Z0-9_-]+:.*?# .*$$' $(MAKEFILE_LIST) | cut -d: -f1)
.PHONY: $(TARGETS)

.DEFAULT_GOAL := help

dev: ## Run the development server
	./bin/dev

server: ## Run the production server
	./bin/server

build: ## Build the project container image
	docker-compose build

buildf: ## Build the project container image with no cache
	docker-compose build --no-cache

up: ## Start the project container
	docker-compose up

upd: ## Start the project container in detached mode
	docker-compose up -d

logs: ## Show the logs of the project container
	docker logs alarm_server -f

sh: ## Open a shell in the project container
	docker exec -it alarm_server /bin/sh

lint: ## Run the linter
	bundle exec rubocop

t_ping: ## Ping the server
	echo "PING" | nc 0.0.0.0 8888

t_alarm: ## Test the server with an alarm message
	echo '{"Address": "0x0A01A8C0", "Channel": 0, "Descrip": "", "Event": "HumanDetect", "SerialID": "93a94d6fcb2e8056", "StartTime": "2025-04-20 18:05:43", "Status": "Start", "Type": "Alarm"}' | nc 0.0.0.0 8888

t_log: ## Test the server with an log message
	echo '{"Address": "0x0A01A8C0", "Channel": 0, "Descrip": "", "Event": "BlindDetect", "SerialID": "93a94d6fcb2e8056", "StartTime": "2025-04-20 18:05:43", "Status": "Start", "Type": "Log"}' | nc 0.0.0.0 8888

t_invalid: ## Test the server with an invalid message
	echo '{"Address": "0x0A01A8C0", "Channel": 0, "Descrip": "", "Event": "HumanDetect", "SerialID": "93a94d6fcb2e8056", "StartTime": "2025-04-20 18:05:43", "Status": "Start", "Type": "RandomType"}' | nc 0.0.0.0 8888

t_invalid_parse: ## Test the server with an invalid message with invalid json
	echo 'RandomMessage Hello World!' | nc 0.0.0.0 8888

remove_tag: ## Remove the git tag :arguments -- TAG
	git tag -d $(TAG)
	git push origin --delete $(TAG)

helm_upgrade: ## Upgrade the helm chart
	helm upgrade --install alarm-server -n self-hosted --values .helm/alarm-server/values.yaml .helm/alarm-server

help: ## Show this help.
	@printf "Usage: make [target]\n\nTARGETS:\n"; grep -F "##" $(MAKEFILE_LIST) | grep -Fv "grep -F" | grep -Fv "printf " | sed -e 's/\\$$//' | sed -e 's/##//' | column -t -s ":" | sed -e 's/^/    /'; printf "\n"
