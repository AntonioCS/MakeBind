#####################################################################################
# Project: MakeBind
# File: main.mk
# Description: Module loader for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_MODULES_MANAGER_MK__
__MB_CORE_MODULES_MANAGER_MK__ := 1

mb_debug_modules ?= $(mb_debug)

define mb_load_modules
$(strip
	$(eval mb_load_modules_to_load := \
			$(addprefix $(mb_modules_path)/, $(filter-out /%, $(mb_project_modules)))\
			$(filter /%, $(mb_project_modules))\
	)
	$(call mb_debug_print, Modules path: $(mb_modules_path),$(mb_debug_modules))
	$(call mb_debug_print, Loading modules: $(mb_load_modules_to_load),$(mb_debug_modules))
	$(call mb_debug_print, MakeBind modules: $(filter-out /%, $(mb_project_modules)),$(mb_debug_modules))
	$(call mb_debug_print, Project modules: $(filter /%, $(mb_project_modules)),$(mb_debug_modules))

    $(if $(mb_load_modules_to_load),
		$(eval include $(mb_load_modules_to_load))
	)
)
endef

endif # __MB_CORE_MODULES_MANAGER_MK__
