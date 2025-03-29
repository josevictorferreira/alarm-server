TARGETS := $(shell grep -E '^[a-zA-Z0-9_-]+:.*?# .*$$' $(MAKEFILE_LIST) | cut -d: -f1)
.PHONY: $(TARGETS)

.DEFAULT_GOAL := help

dev: ## Run the development server
	./bin/dev

server: ## Run the production server
	./bin/server

help: ## Show this help.
	@printf "Usage: make [target]\n\nTARGETS:\n"; grep -F "##" $(MAKEFILE_LIST) | grep -Fv "grep -F" | grep -Fv "printf " | sed -e 's/\\$$//' | sed -e 's/##//' | column -t -s ":" | sed -e 's/^/    /'; printf "\n"
