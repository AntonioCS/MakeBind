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
	$(call dc_invoke,build,--parallel --no-cache \
		--build-arg USER_ID=$(if $(value mb_dc_build_user_id),$(mb_dc_build_user_id),$(shell id -u)) \
		--build-arg USER_NAME=$(if $(value mb_dc_build_user_name),$(mb_dc_build_user_name),$(shell whoami)) \
		--build-arg GROUP_ID=$(if $(value mb_dc_build_group_id),$(mb_dc_build_group_id),$(shell id -g)) \
	)

dc/rebuild: ## Rebuild all containers
dc/rebuild: dc/stop
dc/rebuild: dc/build
dc/rebuild: dc/start

dc/remove: ## Remove all stopped containers
	$(call dc_invoke,rm)

dc/nuke: mb_info_msg := Initiating nuking process
dc/nuke: mb/info-nuke-project
dc/nuke: ## Remove all project containers (with volumes)
	$(eval dc_nuke_msg := Are you sure you want to remove all contaioner of this project? [y/n])
	$(if $(call mb_user_confirm,$(dc_nuke_msg)),
		$(call dc_invoke,down,--remove-orphans --volumes --rmi all)
	,
		$(call mb_printf_info,Nuking process stoppped)
	)

dc/nuke-all: ## Remove everything docker related from the system (system prune)
	$(eval dc_nuke_all_msg := Are you sure you want to remove everything?? [y/n])
	$(if $(call mb_user_confirm,$(dc_nuke_all_msg)),
		$(call mb_invoke,docker system prune --all --volumes --force)
	,
		$(call mb_print_info,Nuking all process stoppped)
	)

dc/invoke: ## Run docker compose command with given parameters (params="<command> <service> <parameters>")
	$(if $(value params),
		$(eval
			dc_target_cmd := $(word 1,$(params))
			dc_target_service := $(word 2,$(params))
			dc_target_extra := $(wordlist 3,$(words $(params)),$(params))
		)
		$(call dc_invoke,$(dc_target_cmd),,$(dc_target_service),$(dc_target_extra))
	,
		$(call mb_printf_error, You need to pass the variable params. Ex.: make $@ params="exec app ls -la")
	)



endif # __MB_MODULES_DOCKER_DOCKER_COMPOSE__
