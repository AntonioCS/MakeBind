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
php_composer_bin ?= composer

define php_invoke
$(strip
	$(eval $0_parms_cmd := $(if $(value 1),$1,$(error ERROR: You must pass a commad)))
	$(eval $0_php_cmd := $(strip $(php_bin) $($0_parms_cmd)))
	$(if $(php_use_docker),
		$(call dc_shellc,$(php_dc_service),$($0_php_cmd),$(php_dc_default_shell))
		,
		$(call mb_invoke,$($0_php_cmd))
	)
)
endef


endif # __MB_MODULES_PHP__FUNCTIONS__


#define php_composer_invoke
#$(strip
#	$(if $(value 1),,$(error ERROR: You must pass a commad))
#	$(eval
#		php_composer_invoke_bin := $(if $(value php_composer_bin),$(php_composer_bin),composer)
#		php_composer_invoke_cmd := $(if $(value 1),$1)
#	)
#	$(strip $(php_invoke_bin) $(php_invoke_cmd)))
#)
#endef


ifndef __MB_MODULES_PHP_TARGETS__
__MB_MODULES_PHP_TARGETS__ := 1

php/inis: ## List all php ini files
	$(call php_invoke,--ini)

php/version: ## Show php version
	$(call php_invoke,--version)

php/dc/shell: ## Start a shell in the php docker compose container
	$(if $(value dc_invoke),,$(error ERROR: dc_invoke is not defined, please include docker module))
	$(call dc_invoke,exec,,$(php_dc_service),$(php_dc_default_shell))

endif # __MB_MODULES_PHP_TARGETS__

endif # __MB_MODULES_PHP__


