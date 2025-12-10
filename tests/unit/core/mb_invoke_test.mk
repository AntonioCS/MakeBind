#####################################################################################
# Project: MakeBind
# File: tests/unit/core/mb_invoke_test.mk
# Description: Tests for mb_invoke function
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/functions.mk

## NOTE: We must reset mb_invoke_last_target before calling mb_invoke to ensure we get the right amount of calls to mb_printf_info
define test_mb_invoke_basic
	$(eval mb_invoke_last_target := $(mb_empty))
	$(eval mb_invoke_silent := $(mb_off))
	$(eval mb_invoke_run_in_shell := $(mb_off))
	$(call mb_assert_was_called,mb_printf_info,2)
	$(eval result := $(call mb_invoke,echo "mb_invoke tests passed"))
	$(call mb_assert_eq,echo "mb_invoke tests passed";,$(result))
endef

define test_mb_invoke_print_off
	$(eval mb_invoke_last_target := $(mb_empty))
	$(eval mb_invoke_print := $(mb_off))
	$(call mb_assert_was_called,mb_printf_info,1)
	$(eval tests_mb_invoke_cmd := echo "mb_invoke tests passed123")
	$(eval result := $(call mb_invoke,$(tests_mb_invoke_cmd)))
	$(eval mb_invoke_print := $(mb_on))
	$(call mb_assert_eq,$(tests_mb_invoke_cmd);,$(result))
endef

define test_mb_invoke_silent_on
	$(eval mb_invoke_last_target := $(mb_empty))
	$(eval mb_invoke_silent := $(mb_on))
	$(eval mb_invoke_run_in_shell := $(mb_off))
	$(call mb_assert_was_called,mb_printf_info,0)
	$(eval tests_mb_invoke_cmd := echo "mb_invoke tests passed123")
	$(eval result := $(call mb_invoke,$(tests_mb_invoke_cmd)))
	$(eval mb_invoke_silent := $(mb_off))
	$(call mb_assert_eq,$(tests_mb_invoke_cmd);,$(result))
endef

define test_mb_invoke_dry_run_on
	$(eval mb_invoke_last_target := $(mb_empty))
	$(eval mb_invoke_dry_run := $(mb_on))

	$(call mb_assert_was_called,mb_printf_info,2)
	$(eval $0_cmd := echo "mb_invoke tests passed")
	$(eval $0_result := $(call mb_invoke,$($0_cmd)))
	$(call mb_assert_empty,$(strip $($0_result)))

	$(eval mb_invoke_dry_run := $(mb_off))
endef

define test_mb_invoke_run_in_shell
	$(eval mb_invoke_last_target := $(mb_empty))
	$(eval mb_invoke_dry_run := $(mb_off))
	$(eval mb_invoke_run_in_shell := $(mb_on))

	$(call mb_assert_was_called,mb_printf_info,2)
	$(eval $0_cmd := echo "mb_invoke tests passed")
	$(eval $0_result := $(call mb_invoke,$($0_cmd)))
	$(call mb_assert_empty,$(strip $($0_result)))
	$(call mb_assert_eq,0,$(mb_invoke_shell_exit_code))
	$(call mb_assert_eq,mb_invoke tests passed,$(strip $(mb_invoke_shell_output)))

	$(eval mb_invoke_run_in_shell := $(mb_off))
endef
