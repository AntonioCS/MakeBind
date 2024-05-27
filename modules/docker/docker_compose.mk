#####################################################################################
# Project: MakeBind
# File: modules/docker/docker_compose.mk
# Description: All targets for docker compose
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_DOCKER_DOCKER_COMPOSE__
__MB_MODULES_DOCKER_DOCKER_COMPOSE__ := 1

include $(mb_modules_path)/docker/docker_compose/functions.mk

dc/up: mb_info_msg := Starting containers
dc/up: ## Start all containers
	$(eval dc_cmd_options_up ?= -d --wait)
	$(call dc_invoke,up,--remove-orphans)

dc/start: dc/up
dc/start: ## Start all containers (alias for dc/up)

dc/stop: ## Stop all containers
	$(call dc_invoke,stop)

dc/down: ## Stop and remove all containers
	$(call dc_invoke,down)

dc/logs: ## Show logs for all containers
	$(call dc_invoke,logs)

dc/status: ## Show status of all containers
	$(call dc_invoke,ps)

dc/restart: ## Restart all containers
dc/restart: dc/stop
dc/restart: dc/start

dc/build: ## Build all containers
	$(call dc_invoke,build,--parallel --no-cache
		--build-arg USER_ID=$(shell id -u)
		--build-arg USER_NAME=$(shell whoami)
		--build-arg GROUP_ID=$(shell id -g)
	)

dc/rebuild: ## Rebuild all containers
dc/rebuild: dc/stop
dc/rebuild: dc/build
dc/rebuild: dc/start

endif # __MB_MODULES_DOCKER_DOCKER_COMPOSE__
