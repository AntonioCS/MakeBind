#####################################################################################
# Project: MakeBind
# File: main.mk
# Description: Main entry point for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################

mb_make_version_required ?= 4.4%
mb_debug_all ?= 0
mb_debug ?= $(mb_debug_all)
mb_debug_no_silence ?= $(mb_debug_all)
mb_debug_show_all_commands ?= $(mb_debug_all)

ifndef CI
ifeq ($(filter $(mb_make_version_required),$(MAKE_VERSION)),)
  $(error ERROR: Incompatible GNU Make version, please upgrade to $(subst %,*,$(mb_make_version_required)) or higher, for instructions on how to upgrade please go to: https://github.com/AntonioCS/MakeBind?tab=readme-ov-file#upgrading-Make)
endif
endif

ifndef mb_project_path
  $(error ERROR: Please define the variable 'mb_project_path' in your project Makefile)
endif

## Note: mb_main_path must be set with immediate mode
mb_main_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mb_makebind_path ?= $(abspath $(realpath $(dir $(mb_main_path))))
mb_makebind_config_path ?= $(mb_makebind_path)/mb_config.mk
mb_makebind_config_local_path ?= $(mb_makebind_path)/mb_config.local.mk

include $(mb_makebind_config_path)
-include $(mb_makebind_config_local_path)

include $(mb_core_path)/util.mk
include $(mb_core_path)/functions.mk
include $(mb_core_path)/modules_manager.mk
include $(mb_core_path)/targets.mk

.ONESHELL:
.POSIX:

#https://www.gnu.org/software/make/manual/html_node/Options-Summary.html
MAKEFLAGS := --no-builtin-rules \
	--no-builtin-variables \
	--always-make \
	--warn-undefined-variables \
	--no-print-directory \
	$(if $(call mb_is_off,$(mb_debug_no_silence)),--silent)

## https://stackoverflow.com/a/63840549/8715
SHELL := $(mb_default_shell_not_windows)
## Linux Configure shell flags:
## '-e' exits the shell if any command exits with a non-zero status.
## '-u' treats unset variables and parameters as an error when performing parameter expansion.
## '-c' tells the shell that the commands to run are coming from the string argument following this option.
## '-x' (conditionally included if mb_debug_show_all_commands is set) prints each command before execution, useful for debugging.
## '-o pipefail' ensures the pipeline's return status is the exit code of the last command to exit with a non-zero status.
.SHELLFLAGS := -euc$(if $(call mb_is_on,$(mb_debug_show_all_commands)),x)o pipefail
ifeq ($(OS),Windows_NT)
## This is not working properly and that is why I'm using mb_powershell
SHELL := pwsh.exe
.SHELLFLAGS := -NoProfile -Command
endif

MAKESHELL := $(SHELL)
.DEFAULT_GOAL = $(mb_default_target)

$(call mb_debug_print, SHELL: $(SHELL))
$(call mb_debug_print, .SHELLFLAGS: $(.SHELLFLAGS))
$(call mb_debug_print, MAKEFLAGS: $(MAKEFLAGS))
$(call mb_debug_print, mb_main_path: $(mb_main_path))
$(call mb_debug_print, mb_makebind_path: $(mb_makebind_path))
$(call mb_debug_print, mb_makebind_templates_path: $(mb_makebind_templates_path))
$(call mb_debug_print, mb_makebind_config_path: $(mb_makebind_config_path))
$(call mb_debug_print, mb_makebind_config_local_path: $(mb_makebind_config_local_path))
$(call mb_debug_print, mb_core_path: $(mb_core_path))
$(call mb_debug_print, mb_modules_path: $(mb_modules_path))
$(call mb_debug_print, mb_project_makefile: $(mb_project_makefile))
$(call mb_debug_print, mb_project_bindhub_path: $(mb_project_bindhub_path))
$(call mb_debug_print, mb_project_bindhub_modules_path: $(mb_project_bindhub_modules_path))
$(call mb_debug_print, mb_project_mb_config_file: $(mb_project_mb_config_file))
$(call mb_debug_print, mb_project_mb_config_local_file: $(mb_project_mb_config_local_file))
$(call mb_debug_print, mb_project_mb_project_mk_file: $(mb_project_mb_project_mk_file))
$(call mb_debug_print, mb_project_mb_project_mk_local_file: $(mb_project_mb_project_mk_local_file))
$(call mb_debug_print, mb_default_shell_not_windows: $(mb_default_shell_not_windows))


ifeq ($(and $(mb_check_missing_project_files),$(or $(call mb_not_exists,$(mb_project_mb_config_file)),$(call mb_not_exists,$(mb_project_mb_project_mk_file)))),$(mb_true))
ifeq ($(mb_auto_include_init_project_if_config_missing),$(mb_on))
$(call mb_debug_print, Including init_project since files are missing)
include $(mb_core_path)/init_project.mk
else
$(call mb_printf_error,Project files are missing)
endif
endif

## Include the project specific configuration and target files
$(call mb_debug_print, Including project config files)
include $(mb_project_mb_config_file)
-include $(mb_project_mb_config_local_file)
$(call mb_debug_print, Including project target files)
include $(mb_project_mb_project_mk_file)
-include $(mb_project_mb_project_mk_local_file)

$(call mb_load_modules)

