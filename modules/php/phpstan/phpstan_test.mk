#####################################################################################
# Project: MakeBind
# File: modules/php/phpstan/phpstan_test.mk
# Description: Tests for the phpstan module
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/util.mk
include $(mb_core_path)/functions.mk

## Load config to define variables
include $(mb_modules_path)/php/phpstan/mod_config.mk

######################################################################################
# Configuration tests
######################################################################################

define test_modules_phpstan_config_defaults
	$(call mb_assert_eq,vendor/bin/phpstan,$(phpstan_bin),phpstan_bin should default to vendor/bin/phpstan)
	$(call mb_assert_eq,phpstan.neon,$(phpstan_config),phpstan_config should default to phpstan.neon)
	$(call mb_assert_eq,$(mb_true),$(phpstan_send_to_file),phpstan_send_to_file should default to mb_true)
	$(call mb_assert_eq,phpstan.output,$(phpstan_output_file),phpstan_output_file should default to phpstan.output)
	$(call mb_assert_empty,$(phpstan_level),phpstan_level should be empty by default)
	$(call mb_assert_empty,$(phpstan_memory_limit),phpstan_memory_limit should be empty by default)
endef

######################################################################################
# phpstan_build_args tests
######################################################################################

## Need to include the main module for function tests
include $(mb_modules_path)/php/phpstan/phpstan.mk

define test_modules_phpstan_build_args_empty
	$(eval phpstan_config := nonexistent.neon)
	$(eval $0_result := $(call phpstan_build_args))
	$(call mb_assert_empty,$($0_result),Should return empty when no config and no options)
	$(eval phpstan_config := phpstan.neon)
endef

define test_modules_phpstan_build_args_with_level
	$(eval phpstan_level := 8)
	$(eval phpstan_config := nonexistent.neon)
	$(eval $0_result := $(call phpstan_build_args))
	$(call mb_assert_eq,--level=8,$($0_result),Should include level option)
	$(eval phpstan_level :=)
	$(eval phpstan_config := phpstan.neon)
endef

define test_modules_phpstan_build_args_with_memory_limit
	$(eval phpstan_memory_limit := 512M)
	$(eval phpstan_config := nonexistent.neon)
	$(eval $0_result := $(call phpstan_build_args))
	$(call mb_assert_eq,--memory-limit=512M,$($0_result),Should include memory-limit option)
	$(eval phpstan_memory_limit :=)
	$(eval phpstan_config := phpstan.neon)
endef

define test_modules_phpstan_build_args_with_files
	$(eval phpstan_files := src/Controller/)
	$(eval phpstan_config := nonexistent.neon)
	$(eval $0_result := $(call phpstan_build_args))
	$(call mb_assert_eq,src/Controller/,$($0_result),phpstan_files should be included)
	$(eval phpstan_files :=)
	$(eval phpstan_config := phpstan.neon)
endef

define test_modules_phpstan_build_args_runtime_args
	$(eval phpstan_args := --no-progress --error-format=json)
	$(eval phpstan_config := nonexistent.neon)
	$(eval $0_result := $(call phpstan_build_args))
	$(call mb_assert_eq,--no-progress --error-format=json,$($0_result),Runtime phpstan_args should be included)
	$(eval phpstan_args :=)
	$(eval phpstan_config := phpstan.neon)
endef

define test_modules_phpstan_build_args_all_options
	$(eval phpstan_level := 5)
	$(eval phpstan_memory_limit := 1G)
	$(eval phpstan_args := --no-progress)
	$(eval phpstan_files := src/)
	$(eval phpstan_config := nonexistent.neon)
	$(eval $0_result := $(call phpstan_build_args))
	$(call mb_assert_eq,--level=5 --memory-limit=1G --no-progress src/,$($0_result),All options should be combined)
	$(eval phpstan_level :=)
	$(eval phpstan_memory_limit :=)
	$(eval phpstan_args :=)
	$(eval phpstan_files :=)
	$(eval phpstan_config := phpstan.neon)
endef
