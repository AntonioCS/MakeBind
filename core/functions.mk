#####################################################################################
# Project: MakeBind
# File: core/functions.mk
# Description: Core functions for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_FUNCTIONS_MK__
__MB_CORE_FUNCTIONS_MK__ := 1

include $(mb_core_path)/util.mk
include $(mb_core_path)/util/colours.mk


mb_invoke_print ?= $(mb_on)
mb_invoke_print_target ?= $(mb_on)
mb_invoke_no_output ?= $(mb_off)
mb_invoke_ignore_error ?= $(mb_off)
mb_invoke_dry_run ?= $(mb_off)
mb_invoke_pipe_to ?= $(mb_empty)
mb_invoke_no_error_handling ?= $(mb_off)
mb_invoke_last_target := $(mb_empty)
mb_invoke_in_shell ?= $(mb_off)
mb_invoke_display_info_msg ?= $(mb_on)


define mb_invoke
	$(if $(value 1),,$(error ERROR: You must pass a commad))
	$(if $(and $(call mb_on,$(mb_invoke_display_info_msg)),$(value mb_info_msg)),
		$(call mb_printf_info,$(mb_info_msg))
		$(eval undefine mb_info_msg)
	)
	$(eval mb_invoke_should_print_target := $(and
			$(call mb_is_on,$(mb_invoke_print_target)),
			$(call mb_is_neq,$(mb_invoke_last_target),$@)
		)
	)
	$(if $(mb_invoke_should_print_target),
		$(eval mb_invoke_last_target := $@)
		$(call mb_printf_info,Target: $@ $(if $*, - Original: $(subst $*,%,$@)))
	)
	$(if $(call mb_is_on,$(mb_invoke_print)),
		$(call mb_printf_info,Executing:,,$(mb_off))
		echo " $(subst #,\#,$(subst ",\",$(subst \,,$1)))";
    )

    $(if $(call mb_is_off,$(mb_invoke_dry_run)),
    	$1
    )
endef # mb_invoke


############################################################################################################################
############################################################################################################################

mb_user_confirm_default_msg ?= Are you sure? [y/n]
mb_user_confirm_default_accepted_value ?= y
mb_user_confirm_auto_accept ?= $(mb_off)
mb_user_confirm_timeout ?= 15

define mb_user_confirm
$(strip
	$(eval
		mb_user_confirm_msg := $(mb_warning_triangle) $(if $(value 1),\
			$1,\
			$(mb_user_confirm_default_msg)\
		)>$(mb_space)
		mb_user_confirm_accepted_answer := $(if $(value 2),\
			$(call mb_tolower,$2),\
			$(mb_user_confirm_default_accepted_value)\
		)
	)
	$(if $(call mb_is_on,$(mb_user_confirm_auto_accept)),
		$(mb_true)
	,
		$(eval mb_user_confirm_reply := $(call mb_ask_user,\
			$(mb_user_confirm_msg),\
			$(if \
				$(call mb_is_neq,0,$(mb_user_confirm_timeout)),\
				$(mb_user_confirm_timeout)) \
			)\
		)
		$(call mb_is_eq,$(mb_user_confirm_reply),$(call mb_tolower,$(mb_user_confirm_accepted_answer)))
	)
)
endef

############################################################################################################################
############################################################################################################################

#https://www.baeldung.com/linux/read-command
# $1 - text to display (string) optional, Default "Are you sure? [y/n]:"
# $2 - timeout (int) optional, Default 0
# $3 - default text filled in (string) optional, Default ""
define mb_ask_user
$(strip
	$(eval mb_ask_user_text := $(if $(value 1),$1,Are you sure? [y/n]:))
	$(eval mb_ask_user_time_out := $(if $(value 2),-t $(strip $2)))
	$(eval mb_ask_user_default_text := $(if $(value 3),-i "$(strip $3)"))
	$(shell read -e \
		-p "$(mb_ask_user_text)$(mb_space)" \
		$(mb_ask_user_time_out) \
		$(mb_ask_user_default_text) \
		; \
		echo $$REPLY \
	)
)
endef
#$(shell read $(mb_ask_user_time_out) -p $$'$(mb_ask_user_initial_text)$(mb_space)'; echo $$REPLY)

#$(shell read -e $(ask_user_initial_text) $(ask_user_time_out) -p $$'$1$(mb_space)'; echo $$REPLY)
############################################################################################################################
############################################################################################################################

#https://stackoverflow.com/a/63626637/8715
#https://www.computerhope.com/unix/uprintf.htm
#mb_printf_info_format_specifier := "[%s]\033[32m[%s]\033[0m %b" 	# Green text for "printf"
#mb_printf_warn_format_specifier := "[%s]\033[33m[%s]\033[0m $(call mb_colour_text,m_italic,WARNING): %b"  	# Yellow text for "printf"
#mb_printf_error_format_specifier := "[%s]\033[31m[%s]\033[0m $(call mb_colour_text,m_bold,ERROR): %b" 	# Red text for "printf"
mb_printf_info_format_specifier ?= "[%s]$(call mb_colour_text,Green,[%s]) %b"
mb_printf_warn_format_specifier ?= "[%s]$(call mb_colour_text,IYellow,[%s] WARNING): %b"
mb_printf_error_format_specifier ?= "[%s]$(call mb_colour_text,BRed,[%s] ERROR): %b"

mb_printf_display_ts ?= $(mb_on)
mb_printf_ts_format ?= +'%F %T'
mb_printf_use_break_line ?= $(mb_on)

## NOTE: Do not use normalizer on this one, because if we are printing bash code this will mess it up
## so this one has to be the one that does not normalize
## EXTRA Note: There seems to be some negative effects when I do
## $(eval msg := $(strip $1))
## If I pass bash code in (like I do in the run function) the $ will be evaluated

## $1 - msg
## $2 - format
## $3 - project name (defaults to variable mb_project_name or just MakeBind
## $4 - use break line (defaults to on)
define mb_printf
$(strip
	$(eval mb_printf_msg := $1)
	$(eval mb_printf_format := $2)
	$(eval mb_printf_project_name := $(if $(value 3),$3,$(if $(value mb_project_name),$(mb_project_name),MakeBind)))
	$(eval mb_printf_breakline := $(if $(call mb_is_on,$(if $(value 4),$4,$(mb_printf_use_break_line))),printf "\n";))
	printf $(mb_printf_format) \
		"$(if $(call mb_is_on,$(mb_printf_display_ts)),$(shell date $(mb_printf_ts_format)))" \
		"$(mb_printf_project_name)" \
		"$(mb_printf_msg)";$(mb_printf_breakline)
)
endef



mb_printf_info = $(call mb_printf,$(call mb_normalizer,$1),$(mb_printf_info_format_specifier),$(if $(value 2),$2),$(if $(value 3),$3))
mb_printf_warn = $(call mb_printf,$(call mb_normalizer,$1),$(mb_printf_warn_format_specifier),$(if $(value 2),$2),$(if $(value 3),$3))
mb_printf_error = $(call mb_printf,$(call mb_normalizer,$1),$(mb_printf_error_format_specifier),$(if $(value 2),$2),$(if $(value 3),$3))

### NOTE: Ensure load-data is called before calling
info-%:
	$(call mb_printf_info,$(mb_info_msg))

warn-%:
	$(call mb_printf_warn,$(mb_warn_msg))

### NOTE: Ensure load-data is called before calling
error:
	$(call mb_printf_error,$(mb_error_msg))


define mb_normalizer
$(strip
	$(subst
		`,\`,
		$(subst ",\",$1)
	)
)
endef

endif # __MB_CORE_FUNCTIONS_MK__
