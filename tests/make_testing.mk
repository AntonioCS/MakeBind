
include $(mb_core_path)/util/variables.mk

mb_assert_was_called_func := $(mb_empty)
mb_assert_pass := 0
mb_assert_fail := 0
mb_assert_msg_fail := $(mb_empty)

define mb_run_tests
$(strip
$(eval $0_all_tests := $(filter test_%,$(.VARIABLES)))
$(if $(value filter_test),
	$(eval $0_all_tests := $(filter $(filter_test),$($0_all_tests)))
)
$(info All tests to be executed: $($0_all_tests))
$(foreach $0_running_test,$($0_all_tests),
	$(call mb_test_assert_reset)
	$(eval $0_result := $(strip $(call $($0_running_test))))
	$(call mb_test_check_asserts)
)
)
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
	$(if $(mb_assert_was_called_func),
		$(eval $0_expected := $(mb_assert_was_called_expected_called_times))
		$(eval $0_actual := $(mb_assert_was_called_call_counter))
		$(call mb_assert_eq,\
			$($0_expected),$($0_actual),\
			Function $(mb_assert_was_called_func) was called $($0_actual) times - expected $($0_expected)\
		)
	)
	$(intcmp $(mb_assert_fail),0,,
		$(info $(shell printf "\e[32m%s\e[0m %s\n" "ASSERTION PASSED:" "$(mb_run_tests_running_test)")),
		$(info $(shell printf "\e[31m%s\e[0m %s\n" "ASSERTION FAILURE:" "$(mb_run_tests_running_test) $(if $(mb_assert_msg_fail),- $(mb_assert_msg_fail))"))
	)
)
endef

define mb_test_assert_reset
$(if $(value mb_assert_was_called_func),
	$(eval $(mb_assert_was_called_func) = $(subst $(mb_dollar_replace),$$,$(mb_assert_was_called_func_back_up)))
)
$(eval
	mb_assert_was_called_func := $(mb_empty)
	mb_assert_pass := 0
	mb_assert_fail := 0
	mb_assert_msg_fail := $(mb_empty)
)
endef

define mb_assert
$(strip
$(if $1,
	$(eval mb_assert_pass := 1)
	,
	$(if $(value 2), $(eval mb_assert_msg_fail := $2))
	$(eval mb_assert_fail := 1)
))
endef

define mb_assert_fail
$(strip
$(if $(strip $1),
	$(eval mb_assert_msg_fail := $(if $(value 2), $2, Expected to fail))
	$(eval mb_assert_fail := 1)
	,
	$(eval mb_assert_pass := 1)
))
endef


## We must remove spaces so that filter doesn't match partially the strings
define mb_assert_eq
$(strip
$(eval $0_expected := $(strip $(call mb_remove_spaces,$1)))
$(eval $0_actual := $(strip $(call mb_remove_spaces,$2)))
$(eval $0_filter_result := $(filter $($0_expected),$($0_actual)))
$(if $(mb_debug_tests),
	$(info Expected: $($0_expected))
	$(info Actual__: $($0_actual))
	$(info Filter: $0_filter_result)
)
$(if $0_filter_result,
	$(eval mb_assert_pass := 1)
	,
	$(eval mb_assert_msg_fail := $(if $(value 3),$3,Expected $(mb_assert_eq_expected) does not match actual $(mb_assert_eq_actual)))
	$(eval mb_assert_fail := 1)
))
endef
#$(info TEST PASSED: $(if $(value 3),$3,"$@")),
#$(warning TEST FAILURE: $(if $(value 3),$3,"$@"))


define mb_assert_filter
$(strip
$(if $(filter $1,$2),
	$(eval mb_assert_pass := 1)
	,
	$(eval mb_assert_msg_fail := $(if $(value 3),$3,))
	$(eval mb_assert_fail := 1)
))
endef

define mb_assert_exists
$(strip
$(if $(wildcard $1),
	$(eval mb_assert_pass := 1)
	,
	$(eval mb_assert_msg_fail := $(if $(value 2),$2,Does not exist: $1))
	$(eval mb_assert_fail := 1)
))
endef
