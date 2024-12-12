#####################################################################################
# Project: MakeBind
# File: modules/php/frameworks/symfony.mk
# Description: PHP Symfony module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_DOCKER_PHP_SYMFONY__
__MB_MODULES_DOCKER_PHP_SYMFONY__ := 1

define php_sy_bin_console
$(strip
	$(eval $0_param_cmd := $(strip $(if $(value 1),$1)))
	$(call php_invoke,bin/console $($0_param_cmd))
)
endef

php_sy_logs_path ?= $(mb_project_path)/var/log

php/sy/logs/tail/all: ## tail all symfony logs files
	tail -f $(php_sy_logs_path)/*.log


endif # __MB_MODULES_DOCKER_PHP_SYMFONY__
