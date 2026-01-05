#####################################################################################
# Project: MakeBind
# File: modules/php/php.mk
# Description: PHP module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_PHP__
__MB_MODULES_PHP__ := 1

ifndef __MB_MODULES_PHP__FUNCTIONS__
__MB_MODULES_PHP__FUNCTIONS__ := 1

# Check if something is listening on the xdebug port
define php_xdebug_check_is_listening
$(strip
$(shell nc -z -w "1" "$(php_xdebug_listener_host)" "$(php_xdebug_listener_port)" > /dev/null 2>&1 && echo $(mb_true))
)
endef


## Invoke a php command
## $1 string: Command to run
## $2 string: Flags to pass to the php command
define php_invoke
$(strip
	$(eval
		$0_php_cmd := $(if $(value 1),$(strip $1),$(call mb_printf_error, $0 - You must pass a commad))
		$0_php_cmd_flags := $(strip $(if $(value 2),$(strip $2)))
		$0_php_bin := $(strip $(php_bin))
	)
	$(if $(and $(call mb_is_on,$(php_xdebug_check_listener)),$(call mb_is_false,$(call php_xdebug_check_is_listening))),
		$(eval $0_php_cmd_flags += -d xdebug.mode=off)
	)
	$(eval $0_php_cmd_call := $(strip $($0_php_bin) $($0_php_cmd_flags) $($0_php_cmd)))
	$(if $(php_use_docker),
		$(if $(value php_dc_service),,$(call mb_printf_error,$0 - php_dc_service is not set$(mb_comma) please set it in your mb_config.mk or php_config.mk file))
		$(call dc_shellc,$(php_dc_service),$($0_php_cmd_call),$(php_dc_default_shell),$(php_invoke_dc_mode))
	,
		$(call mb_invoke,$($0_php_cmd_call))
	)
)
endef

## @function php_run_on_staged
## @description Run a PHP tool on staged PHP files only
## @arg 1: command (required) - Command to run (files will be appended)
## @example $(call php_run_on_staged,vendor/bin/phpcs -s)
## @example $(call php_run_on_staged,vendor/bin/phpstan analyse)
define php_run_on_staged
$(strip
	$(eval $0_arg1_cmd := $(if $(value 1),$(strip $1),$(call mb_printf_error,$0: command required)))
	$(eval $0_files := $(call mb_staged_files,php))
	$(if $($0_files),\
		$(call php_invoke,$($0_arg1_cmd) $($0_files)),\
		$(call mb_printf_info,No staged .php files))
)
endef

# $1 - Invoker name
# $2 - Docker check variable name
# $3 - Docker compose service name variable
### WIP - Find a way to generalize the above function. Many other modules are using similar function (if not identical)
define local_or_dc_invoker
$(strip
	$(eval

	)
)
endef

endif # __MB_MODULES_PHP__FUNCTIONS__

ifndef __MB_MODULES_PHP_TARGETS__
__MB_MODULES_PHP_TARGETS__ := 1

php/inis: ## List all php ini files
	$(call php_invoke,--ini)

php/version: ## Show php version
	$(call php_invoke,--version)


ifeq ($(php_use_docker),$(mb_true))

php/dc/check_service: # Internal helper
	$(if $(value php_dc_service),\
	,\
		$(call mb_printf_error, php_dc_service is not set, please set it to the php docker compose service name in your mb_config.mk or php_config.mk file)\
	)

php/dc/shell: php/dc/check_service
php/dc/shell: ## Start a shell in the php container
	$(call dc_invoke,$(php_dc_shell_mode),,$(php_dc_service),$(php_dc_default_shell))

php/dc/logs: php/dc/check_service
php/dc/logs: ## Show php container logs
	$(call dc_invoke,logs,-f $(php_dc_service))

endif

endif # __MB_MODULES_PHP_TARGETS__

endif # __MB_MODULES_PHP__


