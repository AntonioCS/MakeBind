#####################################################################################
# Project: MakeBind
# File: modules/docker/docker_compose.mk
# Description: All targets for docker compose
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_DOCKER_PHP__
__MB_MODULES_DOCKER_PHP__ := 1

dc_service_php ?= $(error ERROR: dc_service_php is not set, please set it to the php docker compose service name in your mb_config.mk file)
dc_php_default_shell ?= /bin/sh

dc/php/shell: ## Start a shell in the php container
	$(call dc_invoke,exec,,$(dc_service_php),$(dc_php_default_shell))

endif # __MB_MODULES_DOCKER_PHP__
