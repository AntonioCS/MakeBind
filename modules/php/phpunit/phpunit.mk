#####################################################################################
# Project: MakeBind
# File: modules/php/phpunit.mk
# Description: PHPUnit module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_PHP_PHPUNIT__
__MB_MODULES_PHP_PHPUNIT__ := 1

phpunit_bin ?= vendor/bin/phpunit

php/phpunit: ## Run phpunit tests (user filter to filter for specific tests, args to pass extra arguments)
	$(if $(value php_invoke),,$(error ERROR: php_invoke is not defined, please include php.mk module))
	$(eval $@_args := $(if $(value args),$(strip $(args))))
	$(eval $@_filter := $(if $(value filter),'$(filter)'))
	$(eval $@_verbose :=  $(if $(and $(value verbose),$(findstring 1,$(verbose))),-vvv))
	$(call php_invoke, $(phpunit_bin) $($@_args) $($@_filter) $($@_verbose))

endif # __MB_MODULES_PHP_PHPUNIT__
