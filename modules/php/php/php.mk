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

php_use_docker ?= $(if $(value dc_invoke),$(mb_true),$(mb_false))
php_dc_service ?= $(error ERROR: php_dc_service_php is not set, please set it to the php docker compose service name in your mb_config.mk file)
php_dc_default_shell ?= $(if $(value dc_default_shell_bin),$(dc_default_shell_bin))


php_bin ?= /usr/local/bin/php

php_xdebug_check_listener := $(mb_on)
php_xdebug_listener_host ?= 127.0.0.1
php_xdebug_listener_port ?= 9003

# Check if something is listening on the xdebug port
define php_xdebug_is_listener_on
$(strip
$(shell nc -z -w "1" "$(php_xdebug_listener_host)" "$(php_xdebug_listener_port)" > /dev/null 2>&1 && echo $(mb_true))
)
endef

## Maybe not necessary as we can just use dc_shellc_default_cmd and set that to run as that is what php_invoke calls when using dc_shellc
php_invoke_dc_mode ?= exec # Can be exec or run, defaults to exec

## Invoke a php command
## $1 string: Command to run
## $2 string: Flags to pass to the php command
define php_invoke
$(strip
	$(eval $0_php_cmd := $(if $(value 1),$(strip $1),$(error ERROR: $0 - You must pass a commad)))
	$(eval $0_php_bin := $(strip $(php_bin)))
	$(eval $0_php_cmd_flags := $(if $(value 2),$(strip $2),$(mb_empty)))
	$(if $(and $(call mb_is_on,$(php_xdebug_check_listener)),$(call mb_is_false,$(call php_xdebug_is_listener_on))),
		$(eval $0_php_cmd_flags += -d xdebug.mode=off)
	)
	$(eval $0_php_cmd_call := $(strip $($0_php_bin) $($0_php_cmd_flags) $($0_php_cmd)))
	$(if $(php_use_docker),
		$(call dc_shellc,$(php_dc_service),$($0_php_cmd_call),$(php_dc_default_shell),$(php_invoke_dc_mode))
	,
		$(call mb_invoke,$($0_php_cmd_call))
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

php_dc_shell_mode ?= $(php_invoke_dc_mode)# Can be exec or run, defaults to exec

php/dc/shell: ## Start a shell in the php container
	$(call dc_invoke,$(php_dc_shell_mode),,$(php_dc_service),$(php_dc_default_shell))

endif

phpstan_bin ?= vendor/bin/phpstan
phpstan_config_file ?= phpstan.neon
phpstan_send_to_file ?= $(mb_true)
phpstan_output_file ?= phpstan.output

php/phpstan: mb/info-$$@ := Running PHPStan
php/phpstan: ## Run PHPStan to phpstan.output
	$(call php_invoke,$(phpstan_bin) analyse \
		--configuration=$(phpstan_config_file) \
		$(if $(phpstan_send_to_file),--error-format=github > $(phpstan_output_file)) \
		 || true \
	)


psalm_bin ?= vendor/bin/psalm
psalm_send_to_file ?= $(mb_true)
psalm_output_file ?= psalm.output
psalm_flags ?= -m --output-format=compact

php/psalm: ## Run Psalm to psalm.output
	$(call php_invoke,$(psalm_bin) $(psalm_flags) \
		$(if $(psalm_send_to_file),> $(psalm_output_file)) \
		|| true \
	)

php/phpcs: ## Run PHP CodeSniffer to check code style issues
	$(call php_invoke,vendor/bin/phpcs -s)

php/phpcbf: ## Run PHP CodeSniffer to fix code style issues
	$(call php_invoke,vendor/bin/phpcbf)


.PHONY: php/inis php/version php/dc/shell

endif # __MB_MODULES_PHP_TARGETS__

endif # __MB_MODULES_PHP__


