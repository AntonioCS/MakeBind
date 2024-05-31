#####################################################################################
# Project: MakeBind
# File: main.mk
# Description: Main entry point for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################

mb_make_version_required ?= 4.4%
mb_debug ?= 0
mb_default_shell ?= /bin/bash

ifndef CI
ifeq ($(filter $(mb_make_version_required),$(MAKE_VERSION)),)
  $(error Incompatible GNU Make version, please upgrade to $(subst %,*,$(mb_make_version_required)) or higher)
endif
endif

ifndef mb_project_path
  $(error ERROR: Please define the variable 'mb_project_path' in your project Makefile)
endif

mb_main_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mb_makebind_path := $(abspath $(realpath $(dir $(mb_main_path))))
mb_makebind_templates_path := $(mb_makebind_path)/templates
mb_config_path := $(abspath $(mb_makebind_path)/mb_config.mk)
mb_config_local_path := $(abspath $(mb_makebind_path)/mb_config.mk)
mb_core_path = $(abspath $(mb_makebind_path)/core)
mb_modules_path := $(abspath $(mb_makebind_path)/modules)
mb_project_makefile := $(mb_project_path)/Makefile
mb_project_bindhub_path := $(mb_project_path)/bind-hub
mb_project_bindhub_modules_path := $(mb_project_bindhub_path)/modules
mb_project_mb_config_file := $(mb_project_bindhub_path)/mb_config.mk
mb_project_mb_config_local_file := $(mb_project_bindhub_path)/mb_config.local.mk
mb_project_mb_project_mk_file := $(mb_project_bindhub_path)/mb_project.mk
mb_project_mb_project_mk_local_file := $(mb_project_bindhub_path)/mb_project.local.mk
mb_project_modules := $(mb_empty)

include $(mb_makebind_path)/mb_config.mk
-include $(mb_makebind_path)/mb_config.local.mk

.ONESHELL:
SHELL := $(mb_default_shell)

include $(mb_core_path)/util.mk
include $(mb_core_path)/functions.mk
include $(mb_core_path)/modules_manager.mk
include $(mb_core_path)/util/targets.mk

MAKEFLAGS := --no-builtin-rules \
	--no-builtin-variables \
	--always-make \
	--warn-undefined-variables \
	--no-print-directory \
	$(if $(call mb_is_off,$(mb_debug)),--silent)


## Configure shell flags:
## '-e' exits the shell if any command exits with a non-zero status.
## '-u' treats unset variables and parameters as an error when performing parameter expansion.
## '-c' tells the shell that the commands to run are coming from the string argument following this option.
## '-x' (conditionally included if MB_DEBUG is set) prints each command before execution, useful for debugging.
## '-o pipefail' ensures the pipeline's return status is the exit code of the last command to exit with a non-zero status.
.SHELLFLAGS := -euc$(if $(call mb_is_on,$(mb_debug)),x)o pipefail
.DEFAULT_GOAL = $(mb_default_target)

ifeq ($(mb_debug),$(mb_on))
$(info MAKEFLAGS: $(MAKEFLAGS))
$(info .SHELLFLAGS: $(.SHELLFLAGS))
$(info mb_main_path: $(mb_main_path))
$(info mb_makebind_path: $(mb_makebind_path))
$(info mb_makebind_templates_path: $(mb_makebind_templates_path))
$(info mb_core_path: $(mb_core_path))
$(info mb_modules_path: $(mb_modules_path))
$(info mb_project_makefile: $(mb_project_makefile))
$(info mb_project_bindhub_path: $(mb_project_bindhub_path))
$(info mb_project_bindhub_modules_path: $(mb_project_bindhub_modules_path))
$(info mb_project_mb_config_file: $(mb_project_mb_config_file))
$(info mb_project_mb_config_local_file: $(mb_project_mb_config_local_file))
$(info mb_project_mb_project_mk_file: $(mb_project_mb_project_mk_file))
$(info mb_project_mb_project_mk_local_file: $(mb_project_mb_project_mk_local_file))
$(info mb_default_shell: $(mb_default_shell))
endif # mb_debug

ifeq ($(call mb_not_exists,$(mb_project_mb_config_file)),$(mb_true))
include $(mb_core_path)/util/init_project.mk
endif

## Include the project specific configuration and target files
include $(mb_project_mb_config_file)
-include $(mb_project_mb_config_local_file)
include $(mb_project_mb_project_mk_file)
-include $(mb_project_mb_project_mk_local_file)

$(call mb_load_modules)

