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

## @var mb_invoke_print
## @desc Print the command before execution (shows in stdout)
## @type boolean
## @default $(mb_on)
## @values $(mb_on), $(mb_off)
## @group mb_invoke
## @example mb_invoke_print=$(mb_off) make target
## @see mb_invoke_silent, mb_invoke_print_target
mb_invoke_print ?= $(mb_on)

## @var mb_invoke_print_target
## @desc Print the target name before command execution
## @type boolean
## @default $(mb_on)
## @values $(mb_on), $(mb_off)
## @group mb_invoke
## @see mb_invoke_print
mb_invoke_print_target ?= $(mb_on)

## @var mb_invoke_dry_run
## @desc Print commands without executing them (useful for debugging)
## @type boolean
## @default $(mb_off)
## @values $(mb_on), $(mb_off)
## @group mb_invoke
## @example mb_invoke_dry_run=$(mb_on) make deploy
mb_invoke_dry_run ?= $(mb_off)

## @var mb_invoke_last_target
## @desc Tracks the last target that was executed (internal use)
## @type string
## @default $(mb_empty)
## @group mb_invoke
mb_invoke_last_target := $(mb_empty)

## @var mb_invoke_last_cmd
## @desc Stores the last command invoked (internal use)
## @type string
## @default $(mb_empty)
## @group mb_invoke
mb_invoke_last_cmd := $(mb_empty)

## @var mb_invoke_silent
## @desc Suppress all output from mb_invoke (overrides print settings)
## @type boolean
## @default $(mb_off)
## @values $(mb_on), $(mb_off)
## @group mb_invoke
## @see mb_invoke_print, mb_invoke_print_target
mb_invoke_silent ?= $(mb_off)

## @var mb_invoke_run_in_shell
## @desc Run command in a shell and capture output/exit code
## @type boolean
## @default $(mb_off)
## @values $(mb_on), $(mb_off)
## @group mb_invoke
## @see mb_invoke_shell_exit_code, mb_invoke_shell_output
mb_invoke_run_in_shell ?= $(mb_off)

## @var mb_invoke_shell_exit_code
## @desc Exit code of the last command run in shell (set by mb_invoke)
## @type number
## @group mb_invoke
## @see mb_invoke_run_in_shell, mb_is_last_rc_ok, mb_is_last_rc_fail
mb_invoke_shell_exit_code :=

## @var mb_invoke_shell_output
## @desc Combined stdout/stderr output of last shell command (set by mb_invoke)
## @type string
## @group mb_invoke
## @see mb_invoke_run_in_shell
mb_invoke_shell_output :=

## @var mb_invoke_cmd_autosep
## @desc Automatically add separator after commands (for loop usage)
## @type boolean
## @default $(mb_true)
## @values $(mb_true), $(mb_false)
## @group mb_invoke
## @see mb_invoke_cmd_sep
mb_invoke_cmd_autosep ?= $(mb_true)

## @var mb_invoke_cmd_sep
## @desc Command separator to use when autosep is enabled
## @type string
## @default $(mb_scolon)
## @values $(mb_scolon), $(mb_ampersand), etc.
## @group mb_invoke
## @see mb_invoke_cmd_autosep
mb_invoke_cmd_sep ?= $(mb_scolon)


# Predicates bound to the last mb_invoke run-in-shell return code
mb_is_last_rc_ok   = $(call mb_is_eq,$(strip $(mb_invoke_shell_exit_code)),0)
mb_is_last_rc_fail = $(call mb_is_neq,$(strip $(mb_invoke_shell_exit_code)),0)

## @function mb_invoke
## @desc Execute commands with consistent logging, dry-run support, and shell capture
## @desc This is the core command execution function used throughout MakeBind.
## @desc It handles printing, dry-run mode, and can optionally capture output.
## @arg 1: command (required) - The command to execute
## @example $(call mb_invoke,docker ps -a)
## @example $(call mb_invoke,npm install)
## @returns Command output or captured result (if mb_invoke_run_in_shell is enabled)
## @group mb_invoke
## @see mb_invoke_print, mb_invoke_dry_run, mb_invoke_run_in_shell, mb_shell_capture
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

## @function mb_invoke_normalizer
## @desc Normalize command strings for safe printing (escapes special characters)
## @arg 1: text (required) - Text to normalize
## @returns Normalized text with escaped quotes and special characters
## @group mb_invoke
## @see mb_invoke
define mb_invoke_normalizer
$(strip
	$(subst \\",",
	$(subst #,\\#,
	$(subst ",\\",
	$(subst \\,,
		$1))))
)
endef

## @function mb_shell_capture
## @desc Run command in shell and capture both exit code and output
## @desc Uses temporary file to capture combined stdout/stderr output.
## @desc Pass variable names (not values) for exit_var and log_var parameters.
## @arg 1: command (required) - Command to execute in /bin/sh
## @arg 2: exit_var (required) - Variable name to store numeric exit code
## @arg 3: log_var (required) - Variable name to store combined stdout+stderr
## @example $(call mb_shell_capture,ls /tmp,my_exit_code,my_output)
## @example $(call mb_shell_capture,git status,exit_code_var,log_var)
## @group mb_invoke
## @see mb_invoke, mb_invoke_run_in_shell
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

## @var mb_user_confirm_default_msg
## @desc Default confirmation prompt message
## @type string
## @default Are you sure? [y/n]
## @group mb_user_confirm
mb_user_confirm_default_msg ?= Are you sure? [y/n]

## @var mb_user_confirm_default_accepted_value
## @desc Default value that represents user acceptance (case-insensitive)
## @type string
## @default y
## @values y, yes, n, no, etc.
## @group mb_user_confirm
mb_user_confirm_default_accepted_value ?= y

## @var mb_user_confirm_auto_accept
## @desc Automatically accept all confirmations (non-interactive mode)
## @type boolean
## @default $(mb_off)
## @values $(mb_on), $(mb_off)
## @group mb_user_confirm
## @example mb_user_confirm_auto_accept=$(mb_on) make deploy
mb_user_confirm_auto_accept ?= $(mb_off)

## @var mb_user_confirm_timeout
## @desc Timeout in seconds for user confirmation (0 disables timeout)
## @type number
## @default 15
## @values 0 (no timeout), positive integer
## @group mb_user_confirm
mb_user_confirm_timeout ?= 15

## @function mb_user_confirm
## @desc Prompt user for confirmation before performing potentially destructive actions
## @desc Supports auto-accept mode and configurable timeouts for non-interactive use.
## @desc Returns mb_true if user confirms, mb_false otherwise.
## @arg 1: message (optional) - Confirmation message (defaults to mb_user_confirm_default_msg)
## @arg 2: accepted_value (optional) - Value considered as acceptance (defaults to mb_user_confirm_default_accepted_value)
## @example $(if $(call mb_user_confirm,Delete bucket s3://my-bucket?),,$(call mb_printf_warn,Aborted); exit 1)
## @example $(if $(call mb_user_confirm),,exit 1)
## @returns $(mb_true) if confirmed, $(mb_false) otherwise
## @group mb_user_confirm
## @see mb_ask_user, mb_user_confirm_auto_accept, mb_user_confirm_timeout
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

## @var mb_ask_user_default_question_text
## @desc Default question text when prompting user for input
## @type string
## @default Are you sure? [y/n]:
## @group mb_ask_user
mb_ask_user_default_question_text ?= Are you sure? [y/n]:

## @var mb_ask_user_linux_mac_cmd
## @desc Command used for reading user input on Linux/Mac
## @type string
## @default read -e
## @values read -e, read, etc.
## @group mb_ask_user
mb_ask_user_linux_mac_cmd ?= read -e

## @function mb_ask_user
## @desc Prompt user for input with optional timeout and default value
## @desc Cross-platform function (Linux/Mac/Windows). Note: timeout and default text don't work on Windows.
## @arg 1: question_text (optional) - Text to display (defaults to mb_ask_user_default_question_text)
## @arg 2: timeout (optional) - Timeout in seconds, 0 for no timeout (does not work on Windows)
## @arg 3: default_text (optional) - Default text pre-filled (does not work on Windows)
## @example $(call mb_ask_user,Enter your name:)
## @example $(call mb_ask_user,Proceed?,10,y)
## @returns User input as string
## @group mb_ask_user
## @see mb_user_confirm
define mb_ask_user
$(strip
	$(eval $0_question_text := $(if $(value 1),$1,$($0_default_question_text)))
	$(eval $0_time_out := $(if $(value 2),-t $(strip $2)))
	$(eval $0_default_text := $(if $(value 3),-i "$(strip $3)"))
	$(call mb_os_call,$(call $0_windows),$(call $0_linux_mac))
)
endef

## @function mb_ask_user_linux_mac
## @desc Linux/Mac implementation of user input prompt (uses bash read command)
## @desc Internal function called by mb_ask_user for Unix-based systems
## @returns User input from REPLY variable
## @group mb_ask_user
## @see mb_ask_user
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

## @var mb_printf_info_format_specifier
## @desc Format string for info messages (OS-specific)
## @type string
## @group mb_printf
ifeq ($(OS),Windows_NT)
mb_printf_info_format_specifier ?= "{0}{1} {2}"
else
mb_printf_info_format_specifier ?= "%s$(call mb_colour_text,Green,%s)%b"
endif

## @var mb_printf_warn_format_specifier
## @desc Format string for warning messages (OS-specific)
## @type string
## @group mb_printf
ifeq ($(OS),Windows_NT)
mb_printf_warn_format_specifier ?= "{0}{1} WARNING: {2}"
else
mb_printf_warn_format_specifier ?= "%s$(call mb_colour_text,IYellow,%sWARNING): %b"
endif

## @var mb_printf_error_format_specifier
## @desc Format string for error messages (OS-specific)
## @type string
## @group mb_printf
ifeq ($(OS),Windows_NT)
mb_printf_error_format_specifier ?= "{0}{1} ERROR: {2}"
else
mb_printf_error_format_specifier ?= "%s$(call mb_colour_text,BRed,%sERROR): %b"
endif

## @var mb_printf_debug_format_specifier
## @desc Format string for debug messages (OS-specific)
## @type string
## @group mb_printf
ifeq ($(OS),Windows_NT)
mb_printf_debug_format_specifier ?= "{0}{1} DEBUG: {2}"
else
mb_printf_debug_format_specifier ?= "%s$(call mb_colour_text,BBlue,%sDEBUG): %b"
endif

## @var mb_printf_ts_format
## @desc Timestamp format for log messages (OS-specific)
## @type string
## @group mb_printf
ifeq ($(OS),Windows_NT)
mb_printf_ts_format ?= "yyyy-MM-dd HH:mm:ss"
else
mb_printf_ts_format ?= +'%F %T'
endif

## @var mb_printf_opt_display_ts
## @desc Display timestamp in log messages
## @type boolean
## @default $(mb_on)
## @values $(mb_on), $(mb_off)
## @group mb_printf
mb_printf_opt_display_ts ?= $(mb_on)

## @var mb_printf_opt_display_project_name
## @desc Display project name in log messages
## @type boolean
## @default $(mb_on)
## @values $(mb_on), $(mb_off)
## @group mb_printf
mb_printf_opt_display_project_name ?= $(mb_on)

## @var mb_printf_opt_display_guard_l
## @desc Left guard character for timestamp/project name
## @type string
## @default [
## @group mb_printf
mb_printf_opt_display_guard_l ?= [

## @var mb_printf_opt_display_guard_r
## @desc Right guard character for timestamp/project name
## @type string
## @default ]
## @group mb_printf
mb_printf_opt_display_guard_r ?= ]

## @var mb_printf_use_break_line
## @desc Add newline after each message
## @type boolean
## @default $(mb_on)
## @values $(mb_on), $(mb_off)
## @group mb_printf
mb_printf_use_break_line ?= $(mb_on)

## @var mb_printf_opt_use_shell
## @desc Use shell command for printing (vs direct make output)
## @type boolean
## @default $(mb_on)
## @values $(mb_on), $(mb_off)
## @group mb_printf
mb_printf_opt_use_shell ?= $(mb_on)

## Internal constants for mb_printf
mb_printf_internal_print_using_info := 1
mb_printf_internal_print_using_warning := 2
mb_printf_internal_print_using_error := 3
mb_printf_internal_print ?= $(mb_printf_internal_print_using_info)

## @function mb_printf
## @desc Core formatted logging function (internal, use mb_printf_info/warn/error instead)
## @desc Supports timestamps, project name, colors, and different output modes
## @arg 1: msg (required) - Message to print
## @arg 2: format (required) - Format specifier (use mb_printf_*_format_specifier variables)
## @arg 3: project_name (optional) - Project name (defaults to mb_project_name or "MakeBind")
## @arg 4: use_breakline (optional) - Add newline (defaults to mb_printf_use_break_line)
## @arg 5: use_shell (optional) - Use shell for output (defaults to mb_printf_opt_use_shell)
## @returns Formatted message output
## @group mb_printf
## @see mb_printf_info, mb_printf_warn, mb_printf_error
ifdef MB_TARGETS_SKIP
mb_printf =#
else
define mb_printf
$(strip
	$(eval
		$0_msg = $(if $(value 1),$(strip $1),$(error ERROR: $0 - You must pass a message to print))
		$0_format = $(if $(value 2),$(strip $2),$(error ERROR: $0 - You must pass a format specifier))
		$0_project_name = $(strip $(if $(strip $(value 3)),$3,$(if $(value mb_project_name),$(mb_project_name),MakeBind)))
		$0_breakline = $(call mb_is_on,$(if $(value 4),$4,$(mb_printf_use_break_line)))
		$0_use_shell = $(call mb_is_on,$(if $(value 5),$5,$(mb_printf_opt_use_shell)))
	)
	$(if $($0_use_shell),
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

mb_printf_statement_display_guard = $(strip $(mb_printf_opt_display_guard_l)$1$(mb_printf_opt_display_guard_r))## Prevent spaces

## NOTE: mb_os_assign not working so well for this
define mb_printf_statement
$(strip \
	$(eval \
		mb_printf_statement_project_name := $(strip $(if $(call mb_is_on,$(mb_printf_opt_display_project_name)),\
				$(call mb_printf_statement_display_guard,$(mb_printf_project_name)) \
			)\
		)\
	) \
	$(if $(mb_os_is_windows), \
		$(eval mb_printf_statement_ts := $(strip \
				$(if $(call mb_is_on,$(mb_printf_opt_display_ts)),\
					$(call mb_printf_statement_display_guard,$(shell $(call mb_powershell,Get-Date -Format $(mb_printf_ts_format))))\
				) \
			) \
		) \
		$(call mb_powershell,Write-Host ($(mb_printf_format) -f "$(mb_printf_statement_ts)"$(mb_comma)"$(mb_printf_statement_project_name)"$(mb_comma)"$(mb_printf_msg)"\
		$(if $(mb_printf_breakline),,-NoNewline))) \
	, \
		$(eval mb_printf_statement_ts := $(if $(call mb_is_on,$(mb_printf_opt_display_ts)),$(call mb_printf_statement_display_guard,$(shell date $(mb_printf_ts_format))))) \
		printf $(mb_printf_format) "$(mb_printf_statement_ts)" "$(mb_printf_statement_project_name)" "$(mb_printf_msg)"$(if $(mb_printf_breakline),;printf "\n") \
	) \
)
endef

## @function mb_printf_info
## @desc Print informational message with timestamp and project name
## @arg 1: msg (required) - Message to print
## @arg 2: project_name (optional) - Project name override
## @arg 3: use_breakline (optional) - Add newline
## @arg 4: use_shell (optional) - Use shell for output
## @example $(call mb_printf_info,Starting deployment)
## @example $(call mb_printf_info,Task completed successfully)
## @group mb_printf
## @see mb_printf, mb_printf_warn, mb_printf_error
mb_printf_info = $(call mb_printf,$(call mb_normalizer,$1),$(mb_printf_info_format_specifier),$(if $(value 2),$2),$(if $(value 3),$3),$(if $(value 4),$4))

## @function mb_printf_warn
## @desc Print warning message with timestamp and project name
## @arg 1: msg (required) - Warning message to print
## @arg 2: project_name (optional) - Project name override
## @arg 3: use_breakline (optional) - Add newline
## @arg 4: use_shell (optional) - Use shell for output
## @example $(call mb_printf_warn,Deprecated feature used)
## @example $(call mb_printf_warn,Configuration file missing)
## @group mb_printf
## @see mb_printf, mb_printf_info, mb_printf_error
define mb_printf_warn
$(strip \
	$(eval mb_printf_internal_print := $(mb_printf_internal_print_using_warning))\
	$(call mb_printf,$(call mb_normalizer,$1),$(mb_printf_warn_format_specifier),$(if $(value 2),$2),$(if $(value 3),$3),$(if $(value 4),$4))\
)
endef

## @function mb_printf_error
## @desc Print error message with timestamp and project name
## @arg 1: msg (required) - Error message to print
## @arg 2: project_name (optional) - Project name override
## @arg 3: use_breakline (optional) - Add newline
## @arg 4: use_shell (optional) - Use shell for output
## @example $(call mb_printf_error,Build failed)
## @example $(call mb_printf_error,Invalid configuration detected)
## @group mb_printf
## @see mb_printf, mb_printf_info, mb_printf_warn
define mb_printf_error
$(strip \
	$(eval mb_printf_internal_print := $(mb_printf_internal_print_using_error))\
	$(call mb_printf,$(call mb_normalizer,$1),$(mb_printf_error_format_specifier),$(if $(value 2),$2),$(if $(value 3),$3),$(if $(value 4),$4))\
)
endef

## @function mb_normalizer
## @desc Normalize text by escaping special characters for safe shell output
## @arg 1: text (required) - Text to normalize
## @returns Normalized text with escaped quotes and backticks
## @group mb_printf
## @see mb_printf_info, mb_printf_warn, mb_printf_error
mb_normalizer = $(strip $(subst	`,\`, $(subst ",\",$1)))

############################################################################################################################
############################################################################################################################

## @function mb_require_var
## @desc Get variable value or error if not defined (helper for required config)
## @arg 1: var_name (required) - Variable name to check
## @arg 2: error_msg (required) - Error message if variable not defined
## @returns Variable value
## @group core
## @example $(call mb_require_var,my_config_var,$0: my_config_var is required)
define mb_require_var
$(strip
	$(if $(value $1),$(value $1),$(call mb_printf_error,$2))
)
endef

## @function mb_exec_with_mode
## @desc Execute command with mode selection (local/docker/docker-compose)
## @desc Reads <prefix>_exec_mode to determine execution mode and delegates to appropriate handler.
## @desc Supports three modes: local (uses <prefix>_bin), docker (uses dk_shellc with <prefix>_dk_container),
## @desc and docker-compose (uses dc_shellc with <prefix>_dc_service).
## @arg 1: command (required) - Command to execute
## @arg 2: prefix (required) - Variable prefix for config lookup (e.g., "php", "localstack", "pg")
## @example $(call mb_exec_with_mode,bash,localstack)
## @example $(call mb_exec_with_mode,php --version,php)
## @returns Command output via mode-specific handler function
## @group exec_mode
## @see mb_exec_with_mode_local, mb_invoke
## @note Mode handlers are defined by modules: docker adds mb_exec_with_mode_docker,
##       docker_compose adds mb_exec_with_mode_docker-compose, etc.
define mb_exec_with_mode
$(strip
	$(eval $0_arg1_cmd := $(if $(value 1),$(strip $1),$(call mb_printf_error,$0: command argument required)))
	$(eval $0_arg2_prefix := $(if $(value 2),$(strip $2),$(call mb_printf_error,$0: prefix argument required)))

	$(eval $0_mode := $(call mb_require_var,$($0_arg2_prefix)_exec_mode,$0: $($0_arg2_prefix)_exec_mode not defined))
	$(eval $0_handler := $0_$($0_mode))

	$(if $(value $($0_handler)),,
		$(call mb_printf_error,$0: unknown mode '$($0_mode)' for prefix '$($0_arg2_prefix)'. Handler '$($0_handler)' not defined. Ensure the required module is loaded.)
	)

	$(call $($0_handler),$($0_arg1_cmd),$($0_arg2_prefix))
)
endef

## @function mb_exec_with_mode_local
## @desc Execute command locally using the binary specified by <prefix>_bin
## @arg 1: command (required) - Command to execute
## @arg 2: prefix (required) - Variable prefix for config lookup
## @requires <prefix>_bin - Path to the binary
## @group exec_mode
## @see mb_exec_with_mode
define mb_exec_with_mode_local
$(strip
	$(eval $0_arg1_cmd := $(if $(value 1),$(strip $1),$(call mb_printf_error,$0: command argument required)))
	$(eval $0_arg2_prefix := $(if $(value 2),$(strip $2),$(call mb_printf_error,$0: prefix argument required)))

	$(eval $0_bin := $(call mb_require_var,$($0_arg2_prefix)_bin,$0: $($0_arg2_prefix)_bin not defined for local mode))
	$(call mb_invoke,$($0_bin) $($0_arg1_cmd))
)
endef


endif # __MB_CORE_FUNCTIONS_MK__
