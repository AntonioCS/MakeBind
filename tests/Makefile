#####################################################################################
# Project: MakeBind
# File: tests/mb_test.mk
# Description: Tests for MakeBind
# Author: AntonioCS
# License: MIT License
#####################################################################################

mb_assert = $(if $(1),,$(error TEST FAILURE: $(2)))
mb_test_path := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
mb_core_path := $(abspath $(mb_test_path)/../core)
mb_debug ?= 0

MAKEFLAGS := --no-builtin-rules \
	--no-builtin-variables \
	--always-make \
	--warn-undefined-variables \
	--no-print-directory \
	--silent

.SHELLFLAGS := -euc
#$(if $(mb_debug),x)
#-o pipefail

.ONESHELL:
SHELL = /bin/bash



include $(mb_test_path)/core/util_test.mk
include $(mb_test_path)/core/functions_test.mk
include $(mb_test_path)/util/colours_test.mk

tests/core/util: tests/core/util/mb_is_tests

tests/core/functions: tests/core/functions/mb_invoke_test
