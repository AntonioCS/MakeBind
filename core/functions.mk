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

mb_invoke_print ?= $(mb_on) ## Print the command that is being executed
mb_invoke_print_target ?= $(mb_on) ## Print the target that is being executed
mb_invoke_dry_run ?= $(mb_off) ## Do not execute the command
mb_invoke_last_target := $(mb_empty) ## Last target that was executed
mb_invoke_last_cmd := $(mb_empty) ## Last command invoked
mb_invoke_silent ?= $(mb_off) ## Do not print anything
mb_invoke_run_in_shell ?= $(mb_off) ## Run the command in a shell
mb_invoke_shell_exit_code :=## The exit code of the last command run in shell (set by mb_invoke)
mb_invoke_shell_output :=## The output of the last command run in shell (set by mb_invoke)

## Note: We need to add a separator if multiple commands are passed if mb_invoke is used in a loop and the command is not run in a shell
mb_invoke_cmd_autosep ?= $(mb_true)## default: auto-terminate
mb_invoke_cmd_sep ?= $(mb_scolon)## default: semicolon


# Predicates bound to the last mb_invoke run-in-shell exit code
mb_is_last_rc_ok   = $(call mb_is_eq,$(strip $(mb_invoke_shell_exit_code)),0)
mb_is_last_rc_fail = $(call mb_is_neq,$(strip $(mb_invoke_shell_exit_code)),0)


## $1 - command (Note: Don't put $1 in $0_cmd to avoid evaluation issues)
define mb_invoke
$(strip
	$(if $(value 1),,$(error ERROR: You must pass a command))
	$(eval $0_shell_exit_code :=#)
	$(eval $0_shell_output :=#)

	$(eval $0_cmd := $(value 1))
	$(if $(call mb_is_off,$($0_silent)),
		$(eval $0_should_print_target := $(and
				$(call mb_is_on,$($0_print_target)),
				$(call mb_is_neq,$($0_last_target),$@)
			)
		)
		$(if $($0_should_print_target),
			$(eval $0_last_target := $@)
			$(call mb_printf_info,Target: $@ $(if $*, - Original: $(subst $*,%,$@)))
		)
		$(if $(call mb_is_on,$($0_print)),
			$(call mb_printf_info,Executing: $(call $0_normalizer,$1))
		)
	)
    $(if $(call mb_is_off,$($0_dry_run)),
		$(eval $0_last_cmd := $(value 1))
		$(if $(call mb_is_on,$($0_run_in_shell)),
			$(call mb_shell_capture,$($0_cmd),$0_shell_exit_code,$0_shell_output)
		,
			$($0_cmd)$(if $($0_cmd_autosep),$($0_cmd_sep))
		)
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

# $(call mb_shell_capture,<command>,<exit_var>,<log_var>)
# $1: Runs <command> in /bin/sh
# $2: Sets <exit_var> to the numeric exit code
# $3: Sets <log_var>  to the combined stdout+stderr
# Note: pass the actual name of the variables not $(var) but just var.
# Example: $(call mb_shell_capture,ls dir,exit_code_var,log_var)
define mb_shell_capture
	$(eval $0_mk_tmp := $(shell mktemp -t mkout.XXXXXX))
	$(eval $0_mk_ec  := $(shell sh -c '$1 > "$($0_mk_tmp)" 2>&1; printf "%s" $$?'))
	$(eval $2 := $($0_mk_ec))
$(eval define $3
$(file < $($0_mk_tmp))
endef)
	$(eval $(shell rm -f "$($0_mk_tmp)"))
endef

############################################################################################################################
############################################################################################################################


# =============================================================================
# mb_user_confirm — Ask the user to confirm an action (with timeout & defaults)
#
# Purpose:
#   Prompt the user before performing a potentially destructive or sensitive
#   action. Works non-interactively when auto-accept is enabled.
#
# Signature:
#   $(call mb_user_confirm[,<message>[,<accepted value>]])
#
# Params:
#   $1 (optional) : Confirmation message shown to the user.
#                   Defaults to $(mb_user_confirm_default_msg)
#                   (e.g., "Are you sure? [y/n]").
#   $2 (optional) : The answer that will be considered acceptance (compared
#                   case-insensitively). Defaults to
#                   $(mb_user_confirm_default_accepted_value) (e.g., "y").
#
# Behavior:
#   - If $(mb_user_confirm_auto_accept) is ON, returns $(mb_true) immediately.
#   - Otherwise, prompts the user (with an optional timeout of
#     $(mb_user_confirm_timeout) seconds if non-zero).
#   - Returns $(mb_true) if the reply equals the accepted value (case-insensitive),
#     else returns $(mb_false).
#
# Config (overridable in mb_config):
#   mb_user_confirm_default_msg              ?= Are you sure? [y/n]
#   mb_user_confirm_default_accepted_value   ?= y
#   mb_user_confirm_auto_accept              ?= $(mb_off)   # ON to auto-accept
#   mb_user_confirm_timeout                  ?= 15          # 0 disables timeout
#
# Example:
#   $(if $(call mb_user_confirm,Delete bucket s3://my-bucket?),,\
#       $(call mb_printf_warn,Aborted by user); exit 1)
#
# Notes:
#   - Relies on existing helpers: mb_is_on, mb_tolower, mb_ask_user,
#     mb_is_eq, mb_true/mb_false, mb_space, mb_warning_triangle.
#   - Use inside a recipe line so that "exit 1" stops the shell if declined.
# =============================================================================


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

mb_ask_user_default_question_text ?= Are you sure? [y/n]:
#https://www.baeldung.com/linux/read-command
# $1 - text to display (string) optional, Default set in mb_ask_user_default_question_text"
# $2 - timeout (int) optional, Default 0 (Does not work on windows)
# $3 - default text filled in (string) optional, Default "" (Does not work on windows)
define mb_ask_user
$(strip
	$(eval $0_question_text := $(if $(value 1),$1,$($0_default_question_text)))
	$(eval $0_time_out := $(if $(value 2),-t $(strip $2)))
	$(eval $0_default_text := $(if $(value 3),-i "$(strip $3)"))
	$(call mb_os_call,$(call $0_windows),$(call $0_linux_mac))
)
endef

mb_ask_user_linux_mac_cmd ?= read -e
define mb_ask_user_linux_mac
$(strip
$(mb_ask_user_linux_mac_cmd) \
	-p "$(mb_ask_user_question_text)$(mb_space)" \
	$(mb_ask_user_time_out) \
	$(mb_ask_user_default_text) \
	; \
	echo $(mb_dollar_replace)REPLY \
)
endef


## NOTE: there is more that can be done to simulate the linux version (timeout and default text) but for now this is enough
mb_ask_user_windows = $(call mb_powershell,Read-Host "$(mb_ask_user_default_question_text)")


############################################################################################################################
############################################################################################################################

#https://stackoverflow.com/a/63626637/8715
#https://www.computerhope.com/unix/uprintf.htm


## No colours for powershell (for now)
## There is some info here https://duffney.io/usingansiescapesequencespowershell/#8-bit-256-color-foreground--background
## But I was not able to get this work properly via make (works fine directly on the terminal)
#mb_printf_info_format_specifier ?= "{0}{1} {2}"
#mb_printf_info_format_specifier ?= $(call mb_os_assign,"{0}{1} {2}","%s$(call mb_colour_text,Green,%s) %b")
#mb_printf_warn_format_specifier ?= "%s$(call mb_colour_text,IYellow,%s WARNING): %b"
#mb_printf_error_format_specifier ?= "%s$(call mb_colour_text,BRed,%s ERROR): %b"
#mb_printf_debug_format_specifier ?= "%s$(call mb_colour_text,BBlue,%s DEBUG): %b"

## Not working properly
#mb_printf_info_format_specifier ?= $(call mb_os_assign,"{0}{1} {2}","%s$(call mb_colour_text,Green,%s) %b")
#mb_printf_warn_format_specifier ?= $(call mb_os_assign,"{0}{1} WARNING: {2}","%s$(call mb_colour_text,IYellow,%s WARNING): %b")
#mb_printf_error_format_specifier ?= $(call mb_os_assign,"{0}{1} ERROR: {2}","%s$(call mb_colour_text,BRed,%s ERROR): %b")
#mb_printf_debug_format_specifier ?= $(call mb_os_assign,"{0}{1} DEBUG: {2}","%s$(call mb_colour_text,BBlue,%s DEBUG): %b")

ifeq ($(OS),Windows_NT)
mb_printf_info_format_specifier ?= "{0}{1} {2}"
mb_printf_warn_format_specifier ?= "{0}{1} WARNING: {2}"
mb_printf_error_format_specifier ?= "{0}{1} ERROR: {2}"
mb_printf_debug_format_specifier ?= "{0}{1} DEBUG: {2}"
mb_printf_ts_format ?= "yyyy-MM-dd HH:mm:ss"## Timestamp format
else
mb_printf_info_format_specifier ?= "%s$(call mb_colour_text,Green,%s) %b"
mb_printf_warn_format_specifier ?= "%s$(call mb_colour_text,IYellow,%s WARNING): %b"
mb_printf_error_format_specifier ?= "%s$(call mb_colour_text,BRed,%s ERROR): %b"
mb_printf_debug_format_specifier ?= "%s$(call mb_colour_text,BBlue,%s DEBUG): %b"
mb_printf_ts_format ?= +'%F %T'## Timestamp format
endif
mb_printf_opt_display_ts ?= $(mb_on) ## Display timestamp
mb_printf_opt_display_project_name ?= $(mb_on) ## Display project name
mb_printf_opt_display_guard_l ?= [## Display Left guard
mb_printf_opt_display_guard_r ?= ]## Right guard

mb_printf_use_break_line ?= $(mb_on) ## Use break line
# This will cause the printf to use the shell command and be printed using $(info) which will make it be printed via make and not the actual shell
mb_printf_opt_use_shell ?= $(mb_on) ## Use shell command

mb_printf_internal_print_using_info := 1
mb_printf_internal_print_using_warning := 2
mb_printf_internal_print_using_error := 3
mb_printf_internal_print ?= $(mb_printf_internal_print_using_info)

## $1 - msg
## $2 - format
## $3 - project name (defaults to variable mb_project_name or just MakeBind
## $4 - use break line (defaults to on)
ifdef MB_TARGETS_SKIP
mb_printf =#
else
define mb_printf
$(strip
	$(eval $0_msg = $(if $(value 1),$(strip $1),$(error ERROR: $0 - You must pass a message to print)))
	$(eval $0_format = $(if $(value 2),$(strip $2),$(error ERROR: $0 - You must pass a format specifier)))
	$(eval $0_project_name = $(if $(strip $(value 3)),$3,$(if $(value mb_project_name),$(mb_project_name),MakeBind)))
	$(eval $0_breakline = $(if \
		$(call mb_is_on,$(if $(value 4),$4,$(mb_printf_use_break_line))),\
		$(mb_true))\
	)
	$(if $(call mb_is_on,$(mb_printf_opt_use_shell)),
		$(eval mb_printf_result = $(shell $(mb_printf_statement)))
		$(if $(call mb_is_eq,$(mb_printf_internal_print),$(mb_printf_internal_print_using_info)),
			$(info $(mb_printf_result))
			,
			$(if $(call mb_is_eq,$(mb_printf_internal_print),$(mb_printf_internal_print_using_warning)),
				$(warning $(mb_printf_result))
				,
				$(error $(mb_printf_result))
			)
		)
		,
		$(mb_printf_statement)
	)
)
endef
endif # MB_TARGETS_SKIP

mb_printf_statement_display_guard = $(mb_printf_opt_display_guard_l)$1$(mb_printf_opt_display_guard_r)## Prevent spaces

## NOTE: mb_os_assign not working so well for this
define mb_printf_statement
$(strip
$(eval mb_printf_statement_project_name := $(strip $(if $(call mb_is_on,$(mb_printf_opt_display_project_name)),\
	$(call mb_printf_statement_display_guard,$(mb_printf_project_name)))\
))

$(if $(mb_os_is_windows),
$(eval mb_printf_statement_ts := $(strip $(if $(call mb_is_on,$(mb_printf_opt_display_ts)),\
	$(call mb_printf_statement_display_guard,$(shell $(call mb_powershell,Get-Date -Format $(mb_printf_ts_format)))))\
))
$(call mb_powershell,Write-Host ($(mb_printf_format) -f "$(mb_printf_statement_ts)"$(mb_comma)"$(mb_printf_statement_project_name)"$(mb_comma)"$(mb_printf_msg)"\
$(if $(mb_printf_breakline),,-NoNewline))),

$(eval mb_printf_statement_ts := $(if $(call mb_is_on,$(mb_printf_opt_display_ts)),$(call mb_printf_statement_display_guard,$(shell date $(mb_printf_ts_format)))))
printf $(mb_printf_format) "$(mb_printf_statement_ts)" "$(mb_printf_statement_project_name)" "$(mb_printf_msg)"$(if $(mb_printf_breakline),;printf "\n";)
))
endef


## NOTE: Seems to require the slashes at the end (unlike the other functions), might be because of the $(call
define mb_printf_info
$(strip \
	$(call mb_printf,\
		$(call mb_normalizer,$1),\
		$(mb_printf_info_format_specifier),\
		$(if $(value 2),$2),\
		$(if $(value 3),$3),\
	))
endef

define mb_printf_warn
$(strip
$(eval mb_printf_internal_print := $(mb_printf_internal_print_using_warning))
$(call mb_printf,$(call mb_normalizer,$1),$(mb_printf_warn_format_specifier),$(if $(value 2),$2),$(if $(value 3),$3))
)
endef

define mb_printf_error
$(strip
$(eval mb_printf_internal_print := $(mb_printf_internal_print_using_error))
$(call mb_printf,$(call mb_normalizer,$1),$(mb_printf_error_format_specifier),$(if $(value 2),$2),$(if $(value 3),$3))
)
endef

define mb_normalizer
$(strip
	$(subst
		`,\`,
		$(subst ",\",$1)
	)
)
endef


endif # __MB_CORE_FUNCTIONS_MK__
