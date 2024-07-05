#####################################################################################
# Project: MakeBind
# File: modules/docker/docker_compose.mk
# Description: All targets for docker compose
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_DOCKER_DOCKER_COMPOSE_FUNCTIONS__
__MB_MODULES_DOCKER_DOCKER_COMPOSE_FUNCTIONS__ := 1

mb_debug_dc_invoke ?= $(mb_debug)
dc_default_shell_bin ?= /bin/sh
dc_files ?= $(error ERROR: No docker compose files provided, please add the variable dc_files with the files to your projects mb_config.mk)


#$1 = command
#$2 = options
#$3 = services
#$4 = extra
define dc_invoke
$(strip
	$(if $(value 1),,$(error ERROR: You must pass a commad))
	$(eval
		dc_invoke_bin := $(if $(value dc_bin),$(dc_bin),docker compose)
		dc_invoke_bin_options := $(if $(value dc_bin_options),$(dc_bin_options))
		dc_invoke_all_dc_files := $(if $(value dc_files),$(addprefix --file ,$(dc_files)))
		dc_invoke_all_dc_env_files := $(if $(value dc_env_files),$(addprefix --env-file ,$(dc_env_files)))
		dc_invoke_cmd := $1
		dc_invoke_options := $(if $(value 2),$2)
		dc_invoke_services := $(if $(value 3),$3)
		dc_invoke_extra := $(if $(value 4),$4)
		dc_invoke_cmd_options := $(if $(value dc_cmd_options_$1),$(dc_cmd_options_$1))
		dc_invoke_cmd_services := $(if $(value dc_cmd_services_$1),$(dc_cmd_services_$1))
		dc_invoke_cmd_extras := $(if $(value dc_cmd_extras_$1),$(dc_cmd_extras_$1))
	)

	$(call mb_debug_print, dc_invoke_bin: $(dc_invoke_bin),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_bin_options: $(dc_invoke_bin_options),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_all_dc_files: $(dc_invoke_all_dc_files),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_all_dc_env_files: $(dc_invoke_all_dc_env_files),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_cmd: $(dc_invoke_cmd),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_options: $(dc_invoke_options),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_services: $(dc_invoke_services),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_extra: $(dc_invoke_extra),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_cmd_options: $(dc_invoke_cmd_options),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_cmd_services: $(dc_invoke_cmd_services),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_cmd_extras: $(dc_invoke_cmd_extras),$(mb_debug_dc_invoke))

	$(eval dc_invoke_command := $(strip $(dc_invoke_bin)
			$(dc_invoke_bin_options)
			$(dc_invoke_all_dc_files)
			$(dc_invoke_all_dc_env_files)
			$(dc_invoke_cmd)
			$(dc_invoke_options)
			$(dc_invoke_cmd_options)
			$(dc_invoke_services)
			$(dc_invoke_cmd_services)
			$(dc_invoke_extra)
			$(dc_invoke_cmd_extras)
		)
	)
	$(call mb_invoke,$(dc_invoke_command))
)
endef

dc_shellc_default_shell_bin ?= $(dc_default_shell_bin) # or /bin/bash
dc_shellc_default_cmd ?= exec # or run

define dc_shellc
$(strip
	$(eval dc_shellc_service := $1)
	$(eval dc_shellc_selected_shell_bin := $(if $(value 3),$3,$(dc_shellc_default_shell_bin)))
	$(call dc_invoke,$(dc_shellc_default_cmd),,$(dc_shellc_service),$(dc_shellc_selected_shell_bin) -c "$(call mb_normalizer,$2)")
)
endef

endif # __MB_MODULES_DOCKER_DOCKER_COMPOSE_FUNCTIONS__
#####################################################################################
ifndef __MB_MODULES_DOCKER_DOCKER_COMPOSE_TARGETS__
__MB_MODULES_DOCKER_DOCKER_COMPOSE_TARGETS__ := 1

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
	$(call dc_invoke,ps,--no-trunc)

dc/status-all: dc_cmd_options_ps := --all
dc/status-all: dc/status
dc/status-all: ## Show status (including stopped containers)

dc/restart: ## Restart all containers (calls stop & up)
dc/restart: dc/stop
dc/restart: dc/start

### TODO: Fix this for windows, there is not need to pass any parameters and it will error due to missing id and whoami
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

dc/invoke: ## Run docker compose command with given parameters (use with: params="<command> <service> <parameters>")
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

endif # __MB_MODULES_DOCKER_DOCKER_COMPOSE_TARGETS__
