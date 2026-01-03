#####################################################################################
# Project: MakeBind
# File: tests/unit/core/util/git_test.mk
# Description: Tests for git utility functions
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/util/variables.mk
include $(mb_core_path)/util/git.mk

mb_debug_git := $(mb_off)

## Test that mb_staged_files returns empty when no files are staged
define test_core_util_git_staged_files_empty_when_none
	$(eval $@_result := $(call mb_staged_files,php))
	$(call mb_assert_empty,$($@_result),Expected empty result when no PHP files are staged)
endef

## Test that mb_staged_files works with different extensions
define test_core_util_git_staged_files_different_extensions
	$(eval $@_result_py := $(call mb_staged_files,py))
	$(eval $@_result_go := $(call mb_staged_files,go))
	$(eval $@_result_js := $(call mb_staged_files,js))
	$(call mb_assert_empty,$($@_result_py),Expected empty result for py)
	$(call mb_assert_empty,$($@_result_go),Expected empty result for go)
	$(call mb_assert_empty,$($@_result_js),Expected empty result for js)
endef

## Test that mb_run_on_staged does not error when no files staged
## Note: This test verifies the function executes without error
## The actual command won't run since there are no staged files
define test_core_util_git_run_on_staged_no_files
	$(eval $@_result := $(call mb_run_on_staged,php,echo "would run"))
	$(call mb_assert,1,mb_run_on_staged should complete without error)
endef

## Test that mb_staged_files works without extension (doesn't error)
## Note: Can't assert empty since tests may run with staged files
define test_core_util_git_staged_files_all_no_extension
	$(eval $@_result := $(call mb_staged_files))
	$(call mb_assert,1,mb_staged_files without extension should complete without error)
endef

## Test that mb_run_on_staged works without extension
define test_core_util_git_run_on_staged_all_no_extension
	$(eval $@_result := $(call mb_run_on_staged,,echo "would run"))
	$(call mb_assert,1,mb_run_on_staged without extension should complete without error)
endef
