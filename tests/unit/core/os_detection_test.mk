#####################################################################################
# Project: MakeBind
# File: tests/unit/core/os_detection_test.mk
# Description: Tests for OS detection functions
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/util/os_detection.mk

define test_os_detection_runs_without_error
	$(call mb_os_detection)
	$(call mb_assert,$(mb_os_has_been_set),mb_os_has_been_set should be true after detection)
endef

define test_os_detection_sets_linux_or_osx
	$(call mb_os_detection)
	$(call mb_assert,$(or $(mb_os_is_linux),$(mb_os_is_osx)),Either mb_os_is_linux or mb_os_is_osx should be set)
endef

define test_os_detection_linux_or_osx_flag_set
	$(call mb_os_detection)
	$(call mb_assert,$(mb_os_is_linux_or_osx),mb_os_is_linux_or_osx should be true on Unix)
endef

define test_os_call_executes_linux_command
	$(eval $0_result := $(call mb_os_call,echo LINUX,echo MAC))
	$(call mb_assert,$(call mb_is_regex_match,$($0_result),LINUX|MAC),mb_os_call should execute Linux or Mac command)
endef

define test_os_call_with_shell_off
	$(eval $0_result := $(call mb_os_call,echo LINUX,,$(mb_off)))
	$(call mb_assert,$(findstring echo LINUX,$($0_result)),mb_os_call with shell off should return command string)
endef

define test_os_assign_returns_command_string
	$(eval $0_result := $(call mb_os_assign,linux_cmd,mac_cmd))
	$(call mb_assert_eq,linux_cmd,$($0_result),mb_os_assign should return linux command)
endef

define test_os_windows_detection_variable_defined
	$(call mb_assert,$(filter mb_os_is_windows,$(.VARIABLES)),mb_os_is_windows variable should be defined)
endef

define test_os_windows_detection_is_false_on_unix
	$(call mb_assert,$(call mb_is_false,$(mb_os_is_windows)),mb_os_is_windows should be false on Linux/macOS)
endef
