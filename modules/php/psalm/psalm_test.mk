#####################################################################################
# Project: MakeBind
# File: modules/php/psalm/psalm_test.mk
# Description: Tests for the psalm module
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/util.mk
include $(mb_core_path)/functions.mk

## Load config to define variables
include $(mb_modules_path)/php/psalm/mod_config.mk

######################################################################################
# Configuration tests
######################################################################################

define test_modules_psalm_config_defaults
	$(call mb_assert_eq,vendor/bin/psalm,$(psalm_bin),psalm_bin should default to vendor/bin/psalm)
	$(call mb_assert_eq,psalm.xml,$(psalm_config),psalm_config should default to psalm.xml)
	$(call mb_assert_eq,$(mb_true),$(psalm_send_to_file),psalm_send_to_file should default to mb_true)
	$(call mb_assert_eq,psalm.output,$(psalm_output_file),psalm_output_file should default to psalm.output)
	$(call mb_assert_empty,$(psalm_threads),psalm_threads should be empty by default)
endef

######################################################################################
# psalm_build_args tests
######################################################################################

## Need to include the main module for function tests
include $(mb_modules_path)/php/psalm/psalm.mk

define test_modules_psalm_build_args_empty
	$(eval psalm_config := nonexistent.xml)
	$(eval $0_result := $(call psalm_build_args))
	$(call mb_assert_empty,$($0_result),Should return empty when no config and no options)
	$(eval psalm_config := psalm.xml)
endef

define test_modules_psalm_build_args_with_threads
	$(eval psalm_threads := 4)
	$(eval psalm_config := nonexistent.xml)
	$(eval $0_result := $(call psalm_build_args))
	$(call mb_assert_eq,--threads=4,$($0_result),Should include threads option)
	$(eval psalm_threads :=)
	$(eval psalm_config := psalm.xml)
endef

define test_modules_psalm_build_args_with_files
	$(eval psalm_files := src/Controller/)
	$(eval psalm_config := nonexistent.xml)
	$(eval $0_result := $(call psalm_build_args))
	$(call mb_assert_eq,src/Controller/,$($0_result),psalm_files should be included)
	$(eval psalm_files :=)
	$(eval psalm_config := psalm.xml)
endef

define test_modules_psalm_build_args_runtime_args
	$(eval psalm_args := --no-progress --output-format=json)
	$(eval psalm_config := nonexistent.xml)
	$(eval $0_result := $(call psalm_build_args))
	$(call mb_assert_eq,--no-progress --output-format=json,$($0_result),Runtime psalm_args should be included)
	$(eval psalm_args :=)
	$(eval psalm_config := psalm.xml)
endef

define test_modules_psalm_build_args_all_options
	$(eval psalm_threads := 8)
	$(eval psalm_args := --no-cache)
	$(eval psalm_files := src/)
	$(eval psalm_config := nonexistent.xml)
	$(eval $0_result := $(call psalm_build_args))
	$(call mb_assert_eq,--threads=8 --no-cache src/,$($0_result),All options should be combined)
	$(eval psalm_threads :=)
	$(eval psalm_args :=)
	$(eval psalm_files :=)
	$(eval psalm_config := psalm.xml)
endef
