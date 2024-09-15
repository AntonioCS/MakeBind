
include $(mb_core_path)/util/variables.mk

#mb_assert_was_called_func := $(mb_empty)
#mb_assert_pass := 0
#mb_assert_fail := 0
#mb_assert_msg_fail := $(mb_empty)
mb_testing_long_file := /tmp/mb_testing.log
mb_run_tests_assertions_count_total := 0
mb_run_tests_assertions_count_success := 0
mb_run_tests_assertions_count_fail := 0
mb_debug_tests ?=#

define mb_run_tests
$(strip
$(shell > $(mb_testing_long_file))
$(eval $0_all_tests := $(filter test_%,$(.VARIABLES)))
$(eval $0_test_count := 0)
$(eval $0_assertions_count := 0)
$(if $(value filter),
	$(eval $0_all_tests := $(filter $(filter),$($0_all_tests)))
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

mb_assert_was_called_func := $(mb_empty)#

define mb_assert_was_called
$(strip
$(eval $0_func := $1)
$(eval $0_func_back_up := $(subst $$,$(mb_dollar_replace),$(value $1)))
$(eval $0_expected_called_times := $2)
$(eval $0_call_counter := 0)
$(eval $1 = $$(call mb_inc,$0_call_counter))
)
endef


## NOTE: I might need to use \ when calling my own "functions" as  mb_assert_eq not having \ was causing:
## Makefile:74: *** recipe commences before first target. Stop.
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

## We must remove spaces so that filter doesn't match partially the strings
# $1 - Expected
# $2 - Actual
# $3 - Message (optional)
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

define mb_assert_filter
$(strip
$(if $(filter $1,$2),
	$(eval mb_assert_pass := 1)
	,
	$(eval mb_assert_msg_fail := $(if $(value 3),$3,))
	$(eval mb_assert_fail := 1)
)
$(call mb_assert_log_state)
)
endef

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
#mb_run_tests_assertions_count_total := 0
#mb_run_tests_assertions_count_success := 0
#mb_run_tests_assertions_count_fail := 0