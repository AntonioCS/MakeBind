#####################################################################################
# Project: MakeBind
# File: modules/php/phpcs/phpcs.mk
# Description: PHP CodeSniffer module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_PHP_PHPCS__
__MB_MODULES_PHP_PHPCS__ := 1

## Internal function to build phpcs command arguments
## @returns Common arguments for phpcs/phpcbf
define phpcs_build_args
$(strip
	$(eval $0_args :=)
	$(eval
		$0_args += $(if $(wildcard $(phpcs_config_file)),--standard=$(phpcs_config_file))
		$0_args += $(if $(phpcs_parallel),--parallel=$(phpcs_parallel))
		$0_args += $(if $(phpcs_cache),--cache=$(phpcs_cache))
		$0_args += $(if $(phpcs_progress),-p)
		$0_args += $(if $(phpcs_report),--report=$(phpcs_report))
		$0_args += $(if $(value phpcs_args),$(phpcs_args))
		$0_args += $(if $(value phpcs_files),$(phpcs_files))
	)
	$(strip $($0_args))
)
endef

## Skip target definitions when loaded dynamically (e.g., during test discovery)
ifndef __MB_TEST_DISCOVERY__

## Verify php module is loaded (check once at module level)
$(if $(value php_invoke),,$(error phpcs module requires php module - please add php module first))

php/phpcs/check: ## Run PHP CodeSniffer (phpcs_files= for paths, phpcs_args= for extra options)
	$(eval $@_cmd := $(phpcs_bin) -s $(call phpcs_build_args))
	$(if $(call mb_is_true,$(phpcs_send_to_file)),\
		$(eval $@_cmd += > $(phpcs_output_file) 2>&1 || true)\
		$(call mb_printf_info,Running phpcs and sending output to $(phpcs_output_file))\
	)
	$(call php_invoke,$($@_cmd))
	$(if $(call mb_is_true,$(phpcs_send_to_file)),\
		$(call mb_printf_info,Results saved to $(phpcs_output_file))\
	)

php/phpcs/fix: ## Run PHP Code Beautifier to auto-fix (phpcs_files= for paths, phpcs_args= for extra options)
	$(eval $@_cmd := $(phpcbf_bin) $(call phpcs_build_args))
	$(call php_invoke,$($@_cmd))

php/phpcs/check/staged: ## Run PHP CodeSniffer on staged PHP files only
	$(call php_run_on_staged,$(phpcs_bin) -s)

php/phpcs/fix/staged: ## Run PHP Code Beautifier on staged PHP files only
	$(call php_run_on_staged,$(phpcbf_bin))

endif # __MB_TEST_DISCOVERY__

endif # __MB_MODULES_PHP_PHPCS__
