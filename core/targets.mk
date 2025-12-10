#####################################################################################
# Project: MakeBind
# File: core/targets.mk
# Description: Targets for all core functionality
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_TARGETS_MK__
__MB_CORE_TARGETS_MK__ := 1

mb_debug_targets ?= $(mb_debug)
mb_targets_valid_targets_file ?= $(mb_makebind_tmp_path)/targets_valid_targets_list
mb_targets_desc_file ?= $(mb_makebind_tmp_path)/targets_descriptions_list
mb_targets_filtered_file ?= $(mb_makebind_tmp_path)/targets_filtered_list
mb_targets_list_awk_file ?= $(mb_core_util_bin_path)/target_listing/list.awk
mb_targets_filtering_awk_file ?= $(mb_core_util_bin_path)/target_listing/filtering.awk
mb_targets_all_valid_awk_file ?= $(mb_core_util_bin_path)/target_listing/all_valid.awk
mb_targets_all_desc_file ?= $(mb_core_util_bin_path)/target_listing/all_desc.grep


## https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
## This will list all the targets in the Makefile with their description
## Note: Having ifeq ($(mb_os_is_windows),1) was not working correctly
ifeq ($(if $(value OS),$(OS),not_windows),Windows_NT)
mb/targets-list:
	powershell -Command "Select-String -Path $(subst $(mb_space),$(mb_comma),$(mb_targets_list_get_files_all)) -Pattern '^[\$$\(\)/a-zA-Z0-9_-]+:.*?## .*$$' -ErrorAction SilentlyContinue |\
		ForEach-Object {\
			$$parts = $$_.Line -split '##';\
			$$formattedText = '{0,-40} {1}' -f $$parts[0].Trim().TrimEnd(':'), $$parts[1].Trim();\
			Write-Host $$formattedText -ForegroundColor Cyan;\
		}"
else
ifndef MB_TARGETS_SKIP

mb/targets-list: mb/targets-filtered
mb/targets-list: # List all targets with description
	@echo 'Available targets ($(if $(mb_targets_only_project),listing project targets only,listing all targets)):'
	awk -v TARGET_COLUMN_WIDTH="$(mb_target_column_width)" -v LEFT_PADDING="$(mb_target_left_padding)" -f "$(mb_targets_list_awk_file)" "$(mb_targets_filtered_file)"
	$(if $(call mb_is_off,$(mb_debug_targets)),
	   rm -f "$(mb_targets_valid_targets_file)" "$(mb_targets_desc_file)" "$(mb_targets_filtered_file)"
	)


## Do a diff to only get the valid targets that also have a description
mb/targets-filtered: mb/targets-all-valid .WAIT mb/targets-all-desc
mb/targets-filtered:
	awk -f "$(mb_targets_filtering_awk_file)" "$(mb_targets_valid_targets_file)" "$(mb_targets_desc_file)" > "$(mb_targets_filtered_file)"


## Note: Even with -q it still seems to process mb/target-list which is why MB_TARGETS_SKIP is needed
## Also, the $(shell) is needed because this forces make to run this during parsing phase and not during the execution phase which caused "Error 2"
## NOTE: This is also causing another issue. If we have a $(info) (or any of the other print function) they will trigger twice, with mb_debug=1 this will fill up the logs twice
### that is why I'm adding mb_debug=0 to the call
#-p prints out the database of variables and rules.
#-r disables built-in rules.
#-R disables built-in variables.
#-n dry run
## Cache all user-invokable targets
mb/targets-all-valid:
	$(shell MB_TARGETS_SKIP=1 mb_debug=0 $(MAKE) -pRrn | awk -f $(mb_targets_all_valid_awk_file) > "$(mb_targets_valid_targets_file)")

mb/targets-all-desc:
	$(call mb_targets_list_get_files)
	grep -h -E -f "$(mb_targets_all_desc_file)" $(mb_targets_list_get_files_all) > "$(mb_targets_desc_file)"

else
## To avoid infinite loop
mb/targets-list:
	;

endif # MB_TARGETS_SKIP
endif # Windows_NT


## Get the files to generate the list of make targets from
## 0_other_files_in_bind_hub_folder is important in case the user wants to include additional files
define mb_targets_list_get_files
$(strip
	$(eval $0_files_project := $(filter $(mb_project_file) $(mb_project_local_file),$(MAKEFILE_LIST)))
	$(eval $0_files_mb_modules := $(filter-out %/mod_info.mk %/mod_config.mk,$(filter $(mb_modules_path)/%,$(MAKEFILE_LIST))))
	$(eval $0_files_in_bindhub_modules_folder := $(filter $(mb_project_bindhub_modules_path)/%,$(MAKEFILE_LIST)))
	$(eval $0_files_project_modules := $(filter-out %/mod_info.mk %/mod_config.mk,$($0_files_in_bindhub_modules_folder)))

	$(eval $0_other_files_in_bind_hub_folder := $(filter-out \
		$($0_files_project_modules) \
		%/mod_info.mk %/mod_config.mk \
		%/mb_config.mk %/mb_modules.mk \
		%_config.mk %mb_project.mk \
		$(mb_project_bindhub_modules_path)/%, \
		$(filter $(mb_project_bindhub_path)/%,$(MAKEFILE_LIST))))

	$(call mb_debug_print,mb/targets-list ALL FILES: $(MAKEFILE_LIST),$(mb_debug_targets))
	$(call mb_debug_print,mb/targets-list Project files: $($0_files_project),$(mb_debug_targets))
	$(call mb_debug_print,mb/targets-list MB modules files: $($0_files_mb_modules),$(mb_debug_targets))
	$(call mb_debug_print,mb/targets-list MB bind-hub modules files: $($0_files_in_bindhub_modules_folder),$(mb_debug_targets))
	$(call mb_debug_print,mb/targets-list Project modules files: $($0_files_project_modules),$(mb_debug_targets))
	$(call mb_debug_print,mb/targets-list Other files files: $($0_other_files_in_bind_hub_folder),$(mb_debug_targets))


	$(if $(value mb_targets_only_project), \
		$(eval mb_targets_list_get_files_all := $(strip \
				$($0_files_project) \
        		$($0_files_project_modules) \
        		$($0_other_files_in_bind_hub_folder) \
        )) \
	, \
    	$(eval mb_targets_list_get_files_all := $(strip \
    		$(mb_core_path)/targets.mk \
    		$(mb_core_path)/modules_manager.mk \
    		$($0_files_project) \
    		$($0_files_mb_modules) \
    		$($0_files_project_modules) \
    		$($0_other_files_in_bind_hub_folder) \
    	)) \
	)

	$(eval mb_targets_list_get_files_all := $(strip \
		$(if $(mb_targets_only_project),
			$($0_files_project) \
			$($0_files_project_modules) \
			$($0_other_files_in_bind_hub_folder) \
		, \
			$(mb_core_path)/targets.mk \
			$(mb_core_path)/modules_manager.mk \
			$($0_files_project) \
			$($0_files_project_modules) \
			$($0_other_files_in_bind_hub_folder) \
			$($0_files_mb_modules) \
        )) \
	)

	$(call mb_debug_print,mb/targets-list all file: $(mb_targets_list_get_files_all),$(mb_debug_targets))
)
endef

## Note: The % is needed because make will not call the same target twice
## so it is important to create different targets that just all call the same thing
mb/info-%:
	$(call mb_printf_info,$(mb_info_msg))
mb/warn-%:
	$(call mb_printf_warn,$(mb_warn_msg))
mb/error-%:
	$(call mb_printf_error,$(mb_error_msg))

##########################################################################################################################################
##########################################################################################################################################
# This help target should be used in the following way
## make help-<target name/command/key>
# This will then trigger a search for the variable "help_msg_<target name/command>"
# If found, it is printed. Used the define keyword to create a multiline variable if you need to
# NOTE: You will have to use substitutes for $ ($(dollar)) and ( ($(lparen)) or make will try to evaluate the code
mb/help: ## Call help to get a list of available help keywords
	$(call mb_printf_info, Please use "make mb/help-<keyword>")
	$(call mb_printf_info, Available help keywords:)
	$(eval mb_help_all_variables := $(filter mb_help_msg_%,$(.VARIABLES)))
	$(foreach mb_hmsg,$(mb_help_all_variables),
		$(call mb_printf_info, - $(subst mb_help_msg_,,$(mb_hmsg)))
	)

## Note, might not display properly on windows
mb/help-%:
	$(if $(value mb_help_msg_$*),
		echo -e "$(mb_help_msg_$*)" | less -R
	,
		$(call mb_print_warn,Sorry no help found for $*)
	)

define mb_help_msg_help
 $(call mb_colour_mode,Bold,Help)

 Use target mb/help to list all available help keywords
 Then use mb/help-<keyword> to get help for that specific keyword

 How to create help topics
 1. Create a define block variable with the name mb_help_msg_<keyword>
 	Ex.: define mb_help_msg_$(call mb_colour_text,Green,<my_target>)
 		...
 		<endef>...
 2. Add the help message to the define block
 3. Call make mb/help-<keyword> to get the help message
endef

endif # __MB_CORE_TARGETS_MK__
