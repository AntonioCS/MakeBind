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
	$(call php_invoke, bin/console $($0_param_cmd))
)
endef

php_sy_logs_path ?= $(mb_project_path)/var/log

php/sy/logs/tail/all: ## tail all symfony logs files
	$(if $(wildcard $(php_sy_logs_path)/*.log),\
		$(call mb_printf_info, Tailing all Symfony logs)\
		$(call mb_invoke,tail -f $(php_sy_logs_path)/*.log)\
	,\
		$(call mb_printf_error, No log files found in $(php_sy_logs_path). Ensure variable php_sy_logs_path is set to the correct path)\
	)


php/sy/doctrine/db/create: ## Create the database using doctrine
	$(call php_sy_bin_console,doctrine:database:create --if-not-exists)

php/sy/doctrine/db/drop: ## Drop the database using doctrine
	$(call php_sy_bin_console,doctrine:database:drop --force --if-exists)

php/sy/doctrine/db/migrate: ## Run doctrine migrations
	$(call php_sy_bin_console,doctrine:migrations:migrate --no-interaction)

#php/sy/make/%: ## Call the maker bundle with the given command
#	$(if $(value 1),\
#		$(call php_sy_bin_console,make:$*),\
#		$(call mb_printf_error, You must provide a command to make. Example: php/sy/make:controller)\
#	)
#WIP
#php/sy/controller/create/healthcheck: ## Add a health check controller
#	$(call php_sy_bin_console,make:controller HealthCheckController)

#$(call php_sy_bin_console,cache:clear)

.PHONY: php/sy/logs/tail/all php/sy/doctrine/db/create php/sy/doctrine/db/drop php/sy/doctrine/db/migrate

endif # __MB_MODULES_DOCKER_PHP_SYMFONY__
