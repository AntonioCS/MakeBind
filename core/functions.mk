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

mb_invoke_print ?= $(mb_on)
mb_invoke_print_target ?= $(mb_on)
mb_invoke_dry_run ?= $(mb_off)
mb_invoke_last_target := $(mb_empty)
mb_invoke_silent ?= $(mb_off)

define mb_invoke
$(strip
	$(if $(value 1),,$(error ERROR: You must pass a commad))
	$(if $(call mb_is_off,$(mb_invoke_silent)),
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
			$(eval mb_invoke_print_normalized := $(call mb_invoke_normalizer,$1))
			$(call mb_printf_info,Executing: $(mb_invoke_print_normalized))
		)
	)
    $(if $(call mb_is_off,$(mb_invoke_dry_run)),
		$1
    )
)
endef # mb_invoke

define mb_invoke_normalizer
$(strip
	$(subst \\",",
	$(subst #,\\#,
	$(subst ",\\",
	$(subst \\,,
		$1))))
)
endef


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
############################################################################################################################
############################################################################################################################

#https://stackoverflow.com/a/63626637/8715
#https://www.computerhope.com/unix/uprintf.htm

mb_printf_info_format_specifier ?= "[%s]$(call mb_colour_text,Green,[%s]) %b"
mb_printf_warn_format_specifier ?= "[%s]$(call mb_colour_text,IYellow,[%s] WARNING): %b"
mb_printf_error_format_specifier ?= "[%s]$(call mb_colour_text,BRed,[%s] ERROR): %b"
mb_printf_debug_format_specifier ?= "[%s]$(call mb_colour_text,BBlue,[%s] DEBUG): %b"

mb_printf_display_ts ?= $(mb_on)
mb_printf_ts_format ?= +'%F %T'
mb_printf_use_break_line ?= $(mb_on)
# This will cause the printf to use the shell command and be printed using $(info) which will make it be printed via make and not the actual shell
mb_printf_use_shell ?= $(mb_on)
mb_printf_internal_print_using_info := 1
mb_printf_internal_print_using_warning := 2
mb_printf_internal_print_using_error := 3
mb_printf_internal_print ?= $(mb_printf_internal_print_using_info)

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
	$(if $(call mb_is_on,$(mb_printf_use_shell)),
		$(eval mb_printf_result := $(shell $(mb_printf_statement)))
		$(if $(call mb_is_eq,$(mb_printf_internal_print),$(mb_printf_internal_print_using_info)),
			$(info $(mb_printf_result)),
			$(if $(call mb_is_eq,$(mb_printf_internal_print),$(mb_printf_internal_print_using_warning)),
				$(warning $(mb_printf_result)),
				$(error $(mb_printf_result))
			)
		)
		,
		$(mb_printf_statement)
	)
)
endef

define mb_printf_statement
printf $(mb_printf_format) \
	"$(if $(call mb_is_on,$(mb_printf_display_ts)),$(shell date $(mb_printf_ts_format)))" \
	"$(mb_printf_project_name)" \
	"$(mb_printf_msg)";$(mb_printf_breakline)
endef


mb_printf_info = $(call mb_printf,$(call mb_normalizer,$1),$(mb_printf_info_format_specifier),$(if $(value 2),$2),$(if $(value 3),$3))

define mb_printf_warn
$(strip
$(eval mb_printf_internal_print := $(mb_printf_internal_print_using_warning))
$(call mb_printf,$(call mb_normalizer,$1),$(mb_printf_warn_format_specifier),$(if $(value 2),$2),$(if $(value 3),$3)))
endef

define mb_printf_error
$(strip
$(eval mb_printf_internal_print := $(mb_printf_internal_print_using_error))
$(call mb_printf,$(call mb_normalizer,$1),$(mb_printf_error_format_specifier),$(if $(value 2),$2),$(if $(value 3),$3)))
endef

mb/info-%:
	$(call mb_printf_info,$(mb_info_msg))

mb/warn-%:
	$(call mb_printf_warn,$(mb_warn_msg))

mb/error:
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
