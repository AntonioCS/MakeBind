#####################################################################################
# Project: MakeBind
# File: modules/php/psalm/psalm.mk
# Description: Psalm static analysis module for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_MODULES_PHP_PSALM__
__MB_MODULES_PHP_PSALM__ := 1

## Internal function to build psalm command arguments
## @returns Common arguments for psalm
define psalm_build_args
$(strip
	$(eval $0_args :=)
	$(eval
		$0_args += $(if $(wildcard $(psalm_config)),--config=$(psalm_config))
		$0_args += $(if $(psalm_threads),--threads=$(psalm_threads))
		$0_args += $(if $(value psalm_args),$(psalm_args))
		$0_args += $(if $(value psalm_files),$(psalm_files))
	)
	$(strip $($0_args))
)
endef

## Skip target definitions when loaded dynamically (e.g., during test discovery)
ifndef __MB_TEST_DISCOVERY__

## Verify php module is loaded (check once at module level)
$(if $(value php_invoke),,$(error psalm module requires php module - please add php module first))

php/psalm/analyse: ## Run Psalm analysis (psalm_files= for paths, psalm_args= for extra options)
	$(eval $@_cmd := $(psalm_bin) $(call psalm_build_args))
	$(if $(call mb_is_true,$(psalm_send_to_file)),\
		$(eval $@_cmd += > $(psalm_output_file) 2>&1 || true)\
		$(call mb_printf_info,Running psalm and sending output to $(psalm_output_file))\
	)
	$(call php_invoke,$($@_cmd))
	$(if $(call mb_is_true,$(psalm_send_to_file)),\
		$(call mb_printf_info,Results saved to $(psalm_output_file))\
	)

php/psalm/analyse/staged: ## Run Psalm on staged PHP files only
	$(call php_run_on_staged,$(psalm_bin))

endif # __MB_TEST_DISCOVERY__

endif # __MB_MODULES_PHP_PSALM__
