#####################################################################################
# Project: MakeBind
# File: modules/php/phpunit.mk
# Description: PHPUnit module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_PHP_PHPUNIT__
__MB_MODULES_PHP_PHPUNIT__ := 1

php/phpunit:: ## Run phpunit tests (user filter to filter for specific tests, args to pass extra arguments)
	$(if $(value php_invoke),,$(error ERROR: php_invoke is not defined, please include php.mk module))
	$(eval $@_args := $(if $(value args),$(strip $(args))))
	$(eval $@_filter := $(if $(value filter),--filter '$(filter)'))
	$(eval $@_group := $(if $(value group),--group $(group)))
	$(eval $@_verbose :=  $(if $(and $(value verbose),$(findstring 1,$(verbose))),-vvv))

	$(call php_invoke, $(phpunit_bin) \
		$($@_args) \
		$($@_filter) \
		$($@_verbose) \
		$($@_group) \
		$(if $(call mb_is_true,$(phpunit_stop_on_failure)),--stop-on-failure,) \
		$(if $(call mb_is_true,$(phpunit_stop_on_error)),--stop-on-error,) \
		, \
		$(if $(call mb_is_true,$(phpunit_remove_max_execution_time)),-d max_execution_time=0,) \
	)

.PHONY: php/phpunit

endif # __MB_MODULES_PHP_PHPUNIT__
