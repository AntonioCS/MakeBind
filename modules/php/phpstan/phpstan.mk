#####################################################################################
# Project: MakeBind
# File: modules/php/phpstan/phpstan.mk
# Description: PHPStan static analysis module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_PHP_PHPSTAN__
__MB_MODULES_PHP_PHPSTAN__ := 1

## Internal function to build phpstan command arguments
## @returns Common arguments for phpstan
define phpstan_build_args
$(strip
	$(eval $0_args :=)
	$(eval
		$0_args += $(if $(wildcard $(phpstan_config)),--configuration=$(phpstan_config))
		$0_args += $(if $(phpstan_level),--level=$(phpstan_level))
		$0_args += $(if $(phpstan_memory_limit),--memory-limit=$(phpstan_memory_limit))
		$0_args += $(if $(value phpstan_args),$(phpstan_args))
		$0_args += $(if $(value phpstan_files),$(phpstan_files))
	)
	$(strip $($0_args))
)
endef

## Skip target definitions when loaded dynamically (e.g., during test discovery)
ifndef __MB_TEST_DISCOVERY__

## Verify php module is loaded (check once at module level)
$(if $(value php_invoke),,$(error phpstan module requires php module - please add php module first))

php/phpstan/analyse: ## Run PHPStan analysis (phpstan_files= for paths, phpstan_args= for extra options)
	$(eval $@_cmd := $(phpstan_bin) analyse $(call phpstan_build_args))
	$(if $(call mb_is_true,$(phpstan_send_to_file)),\
		$(eval $@_cmd += > $(phpstan_output_file) 2>&1 || true)\
		$(call mb_printf_info,Running phpstan and sending output to $(phpstan_output_file))\
	)
	$(call php_invoke,$($@_cmd))
	$(if $(call mb_is_true,$(phpstan_send_to_file)),\
		$(call mb_printf_info,Results saved to $(phpstan_output_file))\
	)

php/phpstan/analyse/staged: ## Run PHPStan on staged PHP files only
	$(call php_run_on_staged,$(phpstan_bin) analyse)

endif # __MB_TEST_DISCOVERY__

endif # __MB_MODULES_PHP_PHPSTAN__
