#####################################################################################
# Project: MakeBind
# File: core/util/init_project.mk
# Description: This provides a target that will setup the project to work with MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_INIT_PROJECT_MK__
__MB_CORE_UTIL_INIT_PROJECT_MK__ := 1

mb_debug_init ?= $(mb_debug)

##NOTE: there are still error when calling mb_printf in some situations
### $(call mb_printf_info,Creating missing files)
ifeq ($(OS),Windows_NT)
## TODO: Remove Windows support - tracked in Trello ticket "Remove Windows support from MakeBind"
## NOTE: Windows paths need to be escaped even when SHELL is set to pwsh
mb_init_create_folder_cmd := $(call mb_powershell,mkdir $(subst /,\\,$(mb_project_bindhub_path)))
mb_init_cp_config_mk_cmd := $(call mb_powershell,copy $(subst /,\\,$(mb_makebind_templates_path)\\config.tpl.mk) $(subst /,\\,$(mb_project_config_file)))
mb_init_cp_project_mk_cmd := $(call mb_powershell,copy $(subst /,\\,$(mb_makebind_templates_path)\\project.tpl.mk) $(subst /,\\,$(mb_project_file)))

else
mb_init_create_folder_cmd := mkdir -p $(mb_project_bindhub_path)
mb_init_create_internal_folder_cmd := mkdir -p $(mb_project_bindhub_internal_path);
mb_init_cp_config_mk_cmd := cp $(mb_makebind_templates_path)/config.tpl.mk $(mb_project_config_file);
mb_init_cp_project_mk_cmd := cp $(mb_makebind_templates_path)/project.tpl.mk $(mb_project_file);
mb_init_cp_readme_cmd := cp $(mb_makebind_templates_path)/README.bind-hub.md $(mb_project_bindhub_path)/README.md;
endif

$(if $(call mb_not_exists,$(mb_project_bindhub_path)),\
$(call mb_debug_print,Creating bindhub path: $(mb_project_bindhub_path),$(mb_debug_init))\
$(shell $(mb_init_create_folder_cmd) && $(mb_init_create_internal_folder_cmd))\
)
$(if $(call mb_not_exists,$(mb_project_file)),\
$(call mb_debug_print, Copying project.tpl.mk to $(mb_project_file),$(mb_debug_init))\
$(shell $(mb_init_cp_project_mk_cmd))\
)
$(if $(call mb_not_exists,$(mb_project_config_file)),\
$(call mb_debug_print, Copying config.tpl.mk to $(mb_project_config_file),$(mb_debug_init))\
$(shell $(mb_init_cp_config_mk_cmd))\
)
$(if $(call mb_not_exists,$(mb_project_bindhub_path)/README.md),\
$(call mb_debug_print, Copying README.bind-hub.md to $(mb_project_bindhub_path)/README.md,$(mb_debug_init))\
$(shell $(mb_init_cp_readme_cmd))\
)

endif # __MB_CORE_INIT_PROJECT_MK__
