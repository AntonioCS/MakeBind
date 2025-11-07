#####################################################################################
# Project: MakeBind
# File: modules/docker/docker_compose.mk
# Description: All targets for docker compose
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_DOCKER_DOCKER_COMPOSE_FUNCTIONS__
__MB_MODULES_DOCKER_DOCKER_COMPOSE_FUNCTIONS__ := 1

$(if $(and $(strip $(dc_env_files)),$(dc_env_auto_include)),\
	$(foreach dc_current_env_file_to_load,$(dc_env_files),\
		$(eval -include $(dc_current_env_file_to_load))\
	)\
)


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
		$0_prms_command := $(strip $(if $(value 1),$1,$(call mb_printf_error, You must pass a command)))
		$0_prms_options := $(strip $(if $(value 2),$2))
		$0_prms_services := $(strip $(if $(value 3),$3))
		$0_prms_extras := $(strip $(if $(value 4),$4))
	)
	$(eval
		$0_bin := $(dc_bin)
		$0_bin_options := $(dc_bin_options)
		$0_all_dc_files := $(call mb_space_unguard,$(if $(value dc_files),$(addprefix --file ,$(dc_files))))
		$0_all_dc_env_files := $(call mb_space_unguard,$(if $(value dc_env_files),$(addprefix --env-file ,$(dc_env_files))))
		$0_cmd := $($0_prms_command)
		$0_options := $($0_prms_options)
		$0_services := $($0_prms_services)
		$0_extras := $($0_prms_extras)
		$0_cmd_options := $(if $(value dc_cmd_options_$($0_prms_command)),$(dc_cmd_options_$($0_prms_command)))
		$0_cmd_services := $(if $(value dc_cmd_services_$($0_prms_command)),$(dc_cmd_services_$($0_prms_command)))
		$0_cmd_extras := $(if $(value dc_cmd_extras_$($0_prms_command)),$(dc_cmd_extras_$($0_prms_command)))
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

### Function to run commands inside a container using a selected shell
# $1 = service
# $2 = commands to run inside the container (quotes will be added automatically)
# $3 = shell to load /bin/sh or /bin/bash (optional, default: dc_default_shell_bin)
# $4 = docker compose command to be used exec or run (optional, default: dc_shellc_default_cmd)
# $5 = extra options to pass to docker compose (optional, default: none)
define dc_shellc
$(strip
	$(eval $0_service := $(strip $(if $(value 1),$1,$(call mb_printf_error, $0 requires a service))))
	$(eval $0_command := $(strip $(if $(value 2),$2,$(call mb_printf_error, $0 requires a command))))
	$(eval $0_shell_bin := $(strip $(if $(value 3),$3,$(dc_shellc_default_shell_bin))))
	$(eval $0_dc_cmd := $(strip $(if $(value 4),$4,$(dc_shellc_default_cmd))))
	$(eval $0_extra_options := $(strip $(if $(value 5),$5,$(dc_shellc_default_extra_options))))

	$(call dc_invoke,
		$($0_dc_cmd),\
		$($0_extra_options),\
		$($0_service),\
		$($0_shell_bin) -c "$(call mb_normalizer,$($0_command))"\
	)
)
endef


define dc_build_args_linux_mac
--build-arg USER_ID=$(if $(value mb_dc_build_user_id),$(mb_dc_build_user_id),$(shell id -u)) \
--build-arg USER_NAME=$(if $(value mb_dc_build_user_name),$(mb_dc_build_user_name),$(shell whoami)) \
--build-arg GROUP_ID=$(if $(value mb_dc_build_group_id),$(mb_dc_build_group_id),$(shell id -g))
endef

# $1 = service names (can put multiple services separated by space)
# Returns true if any of the services is running, false otherwise
## NEEDS TO USE dc_invoke but also suppress all the stuff from mb_invoke
define dc_is_service_running
$(strip
	$(eval $0_service_names := $(strip $(subst ,|,$1)))
	$(if $(strip $(shell docker compose ps --services --filter "status=running" | grep -E '^\($(strip $0_service_names)\)$$')),
		$(mb_true)
	,
		$(mb_false)
	)
)
endef

## Chatgpt alternative implementation
## The grep is improved and it's pulling logic in that is already present in the dc_invoke function, so it will probably be simpler to just use dc_invoke.
## note that the grep has been improved but we need to be careful with $$
define __dc_is_service_running
$(strip
	$(eval $0_service_names := $(strip $(subst ,|,$1)))
	$(eval $0_bin := $(dc_bin))
	$(eval $0_bin_options := $(dc_bin_options))
	$(eval $0_all_dc_files := $(if $(value dc_files),$(addprefix --file ,$(dc_files))))
	$(eval $0_all_dc_env_files := $(if $(value dc_env_files),$(addprefix --env-file ,$(dc_env_files))))

	$(if $(strip $(shell $($0_bin) $($0_bin_options) $($0_all_dc_files) $($0_all_dc_env_files) \
		ps --services --filter "status=running" \
		| grep -E '^\($(strip $0_service_names)\)$$' \
	)),
		$(mb_true),
		$(mb_false)
	)
)
endef


# $1 = network name
# Returns $(mb_true) if exists, $(mb_false) if not
define docker_network_exists
$(strip
	$(eval $0_network := $(if $(value 1),$(strip $1),$(error ERROR: You must pass a command)))
	$(if $(shell docker network inspect $($0_network) >/dev/null 2>&1 && echo yes),
		$(mb_true),
		$(mb_false)
	)
)
endef


endif # __MB_MODULES_DOCKER_DOCKER_COMPOSE_FUNCTIONS__
#####################################################################################
ifndef __MB_MODULES_DOCKER_DOCKER_COMPOSE_TARGETS__
__MB_MODULES_DOCKER_DOCKER_COMPOSE_TARGETS__ := 1


## $1 - Target block
## $2 - verbs
define mb_pre_hook_adder
$(strip
	$(eval $0_target_start_block := $(if $(value 1),$1,$(call mb_printf_error, You must pass a target block)))
	$(eval $0_verbs := $(if $(value 2),$2,$(call mb_printf_error, You must pass verbs separated by space)))
	$(foreach $0_v,$($0_verbs),
		$(strip $(eval $($0_target_start_block)/$($0_v):: $($0_target_start_block)/pre/$($0_v); @:))
	)
)
endef

# Pre hooks for verbs
#$(foreach v,$(dc_pre_hook_verb_targets), \
#$(eval dc/$(v):: dc/pre/$(v) ; @:) \
#)

dc_pre_hook_verb_targets ?= up stop down build

$(call mb_pre_hook_adder,dc,$(dc_pre_hook_verb_targets))

dc/pre/%:: ; # Placeholder for pre targets

dc/pre/up:: mb/info-$$@

dc/up:: mb_info_msg := Starting containers
dc/up:: ## Start all containers
	$(eval dc_cmd_options_up ?= -d --wait)
	$(call dc_invoke,up,--remove-orphans)

dc/start: dc/up
dc/start: ## Start all containers (alias for dc/up)

dc/stop:: mb_info_msg := Stopping containers
dc/stop:: ## Stop all containers
	$(call dc_invoke,stop)

dc/pre/down:: mb/info-$$@

dc/down:: mb_info_msg := Stopping all containers and removing them
dc/down:: ## Stop and remove all containers
	$(call dc_invoke,down)

dc/logs: ## Show logs for all containers
	$(call dc_invoke,logs)

dc/logs-follow: ## Show logs for all containers (follow mode)
	$(call dc_invoke,logs,--follow --timestamps --tail 1000)

dc/status: ## Show status of all containers
	$(call dc_invoke,ps,--no-trunc)

dc/status-all: dc_cmd_options_ps := --all
dc/status-all: dc/status
dc/status-all: ## Show status (including stopped containers)

dc/restart: ## Restart all containers (calls dc/stop & dc/start)
dc/restart: dc/stop
dc/restart: dc/start

dc/build:: mb_info_msg := Building all containers
dc/build:: ## Build all containers
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
	$(eval dc_nuke_msg := Are you sure you want to remove all container of this project? [y/n])
	$(if $(call mb_user_confirm,$(dc_nuke_msg)),
		$(call dc_invoke,down,--remove-orphans --volumes --rmi all)
	,
		$(call mb_printf_info,Nuking process stopped)
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

dc/config: ## Show docker compose configuration
	$(call dc_invoke,config)

#dc/network-default-ensure: ## Ensure that the default network is created
#	$(if $(value dc_default_network_name),\
#		$(if $(call docker_network_exists,$(dc_default_network_name)),\
#			$(call mb_printf_info,Network $(dc_default_network_name) already exists)\
#		,\
#			$(call mb_printf_info,Network $(dc_default_network_name) not found$(mb_comma) creating...) \
#			$(call mb_invoke,docker network create $(dc_default_network_name))\
#		)\
#	,\
#		$(call mb_printf_warn,dc_default_network_name is empty$(mb_comma) skipping network check)\
#	)

#https://www.gnu.org/software/make/manual/html_node/Parallel-Disable.html
.NOTPARALLEL: dc/restart dc/rebuild

.PHONY: \
	dc/pre/up \
	dc/up \
	dc/start \
	dc/stop \
	dc/down \
	dc/logs \
	dc/logs-follow \
	dc/status \
	dc/status-all \
	dc/restart \
	dc/build \
	dc/rebuild \
	dc/remove \
	dc/nuke \
	dc/nuke-all \
	dc/invoke \
	dc/stats \
	dc/config \
	dc/network-default-ensure

endif # __MB_MODULES_DOCKER_DOCKER_COMPOSE_TARGETS__
