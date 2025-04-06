TARGETS := $(shell grep -E '^[a-zA-Z0-9_-]+:.*?# .*$$' $(MAKEFILE_LIST) | cut -d: -f1)
.PHONY: $(TARGETS)

.DEFAULT_GOAL := help

dev: ## Run the development server
	./bin/dev

server: ## Run the production server
	./bin/server

ping: ## Ping the server
	echo "PING" | nc 0.0.0.0 8888

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

remove_tag: ## Remove the git tag :arguments -- TAG
	git tag -d $(TAG)
	git push origin --delete $(TAG)

help: ## Show this help.
	@printf "Usage: make [target]\n\nTARGETS:\n"; grep -F "##" $(MAKEFILE_LIST) | grep -Fv "grep -F" | grep -Fv "printf " | sed -e 's/\\$$//' | sed -e 's/##//' | column -t -s ":" | sed -e 's/^/    /'; printf "\n"
