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
mb_modules_db_all_modules :=# Empty
mb_modules_loaded :=# Empty

## Find all info files
## $1: Path to search
define mb_modules_find_info
$(strip
$(eval $0_prm_path := $(strip $1))
$(shell find $($0_prm_path) -type f -name "info.mk")
)
endef
## NOTE: May not work if there are spaces in the paths of the modules
define mb_modules_build_db
$(strip
	$(eval $0_all_modules_info_path := $(call mb_modules_find_info,$(mb_modules_path)/))
	$(if $(wildcard $(mb_project_bindhub_modules_path)/*),
		$(eval $0_all_modules_info_path += $(call mb_modules_find_info, $(mb_project_bindhub_modules_path)/))
	)

	$(foreach $0_module_info_path, $($0_all_modules_info_path),
		$(eval
			undefine mb_module_name
			undefine mb_module_version
			undefine mb_module_description
			undefine mb_module_author
			undefine mb_module_license
			undefine mb_module_depends
		)

		$(eval include $($0_module_info_path))

		$(eval
			mb_modules_db_all_modules += $(strip $(mb_module_name))
			mb_modules_db_version_$(mb_module_name) := $(strip $(mb_module_version))
			mb_modules_db_description_$(mb_module_name) := $(mb_module_description)
			mb_modules_db_depends_$(mb_module_name) := $(if $(value mb_module_depends),$(mb_module_depends))
			mb_modules_db_author_$(mb_module_name) := $(if $(value mb_module_author),$(mb_module_author))
			mb_modules_db_license_$(mb_module_name) := $(if $(value mb_module_license),$(mb_module_license))
			mb_modules_db_path_$(mb_module_name) := $(realpath $(dir $($0_module_info_path)))/$(mb_module_name).mk
        )
        $(if $(wildcard $(mb_modules_db_path_$(mb_module_name))),,
			$(error ERROR: Module $(mb_module_name) is missing the implementation file $(mb_modules_db_path_$(mb_module_name)))
		)
	)
)
endef


define mb_load_modules

endef

define mb_load_modules_old
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

mb/modules/list: ## List all modules available
	$(info Modules available:)
	$(foreach $@_mod,$(mb_modules_db_all_modules),
		$(info - $($@_mod) ($(mb_modules_db_version_$($@_mod))): $(mb_modules_db_description_$($@_mod)))
	)

mb/modules/add/%: ## Add a module. Pass <module_name>


mb/modules/remove/%: ## Remove a module. Pass <module_name>

mb/modules/create/%: ## Create a new module. Pass <module_name>

endif # __MB_CORE_MODULES_MANAGER_MK__
