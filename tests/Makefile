#####################################################################################
# Project: MakeBind
# File: tests/mb_test.mk
# Description: Tests for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################


.ONESHELL:
SHELL = /bin/bash
mb_assert = $(if $1,,$(error TEST FAILURE: $2))
## We must remove spaces so that filter doesn't match partially the strings
define mb_assert_eq
$(strip
$(if $(filter $(call mb_remove_spaces,$1),$(call mb_remove_spaces,$2)),
	$(info TEST "$@" passed),
	$(error TEST FAILURE: "$@")
))
endef
mb_assert_file_exists = $(if $(wildcard $1),$(info TEST SUCCESS: File $1 exists),$(error TEST FAILURE: File $1 does not exist))

mb_test_path := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
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

.SHELLFLAGS := -euc
SHELL := $(mb_default_shell)
#$(if $(mb_debug),x)
#-o pipefail


tests:
	$(info Running tests)
#	$(MAKE) -s tests/core/util
#	$(MAKE) -s tests/core/functions
#	$(MAKE) -s tests/util/colours

include $(mb_test_path)/core/util_test.mk
include $(mb_test_path)/core/util/cache_test.mk
include $(mb_test_path)/core/functions_test.mk
include $(mb_test_path)/util/colours_test.mk
include $(mb_test_path)/modules/docker_compose_test.mk


#tests/core/util: tests/core/util/mb_is_tests
#
#tests/core/functions: tests/core/functions/mb_invoke_test
