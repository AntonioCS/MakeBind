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
mb_test_path_data := $(mb_test_path)/data
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
mb_makebind_tmp_path := $(abspath $(mb_test_path)/../tmp/tests)

$(if $(wildcard $(mb_makebind_tmp_path)),, $(shell mkdir -p $(mb_makebind_tmp_path)))

include test_runner.mk

.SHELLFLAGS := -euco pipefail

## Helper for calling mock project
define mock_prj_call
$(strip $(MAKE) GNUMAKEFLAGS="" --file=$(mb_test_mock_project_mk) $1)
endef

## Default target: discover and run all tests
## Usage: make
## Usage: make test=docker  (filter by module name)
.PHONY: run_tests
run_tests:
	$(call mb_test_load_tests,$(value test))
	$(call mb_run_tests)
