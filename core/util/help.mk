#####################################################################################
# Project: MakeBind
# File: core/util/help.mk
# Description: Help for targets and functions
# Author: AntonioCS
# License: MIT License
#####################################################################################



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