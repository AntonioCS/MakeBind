#####################################################################################
# Project: MakeBind
# File: tests/test_runner.mk
# Description: Test runner, discovery, and utilities
# Author: AntonioCS
# License: MIT License
#####################################################################################

__mb_tests_dir := $(dir $(lastword $(MAKEFILE_LIST)))

include $(mb_core_path)/util/variables.mk
include $(__mb_tests_dir)/asserts.mk

mb_testing_long_file := /tmp/mb_testing.log
mb_run_tests_assertions_count_total := 0
mb_run_tests_assertions_count_success := 0
mb_run_tests_assertions_count_fail := 0
mb_debug_tests ?=#

######################################################################################
# Test Discovery
######################################################################################

## mb_test_find_all_tests: Find all test files in tests/unit/ and modules/
## Returns: List of all *_test.mk files
define mb_test_find_all_tests
$(strip
	$(shell find $(mb_test_path_unit) $(mb_modules_path) -type f -name "*_test.mk" 2>/dev/null)
)
endef

## mb_test_name_from_path: Extract test name from file path
## Args:
##   1: Full path to test file
## Returns: Test name (filename without _test.mk)
define mb_test_name_from_path
$(strip
	$(patsubst %_test,%,$(basename $(notdir $1)))
)
endef

## mb_test_load_tests: Load test files based on filter
## Args:
##   1: filter (optional) - only load tests matching this pattern
define mb_test_load_tests
$(strip
	$(eval $0_all_test_files := $(call mb_test_find_all_tests))

	$(if $(value 1),
		$(eval $0_filter := $(strip $1))
		$(eval $0_all_test_files := $(filter %/$($0_filter)_test.mk,$($0_all_test_files)))
		$(if $($0_all_test_files),,
			$(info No tests found matching: $($0_filter))
		)
	)

	$(if $($0_all_test_files),
		$(info Found $(words $($0_all_test_files)) test file(s):)
		$(foreach $0_test_file,$($0_all_test_files),
			$(eval $0_test_name := $(call mb_test_name_from_path,$($0_test_file)))
			$(info - $($0_test_name): $($0_test_file))
		)
		$(info )
		$(info Loading tests...)
		$(foreach $0_test_file,$($0_all_test_files),
			$(eval include $($0_test_file))
		)
	)
)
endef

######################################################################################
# Test Runner
######################################################################################

## mb_run_tests: Run all tests matching the test_* pattern
## Env vars:
##   filter=<test> - Filter tests to be executed
##   exclude=<test> - Exclude tests from being executed
define mb_run_tests
$(strip
$(shell > $(mb_testing_long_file))
$(eval $0_all_tests := $(filter test_%,$(.VARIABLES)))
$(eval $0_test_count := 0)
$(eval $0_assertions_count := 0)
$(if $(value filter),
	$(eval $0_all_tests := $(filter $(filter),$($0_all_tests)))
)
$(if $(value exclude),
	$(eval $0_all_tests := $(filter-out $(exclude),$($0_all_tests)))
)

$(info All tests to be executed: $($0_all_tests))

$(foreach $0_running_test,$($0_all_tests),
	$(call mb_test_assert_reset)
	$(eval $0_result := $(strip $(call $($0_running_test))))
	$(call mb_test_check_asserts)
	$(call mb_inc,$0_test_count)
)
$(info Tests run: $($0_test_count))
$(info Assertions run: $(mb_run_tests_assertions_count_total))
$(info Assertions passed: $(mb_run_tests_assertions_count_success))
$(info Assertions failed: $(mb_run_tests_assertions_count_fail))
cat $(mb_testing_long_file);
$(if $(call mb_is_neq,$(mb_run_tests_assertions_count_fail),0),
	exit 1
))
endef

######################################################################################
# Function Call Tracking
######################################################################################

mb_assert_was_called_func := $(mb_empty)#

## mb_assert_was_called: Track function calls for verification
## Args:
##   1: function name (required)
##   2: expected call count (required)
define mb_assert_was_called
$(strip
$(eval $0_func := $1)
$(eval $0_func_back_up := $(subst $$,$(mb_dollar_replace),$(value $1)))
$(eval $0_expected_called_times := $2)
$(eval $0_call_counter := 0)
$(eval $1 = $$(call mb_inc,$0_call_counter))
)
endef

## mb_test_check_asserts: Verify function call expectations
define mb_test_check_asserts
$(strip
	$(if $(value mb_assert_was_called_func),
		$(eval $0_expected := $(mb_assert_was_called_expected_called_times))
		$(eval $0_actual := $(mb_assert_was_called_call_counter))
		$(call mb_assert_eq,\
			$($0_expected),$($0_actual),\
			Function $(mb_assert_was_called_func) was called $($0_actual) times - expected $($0_expected)\
		)
	)
)
endef

## mb_test_assert_reset: Reset test state between tests
define mb_test_assert_reset
$(if $(value mb_assert_was_called_func),
	$(eval $(mb_assert_was_called_func) = $(subst $(mb_dollar_replace),$$,$(mb_assert_was_called_func_back_up)))
)
$(eval
	undefine mb_assert_was_called_func
	undefine mb_assert_fail
	undefine mb_assert_pass
	undefine mb_assert_msg_fail
)
endef
