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
