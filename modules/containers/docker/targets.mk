#####################################################################################
# Project: MakeBind
# File: modules/containers/docker/targets.mk
# Description: Docker module targets
# Author: AntonioCS
# License: MIT License
#####################################################################################

######################################################################################
# Targets - Container Operations
######################################################################################

docker/ps: ## List running containers
	$(call dk_invoke,ps)

docker/logs/%: ## Show logs for a specific container. Usage: docker/logs/<container>
	$(call dk_logs,$*)

docker/logs: # Wrapper for docker/logs/%
	$(call mb_printf_info,Usage: make docker/logs/<container>)

docker/logs-follow/%: ## Follow logs for a specific container. Usage: docker/logs-follow/<container>
	$(call dk_logs,$*,--follow --tail=200)

docker/logs-follow: # Wrapper for docker/logs-follow/%
	$(call mb_printf_info,Usage: make docker/logs-follow/<container>)

docker/exec/%: ## Execute bash in container. Usage: docker/exec/<container>
	$(call dk_shellc,$*,bash,/bin/bash)

docker/exec: # Wrapper for docker/exec/%
	$(call mb_printf_info,Usage: make docker/exec/<container>)

docker/sh/%: ## Execute sh in container. Usage: docker/sh/<container>
	$(call dk_shellc,$*,sh,/bin/sh)

docker/sh: # Wrapper for docker/sh/%
	$(call mb_printf_info,Usage: make docker/sh/<container>)

docker/stop/%: ## Stop a container. Usage: docker/stop/<container>
	$(call dk_invoke,stop,,$*)

docker/stop: # Wrapper for docker/stop/%
	$(call mb_printf_info,Usage: make docker/stop/<container>)

docker/restart/%: ## Restart a container. Usage: docker/restart/<container>
	$(call dk_invoke,restart,,$*)

docker/restart: # Wrapper for docker/restart/%
	$(call mb_printf_info,Usage: make docker/restart/<container>)

######################################################################################
# Targets - Cleanup Operations
######################################################################################

docker/clean-containers: ## Remove all stopped containers
	$(if $(call mb_user_confirm,Remove all stopped containers? [y/n]),\
		$(call dk_invoke,container prune,--force),\
		$(call mb_printf_info,Container cleanup cancelled)\
	)

docker/clean-images: ## Remove dangling/unused images
	$(if $(call mb_user_confirm,Remove dangling images? [y/n]),\
		$(call dk_invoke,image prune,--force),\
		$(call mb_printf_info,Image cleanup cancelled)\
	)

docker/clean-all: ## Remove all unused containers, images, volumes, and networks
	$(eval $@_msg := Remove all unused Docker resources (containers$(mb_comma) images$(mb_comma) volumes$(mb_comma) networks)? [y/n])
	$(if $(call mb_user_confirm,$($@_msg)),\
		$(call mb_printf_info,Cleaning all unused Docker resources...) $(call dk_invoke,system prune,--volumes --force),\
		$(call mb_printf_info,Cleanup cancelled)\
	)

######################################################################################
# Targets - Network Operations
######################################################################################

## docker/network/create: Create a docker network (fails if exists)
## Usage: docker/network/create/<name>[@driver][@subnet][@gateway]
## Parameters (use @ as separator):
##   name    - Network name (required)
##   driver  - Network driver: bridge, overlay, host, none (default: bridge)
##   subnet  - Network subnet in CIDR notation (optional, e.g., 172.20.0.0/16)
##   gateway - Network gateway IP (optional, e.g., 172.20.0.1)
## Configuration variables (used if target params not provided):
##   docker_network_<name>_driver  - Network driver
##   docker_network_<name>_subnet  - Network subnet
##   docker_network_<name>_gateway - Network gateway
## To suppress errors when network exists, set: docker_network_ignore_errors=true
## Examples:
##   make docker/network/create/myapp
##   make docker/network/create/myapp@overlay
##   make docker/network/create/myapp@bridge@172.20.0.0/16
##   make docker/network/create/myapp@bridge@172.20.0.0/16@172.20.0.1
docker/network/create/%: ## Create a network (fails if exists). Usage: docker/network/create/<name>[@driver][@subnet][@gateway]
	$(call dk_network_parse_params,$*)
	$(if $(call mb_is_true,$(call dk_network_exists,$(dk_network_parse_params_name))),\
		$(if $(call mb_is_true,$(docker_network_ignore_errors)),\
			$(call mb_printf_info,Network $(dk_network_parse_params_name) already exists (skipped))\
		,\
			$(call mb_printf_error,Network $(dk_network_parse_params_name) already exists. Use docker/network/ensure instead)\
		),\
		$(call mb_printf_info,Creating network $(dk_network_parse_params_name))\
		$(call dk_network_create,$(dk_network_parse_params_name),$(dk_network_parse_params_driver),$(dk_network_parse_params_subnet),$(dk_network_parse_params_gateway))\
	)

docker/network/create: # Wrapper for docker/network/create/%
	$(call mb_printf_info,Usage: make docker/network/create/<name>[@driver][@subnet][@gateway])

## docker/network/ensure: Ensure a docker network exists (create if missing)
## Usage: docker/network/ensure/<name>[@driver][@subnet][@gateway]
## Parameters and configuration are identical to docker/network/create
## This target is idempotent - safe to call multiple times
## Examples:
##   make docker/network/ensure/myapp
##   make docker/network/ensure/myapp@overlay@172.20.0.0/16
docker/network/ensure/%: ## Ensure network exists (create if missing). Usage: docker/network/ensure/<name>[@driver][@subnet][@gateway]
	$(call dk_network_parse_params,$*)
	$(if $(call mb_is_true,$(call dk_network_exists,$(dk_network_parse_params_name))),\
		$(call mb_printf_info,Network $(dk_network_parse_params_name) already exists),\
		$(call mb_printf_info,Creating network $(dk_network_parse_params_name))\
		$(call dk_network_create,$(dk_network_parse_params_name),$(dk_network_parse_params_driver),$(dk_network_parse_params_subnet),$(dk_network_parse_params_gateway))\
	)

docker/network/ensure: # Wrapper for docker/network/ensure/%
	$(call mb_printf_info,Usage: make docker/network/ensure/<name>[@driver][@subnet][@gateway])

## docker/network/remove: Remove a docker network (fails if not exists)
## Usage: docker/network/remove/<name>
## To suppress errors when network doesn't exist, set: docker_network_ignore_errors=true
## Examples:
##   make docker/network/remove/myapp
docker/network/remove/%: ## Remove a network (fails if not exists). Usage: docker/network/remove/<name>
	$(if $(call mb_is_false,$(call dk_network_exists,$*)),\
		$(if $(call mb_is_true,$(docker_network_ignore_errors)),\
			$(call mb_printf_info,Network $* does not exist (skipped)),\
			$(call mb_printf_error,Network $* does not exist)\
		),\
		$(call mb_printf_info,Removing network $*)\
		$(call dk_network_remove,$*)\
	)

docker/network/remove: # Wrapper for docker/network/remove/%
	$(call mb_printf_info,Usage: make docker/network/remove/<name>)
