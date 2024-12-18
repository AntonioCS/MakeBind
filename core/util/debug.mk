#####################################################################################
# Project: MakeBind
# File: core/util/debug.mk
# Description: Useful debugging utilities
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_DEBUG_MK__
__MB_CORE_UTIL_DEBUG_MK__ := 1

mb_debug_to_file ?= $(mb_true)
mb_debug_file ?= $(mb_makebind_path)/mb_debug.log

## Note: Calling $(call mb_debug_print here will cause a segmentation fault as this is called in mb/debug/print
## which prints all the variables and this will cause an infinite loop
define mb_debug_helper
$(info $1 = $(value $1) -- $(origin $1))
endef

mb/debug/print:
	$(foreach V,$(sort $(.VARIABLES)), \
		$(if \
			$(filter-out environment% default automatic,$(origin $V)), \
			$(call mb_debug_helper,$V) \
		) \
	)

mb/debug/print-%:
	$(call mb_debug_helper,$*)


#$1 - msg
#$2 - debug trigger (defaults to mb_debug if not set)
define mb_debug_print
$(strip
	$(eval mb_debug_trigger := $(if $(value 2),$2,$(mb_debug)))
	$(if $(call mb_is_on,$(mb_debug_trigger)),
		$(if $(mb_debug_to_file),
			$(file >> $(mb_debug_file),$(shell $(mb_date_now)) DEBUG: $(strip $1))
			,
			$(warning DEBUG: $(strip $1))
		)
	)
)
endef
## This causes problems
#$(call mb_printf_warn,$(call mb_normalizer,$1),$(mb_printf_debug_format_specifier))\

#https://www.gnu.org/software/make/manual/html_node/Automatic-Variables.html
define mb_debug_automatic_variables_print
	$(info $$@ : $@)
	$(info $$% : $%)
	$(info $$< : $<)
	$(info $$? : $?)
	$(info $$^ : $^)
	$(info $$+ : $+)
	$(info $$| : $|)
	$(info $$* : $*)
	$(info $$(@D) : $(@D))
	$(info $$(@F) : $(@F))
	$(info $$(*D) : $(*D))
	$(info $$(*F) : $(*F))
	$(info $$(%D) : $(%D))
	$(info $$(%F) : $(%F))
	$(info $$(<D) : $(<D))
	$(info $$(<F) : $(<F))
	$(info $$(^D) : $(^D))
	$(info $$(^F) : $(^F))
	$(info $$(+D) : $(+D))
	$(info $$(+F) : $(+F))
	$(info $$(?D) : $(?D))
	$(info $$(?F) : $(?F))
endef

endif #__MB_CORE_UTIL_DEBUG_MK__

