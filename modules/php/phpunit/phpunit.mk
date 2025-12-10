#####################################################################################
# Project: MakeBind
# File: modules/php/phpunit.mk
# Description: PHPUnit module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_PHP_PHPUNIT__
__MB_MODULES_PHP_PHPUNIT__ := 1

phpunit_util_check_var = $(strip $(if $(and $(value $1),$(call mb_is_on,$($1))),$2))
#	$(eval $@_filter := $(strip $(if $(value filter),--filter '$(filter)')))
#	$(eval $@_suite := $(strip $(if $(value suite),--testsuite $(suite))))
#	$(eval $@_group := $(strip $(if $(value group),--group $(group))))
#	$(eval $@_testdox := $(call util_check_var,testdox,--testdox))
#	$(eval $@_display_skipped := $(call util_check_var,display_skipped,--display-skipped))
#	$(eval $@_args := $(strip $(if $(value args),$(strip $(args)))))

php/phpunit:: ## Run phpunit tests (user filter to filter for specific tests, args to pass extra arguments)
	$(if $(value php_invoke),,$(call mb_printf_error,$@ - php_invoke is not defined, please include php.mk module))
	$(eval
		$@_all_args += $(strip $(if $(value filter),--filter '$(filter)'))
		$@_all_args += $(strip $(if $(value suite),--testsuite $(suite)))
		$@_all_args += $(strip $(if $(value group),--group $(group)))
		$@_all_args += $(call phpunit_util_check_var,testdox,--testdox)
		$@_all_args += $(call phpunit_util_check_var,display_skipped,--display-skipped)
		$@_all_args += $(strip $(if $(value args),$(args)))
		$@_all_args += $(strip $(if $(call mb_is_true,$(phpunit_stop_on_failure)),--stop-on-failure))
		$@_all_args += $(strip $(if $(call mb_is_true,$(phpunit_stop_on_error)),--stop-on-error))
## phpunit v10+ does not have a verbose flag or any verbosity levels, so be careful using this - https://github.com/sebastianbergmann/phpunit/issues/5647
		$@_all_args += $(call phpunit_util_check_var,verbose,-vvv)
	)

	$(eval $@_has_max_execution_time_off := $(strip $(if $(call mb_is_true,$(phpunit_remove_max_execution_time)),-d max_execution_time=0,)))
	$(call php_invoke, $(phpunit_bin) $($@_all_args),$($@_has_max_execution_time_off))



endif # __MB_MODULES_PHP_PHPUNIT__
