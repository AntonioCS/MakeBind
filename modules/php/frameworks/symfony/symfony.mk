#####################################################################################
# Project: MakeBind
# File: modules/php/frameworks/symfony.mk
# Description: PHP Symfony module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_PHP_SYMFONY__
__MB_MODULES_PHP_SYMFONY__ := 1


## $1: Command to run with flags
## Internally it will be split into command and flags
define php_sy_bin_console
$(strip
	$(eval
		$0_args := $(strip $(if $(value 1),$1))
		$0_cmd :=#
		$0_flags :=#
	)
	$(if $($0_args),
		$(eval
			$0_cmd   := $(strip $(word 1,$($0_args)))
			$0_flags := $(strip $(wordlist 2,$(words $($0_args)),$($0_args)))
		)
	)
	$(call php_invoke,$(php_sy_bin) $($0_cmd) $(php_sys_bin_console_options) $(if $(php_sy_verbose),-vvv) $($0_flags))
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
	$(call php_sy_bin_console,cache:clear --no-warmup)


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


ifeq ($(php_sy_read_env_files),$(mb_true))

$(call mb_debug_print, Reading env files for Symfony module,$(mb_debug_php_sy))

include $(php_sy_read_env_files_default_file)
-include $(php_sy_read_env_files_default_file).$(php_sy_env)
-include $(php_sy_read_env_files_default_file).local


endif # $(php_sy_read_env_files)

endif # __MB_MODULES_PHP_SYMFONY__
