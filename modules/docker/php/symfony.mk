#####################################################################################
# Project: MakeBind
# File: modules/docker/php/composer.mk
# Description: Docker php symfony module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_DOCKER_PHP_SYMFONY__
__MB_MODULES_DOCKER_PHP_SYMFONY__ := 1

include $(mb_modules_path)/docker/php.mk

dc_php_symfony_logs_file ?= /var/html/www/dev.log


dc/php/sy/logs-cat: ## cat symfony logs file
	$(call dc_shellc,$(dc_service_php),cat $(php_logs_file))

dc/php/sy/logs-tail: ## tail -f symfony logs file
	$(call dc_shellc,$(dc_service_php),tail -f $(php_logs_file))


endif # __MB_MODULES_DOCKER_PHP_SYMFONY__
