#####################################################################################
# Project: MakeBind
# File: modules/php/phpcs/phpcs_test.mk
# Description: Tests for the phpcs module
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/util.mk
include $(mb_core_path)/functions.mk

## Load config to define variables
include $(mb_modules_path)/php/phpcs/mod_config.mk

######################################################################################
# Configuration tests
######################################################################################

define test_modules_phpcs_config_defaults
	$(call mb_assert_eq,vendor/bin/phpcs,$(phpcs_bin),phpcs_bin should default to vendor/bin/phpcs)
	$(call mb_assert_eq,vendor/bin/phpcbf,$(phpcbf_bin),phpcbf_bin should default to vendor/bin/phpcbf)
	$(call mb_assert_eq,phpcs.xml,$(phpcs_config_file),phpcs_config_file should default to phpcs.xml)
	$(call mb_assert_eq,$(mb_true),$(phpcs_send_to_file),phpcs_send_to_file should default to mb_true)
	$(call mb_assert_eq,phpcs.output,$(phpcs_output_file),phpcs_output_file should default to phpcs.output)
	$(call mb_assert_empty,$(phpcs_parallel),phpcs_parallel should be empty by default)
	$(call mb_assert_empty,$(phpcs_cache),phpcs_cache should be empty by default)
	$(call mb_assert_empty,$(phpcs_progress),phpcs_progress should be empty by default)
	$(call mb_assert_empty,$(phpcs_report),phpcs_report should be empty by default)
endef

######################################################################################
# phpcs_build_args tests
######################################################################################

## Need to include the main module for function tests
include $(mb_modules_path)/php/phpcs/phpcs.mk

define test_modules_phpcs_build_args_empty
	$(eval phpcs_config_file := nonexistent.xml)
	$(eval $0_result := $(call phpcs_build_args))
	$(call mb_assert_empty,$($0_result),Should return empty when no config and no options)
	$(eval phpcs_config_file := phpcs.xml)
endef

define test_modules_phpcs_build_args_with_parallel
	$(eval phpcs_parallel := 4)
	$(eval phpcs_config_file := nonexistent.xml)
	$(eval $0_result := $(call phpcs_build_args))
	$(call mb_assert_eq,--parallel=4,$($0_result),Should include parallel option)
	$(eval phpcs_parallel :=)
	$(eval phpcs_config_file := phpcs.xml)
endef

define test_modules_phpcs_build_args_with_cache
	$(eval phpcs_cache := .phpcs.cache)
	$(eval phpcs_config_file := nonexistent.xml)
	$(eval $0_result := $(call phpcs_build_args))
	$(call mb_assert_eq,--cache=.phpcs.cache,$($0_result),Should include cache option)
	$(eval phpcs_cache :=)
	$(eval phpcs_config_file := phpcs.xml)
endef

define test_modules_phpcs_build_args_with_progress
	$(eval phpcs_progress := 1)
	$(eval phpcs_config_file := nonexistent.xml)
	$(eval $0_result := $(call phpcs_build_args))
	$(call mb_assert_eq,-p,$($0_result),Should include progress flag)
	$(eval phpcs_progress :=)
	$(eval phpcs_config_file := phpcs.xml)
endef

define test_modules_phpcs_build_args_with_report
	$(eval phpcs_report := json)
	$(eval phpcs_config_file := nonexistent.xml)
	$(eval $0_result := $(call phpcs_build_args))
	$(call mb_assert_eq,--report=json,$($0_result),Should include report option)
	$(eval phpcs_report :=)
	$(eval phpcs_config_file := phpcs.xml)
endef

define test_modules_phpcs_build_args_with_files
	$(eval phpcs_files := src/Controller/)
	$(eval phpcs_config_file := nonexistent.xml)
	$(eval $0_result := $(call phpcs_build_args))
	$(call mb_assert_eq,src/Controller/,$($0_result),phpcs_files should be included)
	$(eval phpcs_files :=)
	$(eval phpcs_config_file := phpcs.xml)
endef

define test_modules_phpcs_build_args_runtime_args
	$(eval phpcs_args := --colors -n)
	$(eval phpcs_config_file := nonexistent.xml)
	$(eval $0_result := $(call phpcs_build_args))
	$(call mb_assert_eq,--colors -n,$($0_result),Runtime phpcs_args should be included)
	$(eval phpcs_args :=)
	$(eval phpcs_config_file := phpcs.xml)
endef
