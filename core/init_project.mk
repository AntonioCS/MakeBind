#####################################################################################
# Project: MakeBind
# File: core/util/init_project.mk
# Description: This provides a target that will setup the project to work with MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_INIT_PROJECT_MK__
__MB_CORE_UTIL_INIT_PROJECT_MK__ := 1


## NOTE: can't have the mb_printf_info here because it will produce a shell command and those seem to be only
## be able to be executed inside a target
$(if $(call mb_user_confirm,Important config files are missing$(mb_comma) do you want to create them? [y/n]),\
	$(call mb_printf_info,Creating missing files)\
	$(shell mkdir -p $(mb_project_bindhub_path))\
	$(if $(call mb_not_exists,$(mb_project_mb_config_file)),\
		$(shell cp $(mb_makebind_templates_path)/mb_config.tpl.mk $(mb_project_mb_config_file))\
	)\
	$(if $(call mb_not_exists,$(mb_project_mb_project_mk_file)),\
	 	$(shell cp $(mb_makebind_templates_path)/mb_project.tpl.mk $(mb_project_mb_project_mk_file))\
	)\
	,\
	$(error ERROR: Please create the missing files before continuing)\
)

endif # __MB_CORE_UTIL_INIT_PROJECT_MK__
