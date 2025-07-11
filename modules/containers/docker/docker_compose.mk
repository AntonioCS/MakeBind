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
dc_files ?= $(mb_empty)
#$(error ERROR: No docker compose files provided, please add the variable dc_files with the files to your projects mb_config.mk)
dc_bin ?= docker compose
dc_bin_options ?= $(if $(value mb_project_name),-p $(mb_project_name),$(mb_empty))
dc_use_bake ?= $(mb_true)# Use bake for on build
#$(if $(dc_use_bake),COMPOSE_BAKE=true) # Where to put this..

## Parameters
# $1 = command (required)
# $2 = options (optional)
# $3 = services (optional)
# $4 = extras (command [args..]) - See exec documentation of docker composes (optional)
## Variables that will affect the specific command
# dc_cmd_options_<command> = Command specific options
# dc_cmd_services_<command> = Command specific service(s)
# dc_cmd_extras_<command> = Command specific extras
define dc_invoke
$(strip
	$(eval
		$0_params_command := $(if $(value 1),$1,$(error ERROR: You must pass a commad))
		$0_params_options := $(if $(value 2),$2)
		$0_params_services := $(if $(value 3),$3)
		$0_params_extras := $(if $(value 4),$4)
	)
	$(eval
		$0_bin := $(dc_bin)
		$0_bin_options := $(dc_bin_options)
		$0_all_dc_files := $(if $(value dc_files),$(addprefix --file ,$(dc_files)))
		$0_all_dc_env_files := $(if $(value dc_env_files),$(addprefix --env-file ,$(dc_env_files)))
		$0_cmd := $($0_params_command)
		$0_options := $($0_params_options)
		$0_services := $($0_params_services)
		$0_extras := $($0_params_extras)
		$0_cmd_options := $(if $(value dc_cmd_options_$1),$(dc_cmd_options_$1))
		$0_cmd_services := $(if $(value dc_cmd_services_$1),$(dc_cmd_services_$1))
		$0_cmd_extras := $(if $(value dc_cmd_extras_$1),$(dc_cmd_extras_$1))
	)

	$(call mb_debug_print, dc_invoke_bin: $(dc_invoke_bin),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_bin_options: $(dc_invoke_bin_options),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_all_dc_files: $(dc_invoke_all_dc_files),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_all_dc_env_files: $(dc_invoke_all_dc_env_files),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_cmd: $(dc_invoke_cmd),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_options: $(dc_invoke_options),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_services: $(dc_invoke_services),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_extras: $(dc_invoke_extras),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_cmd_options: $(dc_invoke_cmd_options),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_cmd_services: $(dc_invoke_cmd_services),$(mb_debug_dc_invoke))
	$(call mb_debug_print, dc_invoke_cmd_extras: $(dc_invoke_cmd_extras),$(mb_debug_dc_invoke))

	$(eval $0_command := $(strip $($0_bin)
			$($0_bin_options)
			$($0_all_dc_files)
			$($0_all_dc_env_files)
			$($0_cmd)
			$($0_options)
			$($0_cmd_options)
			$($0_services)
			$($0_cmd_services)
			$($0_extras)
			$($0_cmd_extras)
		)
	)
	$(call mb_invoke,$($0_command))
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

define dc_build_args_linux_mac
--build-arg USER_ID=$(if $(value mb_dc_build_user_id),$(mb_dc_build_user_id),$(shell id -u)) \
--build-arg USER_NAME=$(if $(value mb_dc_build_user_name),$(mb_dc_build_user_name),$(shell whoami)) \
--build-arg GROUP_ID=$(if $(value mb_dc_build_group_id),$(mb_dc_build_group_id),$(shell id -g))
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

dc/restart: ## Restart all containers (calls dc/stop & dc/start)
dc/restart: dc/stop
dc/restart: dc/start

dc/build: ## Build all containers
	$(call mb_os_detection)
	$(call dc_invoke,build,--parallel $(if $(mb_os_is_linux_or_osx),$(dc_build_args_linux_mac)))

dc/rebuild: ## Rebuild all containers (calls dc/stop & dc/build with --no-cache & dc/start)
dc/rebuild: dc/stop
dc/rebuild: dc_cmd_options_build := --no-cache
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
		$(call mb_printf_info,Nuking all process stoppped)
	)

dc/invoke: ## Run docker compose command with given parameters (use with: params="<command> <service> <extra>")
	$(if $(value params),
		$(eval
			$@_cmd := $(word 1,$(params))
			$@_service := $(word 2,$(params))
			$@_extra := $(wordlist 3,$(words $(params)),$(params))
		)
		$(call dc_invoke,$($@_cmd),,$($@_service),$($@_extra))
	,
		$(call mb_printf_error, You need to pass the variable params. Ex.: make $@ params="exec app ls -la")
	)

dc/stats: ## Show stats of containers
	$(call dc_invoke,stats)

endif # __MB_MODULES_DOCKER_DOCKER_COMPOSE_TARGETS__
