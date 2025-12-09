#####################################################################################
# Project: MakeBind
# File: tests/asserts.mk
# Description: Test assertion functions
# Author: AntonioCS
# License: MIT License
#####################################################################################

## mb_assert: Assert that a condition is truthy
## Args:
##   1: condition (required)
##   2: message on failure (optional)
define mb_assert
$(strip
$(if $1,
	$(eval mb_assert_pass := 1)
	,
	$(if $(value 2), $(eval mb_assert_msg_fail := $2))
	$(eval mb_assert_fail := 1)
)
$(call mb_assert_log_state)
)
endef

## mb_assert_eq: Assert two values are equal
## Args:
##   1: expected (required)
##   2: actual (required)
##   3: message on failure (optional)
define mb_assert_eq
$(strip
$(eval $0_param_expected_real := $(strip $1))
$(eval $0_param_actual_real := $(strip $2))
$(eval $0_param_msg := $(if $(value 3),$3,Expected '$($0_param_expected_real)' does not match actual '$($0_param_actual_real)'))
$(eval $0_expected := $(strip $(call mb_remove_spaces,$($0_param_expected_real))))
$(eval $0_actual := $(strip $(call mb_remove_spaces,$($0_param_actual_real))))

$(eval $0_filter_result := $(strip $(filter $($0_expected),$($0_actual))))
$(if $(mb_debug_tests),
	$(info Expected: $($0_expected))
	$(info Actual__: $($0_actual))
	$(info Filter: $($0_filter_result))
)
$(if $($0_filter_result),
	$(eval mb_assert_pass := 1)
	,
	$(eval mb_assert_msg_fail := $($0_param_msg))
	$(eval mb_assert_fail := 1)
)
$(call mb_assert_log_state)
)
endef

## mb_assert_neq: Assert two values are not equal
## Args:
##   1: not expected (required)
##   2: actual (required)
##   3: message on failure (optional)
define mb_assert_neq
$(strip
$(eval $0_param_not_expected_real := $(strip $1))
$(eval $0_param_actual_real := $(strip $2))
$(eval $0_param_msg := $(if $(value 3),$3,Expected '$($0_param_actual_real)' to NOT equal '$($0_param_not_expected_real)'))
$(eval $0_not_expected := $(strip $(call mb_remove_spaces,$($0_param_not_expected_real))))
$(eval $0_actual := $(strip $(call mb_remove_spaces,$($0_param_actual_real))))

$(eval $0_filter_result := $(strip $(filter $($0_not_expected),$($0_actual))))
$(if $(mb_debug_tests),
	$(info Not Expected: $($0_not_expected))
	$(info Actual______: $($0_actual))
	$(info Filter: $($0_filter_result))
)
$(if $($0_filter_result),
	$(eval mb_assert_msg_fail := $($0_param_msg))
	$(eval mb_assert_fail := 1)
	,
	$(eval mb_assert_pass := 1)
)
$(call mb_assert_log_state)
)
endef

## mb_assert_empty: Assert that a value is empty
## Args:
##   1: value (required)
##   2: message on failure (optional)
define mb_assert_empty
$(strip
$(if $(strip $1),
	$(eval mb_assert_msg_fail := $(if $(value 2),$2,Expected empty got '$1'))
	$(eval mb_assert_fail := 1)
,
	$(eval mb_assert_pass := 1)
)
)
$(call mb_assert_log_state)
endef

## mb_assert_not_empty: Assert that a value is not empty
## Args:
##   1: value (required)
##   2: message on failure (optional)
define mb_assert_not_empty
$(strip
$(if $(strip $1),
	$(eval mb_assert_pass := 1)
,
	$(eval mb_assert_msg_fail := $(if $(value 2),$2,Expected non-empty value))
	$(eval mb_assert_fail := 1)
)
)
$(call mb_assert_log_state)
endef

## mb_assert_filter: Assert that a pattern matches a value (using Make's filter)
## Note: % wildcard only works at start or end of pattern, not in the middle
## Args:
##   1: pattern (required)
##   2: value (required)
##   3: message on failure (optional)
define mb_assert_filter
$(strip
$(if $(filter $1,$2),
	$(eval mb_assert_pass := 1)
	,
	$(eval mb_assert_msg_fail := $(if $(value 3),$3,Pattern '$1' did not match '$2'))
	$(eval mb_assert_fail := 1)
)
$(call mb_assert_log_state)
)
endef

## mb_assert_contains: Assert that a substring is found in a value
## Args:
##   1: substring (required)
##   2: value (required)
##   3: message on failure (optional)
define mb_assert_contains
$(strip
$(if $(findstring $1,$2),
	$(eval mb_assert_pass := 1)
	,
	$(eval mb_assert_msg_fail := $(if $(value 3),$3,Substring '$1' not found in '$2'))
	$(eval mb_assert_fail := 1)
)
$(call mb_assert_log_state)
)
endef

## mb_assert_exists: Assert that a file or directory exists
## Args:
##   1: path (required)
##   2: message on failure (optional)
define mb_assert_exists
$(strip
$(if $(wildcard $1),
	$(eval mb_assert_pass := 1)
	,
	$(eval mb_assert_msg_fail := $(if $(value 2),$2,Does not exist: $1))
	$(eval mb_assert_fail := 1)

)
$(call mb_assert_log_state)
)
endef

## mb_assert_not_exists: Assert that a file or directory does not exist
## Args:
##   1: path (required)
##   2: message on failure (optional)
define mb_assert_not_exists
$(strip
$(if $(wildcard $1),
	$(eval mb_assert_msg_fail := $(if $(value 2),$2,Should not exist: $1))
	$(eval mb_assert_fail := 1)
	,
	$(eval mb_assert_pass := 1)
)
$(call mb_assert_log_state)
)
endef

## mb_assert_log_state: Internal function to log assertion results
define mb_assert_log_state
$(strip
	$(if $(value mb_assert_pass),
		$(call mb_inc,mb_run_tests_assertions_count_success)
		,
		$(if $(value mb_assert_fail),
			$(call mb_inc,mb_run_tests_assertions_count_fail)
			$(file >> $(mb_testing_long_file),$(mb_run_tests_running_test) - FAIL: $(mb_assert_msg_fail))
		)
	)
	$(eval
		undefine mb_assert_pass
		undefine mb_assert_fail
	)
	$(call mb_inc,mb_run_tests_assertions_count_total)
)
endef
