#####################################################################################
# Project: MakeBind
# File: core/util/git.mk
# Description: Git utility functions for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################
ifndef __MB_CORE_UTIL_GIT_MK__
__MB_CORE_UTIL_GIT_MK__ := 1

mb_debug_git ?= $(mb_debug)

## Check if git is available (set once at load time)
## Note: Can't use mb_cmd_exists or mb_true here as they may not be defined yet
mb_git_available := $(shell command -v git >/dev/null 2>&1 && echo 1)

## @function mb_staged_files
## @description Returns a space-separated list of staged files, optionally filtered by extension
## @arg 1: extension (optional) - File extension to filter (e.g., php, py, go). If empty, returns all staged files.
## @returns Space-separated list of staged files (paths relative to git root)
## @example $(call mb_staged_files,php) -> src/Foo.php src/Bar.php
## @example $(call mb_staged_files) -> all staged files
define mb_staged_files
$(strip
	$(if $(mb_git_available),
		$(eval $0_arg1_ext := $(if $(value 1),$(strip $1),))
		$(if $($0_arg1_ext),
			$(shell git diff --cached --name-only --diff-filter=d 2>/dev/null | grep '\.$($0_arg1_ext)$$' || true),
			$(shell git diff --cached --name-only --diff-filter=d 2>/dev/null)
		)
	)
)
endef

## @function mb_run_on_staged
## @description Runs a command only if there are staged files.
##              Optionally filters by extension. The staged files are appended to the command.
## @arg 1: extension (optional) - File extension to filter (e.g., php, py, go). If empty, matches all files.
## @arg 2: command (required) - Command to run (files will be appended)
## @example $(call mb_run_on_staged,php,vendor/bin/phpstan analyse)
## @example $(call mb_run_on_staged,,prettier --write)
define mb_run_on_staged
$(strip
	$(if $(mb_git_available),
		$(eval $0_arg1_ext := $(if $(value 1),$(strip $1),))
		$(eval $0_arg2_cmd := $(if $(value 2),$(strip $2),$(call mb_printf_error,$0: command required)))
		$(eval $0_files := $(call mb_staged_files,$($0_arg1_ext)))
		$(if $($0_files),
			$(call mb_debug_print,Running: $($0_arg2_cmd) $($0_files),$(mb_debug_git))
			$($0_arg2_cmd) $($0_files)
		,
			$(if $($0_arg1_ext),
				$(call mb_printf_info,No staged .$($0_arg1_ext) files),
				$(call mb_printf_info,No staged files)
			)
		)
	,
		$(call mb_printf_info,git not available)
	)
)
endef

endif # __MB_CORE_UTIL_GIT_MK__
