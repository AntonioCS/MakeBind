#####################################################################################
# Project: MakeBind
# File: modules/php/frameworks/symfony.mk
# Description: PHP Symfony module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_PHP_SYMFONY__
__MB_MODULES_PHP_SYMFONY__ := 1

mb_debug_php_sy ?= $(mb_debug)


php_sy_bin ?= bin/console
php_sy_logs_path ?= $(mb_project_path)/var/log
php_sy_env ?= dev            # dev|test|prod
php_sy_read_env_files ?= $(mb_true)  # If true, reads the APP_ENV from .env file
php_sy_read_env_files_default_file ?= $(mb_project_path)/.env # Will also try to read .env.$(php_sy_env)
## I can't use ?= as $(lastword $(MAKEFILE_LIST)) will change as soon as another file is included
php_sy_mod_path := $(if $(value php_sy_mod_path),$(php_sy_mod_path),$(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST))))))

# Build optional flags only when set
php_sy_console_env_flag := $(if $(php_sy_env),--env=$(php_sy_env))

php_sy_doctrine_enable ?= $(mb_true)# If true, loads doctrine submodule targets
php_sy_verbose ?= $(mb_false) # If true, adds -v flag to console commands

php_sy_logs_use_jq_in_tail ?= $(mb_false)

php_sy_helpers_path ?= $(php_sy_mod_path)/helpers
php_sy_jq_log_formatters ?= $(php_sy_helpers_path)/jq/log_format.jq

define php_sy_bin_console
$(strip
	$(eval
		$0_args  := $(strip $(if $(value 1),$1))
		$0_cmd :=#
		$0_flags :=#
	)
	$(if $($0_args),
		$(eval
			$0_cmd   := $(strip $(word 1,$($0_args)))
			$0_flags := $(strip $(wordlist 2,$(words $($0_args)),$($0_args)))
		)
	)

	$(call php_invoke, $(php_sy_bin) $($0_cmd) $(if $(php_sy_verbose),-vvv) $($0_flags))
)
endef

define php_sy_read_env_files
$(strip
	$(if $(wildcard $(php_sy_read_env_files_default_file)),
		$(eval
			include $(php_sy_read_env_files_default_file)
			-include $(php_sy_read_env_files_default_file).$(php_sy_env)
		)
	,
		$(call mb_printf_warn, File $(php_sy_read_env_files_default_file) not found$(mb_comma) skipping reading env files)
	)
)
endef


#########################################################################################################
#########################################################################################################

php/sy/logs/tail/all: ## tail all symfony logs files
	$(eval $@_logs_path := $(php_sy_logs_path)/*.log)
	$(if $(wildcard $($@_logs_path)),\
		$(eval $@_cmd := tail -f $($@_logs_path))\
		$(if $(php_sy_logs_use_jq_in_tail),\
			$(eval $@_cmd += | jq -C -f "$(php_sy_jq_log_formatters)")\
		)\
		$(call mb_printf_info, Tailing all Symfony logs)\
		$(call mb_invoke,$($@_cmd))\
	,\
		$(call mb_printf_error, No log files found in $(php_sy_logs_path). Ensure variable php_sy_logs_path is set to the correct path)\
	)

php/sy/cache/clear: ## Clear symfony cache
	$(call php_sy_bin_console,cache:clear $(php_sy_console_env_flag) --no-warmup)


#php/sy/doctrine/db/drop: ## Drop the database using doctrine
#	$(call php_sy_bin_console,doctrine:database:drop --force --if-exists)
#
#php/sy/doctrine/db/migrate: ## Run doctrine migrations
#	$(call php_sy_bin_console,doctrine:migrations:migrate --no-interaction)

#php/sy/make/%: ## Call the maker bundle with the given command
#	$(if $(value 1),\
#		$(call php_sy_bin_console,make:$*),\
#		$(call mb_printf_error, You must provide a command to make. Example: php/sy/make:controller)\
#	)
#WIP
#php/sy/controller/create/healthcheck: ## Add a health check controller
#	$(call php_sy_bin_console,make:controller HealthCheckController)

#$(call php_sy_bin_console,cache:clear)



php_sy_module_path := $(abspath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

ifeq ($(php_sy_doctrine_enable),$(mb_true))
include $(php_sy_module_path)/modules/doctrine.mk
endif

$(if $(php_sy_read_env_files),\
$(call mb_debug_print, Reading env files for Symfony module,$(mb_debug_php_sy)),\
$(call php_sy_read_env_files)\
)

endif # __MB_MODULES_PHP_SYMFONY__
