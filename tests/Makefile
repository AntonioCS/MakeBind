#####################################################################################
# Project: MakeBind
# File: tests/Makefile
# Description: Test runner for MakeBind tests
# Author: AntonioCS
# License: MIT License
#####################################################################################


.ONESHELL:
.DEFAULT_GOAL := run_tests
SHELL = /bin/bash
MAKEFLAGS := --no-builtin-rules \
	--no-builtin-variables \
	--always-make \
	--warn-undefined-variables \
	--no-print-directory \
	--silent

mb_debug_tests ?=# Not set to anything

mb_test_path := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
mb_test_path_unit := $(mb_test_path)/unit
mb_test_main_path := $(abspath $(mb_test_path)/../main.mk)
mb_test_mock_project_mk := $(abspath $(mb_test_path)/mock_project/Makefile)
mb_core_path := $(abspath $(mb_test_path)/../core)
mb_modules_path := $(abspath $(mb_test_path)/../modules)
mb_debug ?= 0
mb_project_path = $(mb_empty)
mb_main_path := $(abspath $(realpath $(mb_test_path)/../main.mk))
mb_makebind_path := $(abspath $(realpath $(dir $(mb_main_path))))
mb_makebind_config_path ?= $(mb_test_path)/mb_config.test.mk
mb_makebind_config_local_path = #
mb_makebind_tmp_path := /tmp


include make_testing.mk


.SHELLFLAGS := -euco pipefail
#ifeq ($(if $(value OS),$(OS),not_windows),Windows_NT)
### Note: Make seem to ignore this
#SHELL := pwsh.exe
#MAKESHELL := $(SHELL)
#.SHELLFLAGS := -NoProfile -Command
#endif

## Helper
## Note: Was getting a warning of undefined GNUMAKEFLAGS, so I added it to the call
define mock_prj_call
$(strip $(MAKE) GNUMAKEFLAGS="" --file=$(mb_test_mock_project_mk) $1)
endef


include $(mb_test_path_unit)/core/util_test.mk
include $(mb_test_path_unit)/core/util/cache_test.mk
include $(mb_test_path_unit)/core/util/help_test.mk
include $(mb_test_path_unit)/core/functions_test.mk
include $(mb_test_path_unit)/modules/docker_compose_test.mk
#include $(mb_test_path_unit)/core/util_test_mb_is_regex_match.mk ### -- Problems WIP
#include $(mb_test_path)/Makefile_test.mk --WIP


run_tests:
	$(call mb_run_tests)
