#####################################################################################
# Project: MakeBind
# File: core/util/targets.mk
# Description: Useful targets
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_TARGETS_MK__
__MB_CORE_UTIL_TARGETS_MK__ := 1

## Note: core/functions.mk should have already been loaded

###### https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
## This will list all the targets in the Makefile with their description
mb/targets-list:
	grep -h -E '^[$$()/a-zA-Z0-9_-]+:.*?## .*$$' $(filter-out %config.mk, $(MAKEFILE_LIST)) | \
	awk 'BEGIN {FS = ":.*?## "} \
		{if (NF > 1) printf "\033[36m%-40s\033[0m %s\n", $$1, $$2} \
		END {if (NR == 0) print "\033[31mNo targets found\033[0m"}' || true


## Note: The % is needed because make will not call the same target twice
## so it is important to create different targets that just all call the same thing

mb/info-%:
	$(call mb_printf_info,$(mb_info_msg))

mb/warn-%:
	$(call mb_printf_warn,$(mb_warn_msg))

mb/error-%:
	$(call mb_printf_error,$(mb_error_msg))

endif # __MB_CORE_UTIL_TARGETS_MK__
