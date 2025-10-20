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
## NOTE: Windows paths need to be escaped even when SHELL is set to pwsh
mb_init_create_folder_cmd := $(call mb_powershell,mkdir $(subst /,\\,$(mb_project_bindhub_path)))
mb_init_cp_config_mk_cmd := $(call mb_powershell,copy $(subst /,\\,$(mb_makebind_templates_path)\\mb_config.tpl.mk) $(subst /,\\,$(mb_project_mb_config_file)))
mb_init_cp_project_mk_cmd := $(call mb_powershell,copy $(subst /,\\,$(mb_makebind_templates_path)\\mb_project.tpl.mk) $(subst /,\\,$(mb_project_mb_project_mk_file)))

else
mb_init_create_folder_cmd := mkdir -p $(mb_project_bindhub_path);
mb_init_create_configs_folder_cmd := mkdir -p $(mb_project_bindhub_configs);
mb_init_cp_config_mk_cmd := cp $(mb_makebind_templates_path)/mb_config.tpl.mk $(mb_project_mb_config_file);
mb_init_cp_project_mk_cmd := cp $(mb_makebind_templates_path)/mb_project.tpl.mk $(mb_project_mb_project_mk_file);
endif

$(if $(call mb_not_exists,$(mb_project_bindhub_path)),\
$(call mb_debug_print,Creating bindhub path: $(mb_project_bindhub_path),$(mb_debug_init))\
$(shell $(mb_init_create_folder_cmd) && $(mb_init_create_configs_folder_cmd))\
)
$(if $(call mb_not_exists,$(mb_project_mb_project_mk_file)),\
$(call mb_debug_print, Copying mb_project.tpl.mk to $(mb_project_mb_project_mk_file),$(mb_debug_init))\
$(shell $(mb_init_cp_project_mk_cmd))\
)
$(if $(call mb_not_exists,$(mb_project_mb_config_file)),\
$(call mb_debug_print, Copying mb_config.tpl.mk to $(mb_project_mb_config_file),$(mb_debug_init))\
$(shell $(mb_init_cp_config_mk_cmd))\
)

endif # __MB_CORE_INIT_PROJECT_MK__
