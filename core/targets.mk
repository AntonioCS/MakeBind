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
mb_targets_valid ?= $(mb_makebind_tmp_path)/mk_targets_valid
mb_targets_desc ?= $(mb_makebind_tmp_path)/mk_targets_desc
mb_targets_filtered ?= $(mb_makebind_tmp_path)/mk_targets_filtered

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
mb/targets-list:
	awk 'BEGIN {FS = ":.*## "}; { \
		target = $$1; \
		description = $$2; \
		placeholder = "<param>"; \
		if (match(description, /<([^>]+)>/, arr)) { \
			placeholder = "<" arr[1] ">"; \
		} \
		gsub(/%/, placeholder, target); \
		printf "\033[36m%-30s\033[0m %s\n", target, description; \
	}' "$(mb_targets_filtered)"
	$(if $(call mb_is_off,$(mb_debug_targets)),
		rm -f "$(mb_targets_valid)" "$(mb_targets_desc)" "$(mb_targets_filtered)"
	)

## Note: Even with -q it still seems to process mb/target-list which is why MB_TARGETS_SKIP is needed
## Also, the $(shell) is needed because this forces make to run this during parsing phase and not during the execution phase which caused "Error 2"
mb/targets-all-valid:
	$(shell MB_TARGETS_SKIP=1 MAKECMDGOALS="" GNUMAKEFLAGS="" MAKEFLAGS="" MFLAGS="" make -pRrq | awk '/^[^.#\/[:space:]][^=]*:([^=]|$$)/ { print $$1 }' | sort -u > "$(mb_targets_valid)")

mb/targets-all-desc:
	$(mb_targets_list_get_files)
	grep -h -E '^[$$()/a-zA-Z0-9_%/\-]+:.*?## .*$$' $(mb_targets_list_get_files_all) > "$(mb_targets_desc)"

mb/targets-filtered: mb/targets-all-valid
mb/targets-filtered: mb/targets-all-desc
mb/targets-filtered:
	awk -F':' 'NR==FNR { targets[$$1]; next } $$1 in targets' "$(mb_targets_valid)" "$(mb_targets_desc)" > "$(mb_targets_filtered)"

else
## To avoid infinite loop
mb/targets-list:
	;

endif # MB_TARGETS_SKIP
endif # Windows_NT




define mb_targets_list_get_files
	$(eval mb_get_files_project := $(filter $(mb_project_mb_project_mk_file) $(mb_project_mb_project_mk_local_file), $(MAKEFILE_LIST)))
	$(eval mb_get_files_mb_modules := $(filter $(mb_modules_path)/%,$(MAKEFILE_LIST)))
	$(eval mb_get_files_project_modules := $(filter $(mb_project_bindhub_modules_path)/%,$(MAKEFILE_LIST)))

	$(call mb_debug_print,mb/targets-list Project files: $(mb_get_files_project),$(mb_debug_targets))
	$(call mb_debug_print,mb/targets-list MB modules files: $(mb_get_files_mb_modules),$(mb_debug_targets))
	$(call mb_debug_print,mb/targets-list Project modules files: $(mb_get_files_project_modules),$(mb_debug_targets))

	$(eval mb_targets_list_get_files_all := $(strip $(mb_core_path)/targets.mk $(mb_get_files_project) $(mb_get_files_mb_modules) $(mb_get_files_project_modules)))
	$(call mb_debug_print,mb/targets-list all file: $(mb_targets_list_get_files_all),$(mb_debug_targets))
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
