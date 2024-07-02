#####################################################################################
# Project: MakeBind
# File: tests/mb_test.mk
# Description: Tests for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################


.ONESHELL:
SHELL = /bin/bash
mb_debug_tests ?=# Not set to anything
mb_assert = $(if $1,$(info TEST PASSED: "$@"),$(error TEST FAILURE: $2))
## We must remove spaces so that filter doesn't match partially the strings
define mb_assert_eq
$(strip
$(eval mb_assert_eq_expected := $(strip $(call mb_remove_spaces,$1)))
$(eval mb_assert_eq_actual := $(strip $(call mb_remove_spaces,$2)))
$(if $(mb_debug_tests),
	$(info Expected: $(mb_assert_eq_expected))
	$(info Actual__: $(mb_assert_eq_actual))
	$(info Filter: $(filter $(mb_assert_eq_expected),$(mb_assert_eq_actual)))
)
$(if $(filter $(mb_assert_eq_expected),$(mb_assert_eq_actual)),
	$(info TEST PASSED: $(if $(value 3),$3,"$@")),
	$(warning TEST FAILURE: $(if $(value 3),$3,"$@"))
))
endef
define mb_assert_filter
$(if $(filter $1,$2),
	$(info TEST PASSED: $(if $(value 3),$3,"$@")),
	$(warning TEST FAILURE: $(if $(value 3),$3,"$@"))
)
endef

define mb_assert_exists
$(strip
$(if $(wildcard $1),
	$(info TEST PASSED: $(if $(value 2),$2,Exists: $1)),
	$(warning TEST FAILURE: $(if $(value 2),$2,Does not exist: $1"))
))
endef

mb_test_path := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
mb_test_mock_project_mk := $(abspath $(mb_test_path)/mock_project/Makefile)
mb_core_path := $(abspath $(mb_test_path)/../core)
mb_debug ?= 0
mb_project_path = $(mb_empty)
mb_main_path := $(abspath $(realpath $(mb_test_path)/../main.mk))
mb_makebind_path := $(abspath $(realpath $(dir $(mb_main_path))))
mb_makebind_config_path ?= $(mb_test_path)/mb_config.test.mk
mb_makebind_config_local_path = #

include $(mb_test_path)/mb_config.test.mk

MAKEFLAGS := --no-builtin-rules \
	--no-builtin-variables \
	--always-make \
	--warn-undefined-variables \
	--no-print-directory \
	--silent

SHELL := /bin/bash
.SHELLFLAGS := -eucx
#ifeq ($(if $(value OS),$(OS),not_windows),Windows_NT)
## Note: Make seem to ignore this
#SHELL := C:\\Program Files\\PowerShell\\7\\pwsh.exe
#MAKESHELL := $(SHELL)
#.SHELLFLAGS := -NoProfile -Command
#endif



## Helper
## Note: Was getting a warning of undefined GNUMAKEFLAGS, so I added it to the call
define mock_prj_call
$(strip $(MAKE) GNUMAKEFLAGS="" --file=$(mb_test_mock_project_mk) $1)
endef


include $(mb_test_path)/core/util_test.mk
include $(mb_test_path)/core/util/cache_test.mk
include $(mb_test_path)/core/util/help_test.mk
include $(mb_test_path)/core/functions_test.mk
include $(mb_test_path)/modules/docker_compose_test.mk
include $(mb_test_path)/Makefile_test.mk
