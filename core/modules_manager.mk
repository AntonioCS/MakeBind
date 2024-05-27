#####################################################################################
# Project: MakeBind
# File: main.mk
# Description: Main entry point for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_MODULES_MANAGER_MK__
__MB_CORE_MODULES_MANAGER_MK__ := 1

mb_modules := $(mb_empty)
mb_debug_modules ?= $(mb_debug)

define mb_load_modules
$(strip
	$(eval mb_load_modules_to_load := \
			$(addprefix $(mb_modules_path)/, $(filter-out /%, $(mb_project_modules)))\
			$(filter /%, $(mb_project_modules))\
	)
	$(if $(call mb_is_on,$(mb_debug_modules)),
    	$(info Loading modules: $(mb_load_modules_to_load))
    	$(info MakeBind modules: $(filter-out /%, $(mb_project_modules)))
    	$(info Project modules: $(filter /%, $(mb_project_modules)))
    )
    $(if $(mb_load_modules_to_load),
		$(eval include $(mb_load_modules_to_load))
	)
)
endef

endif # __MB_CORE_MODULES_MANAGER_MK__
