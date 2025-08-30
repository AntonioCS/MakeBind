
include $(mb_core_path)/functions.mk



## NOTE: We must reset mb_invoke_last_target before calling mb_invoke to ensure we get the right amount of calls to mb_printf_info
define test_core_functions_mb_invoke
	$(eval mb_invoke_last_target := $(mb_empty))
	$(call mb_assert_was_called,mb_printf_info,2)
	$(eval result := $(call mb_invoke,echo "mb_invoke tests passed"))
	$(call mb_assert_eq,echo "mb_invoke tests passed",$(result))
endef

define test_core_functions_mb_invoke_mb_invoke_print_off
	$(eval mb_invoke_last_target := $(mb_empty))
	$(eval mb_invoke_print := $(mb_off))
	$(call mb_assert_was_called,mb_printf_info,1)
	$(eval tests_mb_invoke_cmd := echo "mb_invoke tests passed123")
	$(eval result := $(call mb_invoke,$(tests_mb_invoke_cmd)))
	$(eval mb_invoke_print := $(mb_on))
	$(call mb_assert_eq,$(tests_mb_invoke_cmd),$(result))
endef

define test_core_functions_mb_invoke_mb_invoke_silent_on
	$(eval mb_invoke_last_target := $(mb_empty))
	$(eval mb_invoke_silent := $(mb_on))
	$(call mb_assert_was_called,mb_printf_info,0)
	$(eval tests_mb_invoke_cmd := echo "mb_invoke tests passed123")
	$(eval result := $(call mb_invoke,$(tests_mb_invoke_cmd)))
	$(eval mb_invoke_silent := $(mb_off))
	$(call mb_assert_eq,$(tests_mb_invoke_cmd),$(result))
endef

define test_core_functions_mb_invoke_mb_invoke_dry_run_on
	$(eval mb_invoke_last_target := $(mb_empty))
	$(eval mb_invoke_dry_run := $(mb_on))

	$(call mb_assert_was_called,mb_printf_info,2)
	$(eval $0_cmd := echo "mb_invoke tests passed")
	$(eval $0_result := $(call mb_invoke,$($0_cmd)))
	$(call mb_assert_empty,$(strip $($0_result)))

	$(eval mb_invoke_dry_run := $(mb_off))
endef

define test_core_functions_mb_invoke_mb_invoke_shell
	$(eval mb_invoke_last_target := $(mb_empty))
	$(eval mb_invoke_dry_run := $(mb_off))
	$(eval mb_invoke_run_in_shell := $(mb_on))


	$(call mb_assert_was_called,mb_printf_info,2)
	$(eval $0_cmd := echo "mb_invoke tests passed")
	$(eval $0_result := $(call mb_invoke,$($0_cmd)))
	$(call mb_assert_empty,$(strip $($0_result)))
	$(call mb_assert_eq,0,$(mb_invoke_shell_exit_code))
	$(call mb_assert_eq,mb_invoke tests passed,$(strip $(mb_invoke_shell_output)))

	$(eval mb_invoke_dry_run := $(mb_off))
endef


define ___test_mb_is_regex_match_printf_command
	$(eval mb_printf_use_shell := $(mb_off))
	$(eval result := $(call mb_printf,printf tests passed,$(mb_printf_info_format_specifier)))
    $(eval regex_pattern := printf \".+?\"\s\".+?\"\s\"\[MakeBind\]\"\s\"printf tests passed\";printf \"\\n\";)
    $(eval result_regex = $(call mb_is_regex_match,$(result),$(regex_pattern)))
    $(info BLA: $(result_regex))
    $(call mb_assert,$(result_regex))
endef

define  __test_printf
	$(eval mb_printf_use_shell := $(mb_off))
	$(eval result := $(call mb_printf,printf tests passed,$(mb_printf_info_format_specifier)))
	$(eval mb_printf_use_shell := $(mb_on))
	$(info test_printf: $(result))
endef


#
#test/powershell2: ## skip
#	$(info Shell: $(SHELL))
#	Write-Host ('{0}`e[0;32m{1}`e[0m {2}' -f '[2024-07-01 20:24:22]','[mock_project]','printf tests passed')
#	$(call mb_powershell,Write-Host ('{0}`e[0;32m{1}`e[0m {2}' -f '[2024-07-01 20:24:22]','[mock_project]','printf tests passed'))
#	pwsh.exe -NoProfile -Command "Write-Host ('{0}`e[0;32m{1}`e[0m {2}' -f '[2024-07-01 20:24:22]','[mock_project]','printf tests passed')"
#	pwsh.exe -NoProfile -Command "Write-Host ('{0}$$([char]27)[0;32m{1}$$([char]27)[0m {2}' -f '[2024-07-01 20:24:22]','[mock_project]','printf tests passed')"
#
#test/powershell: ## skip
#	$(info $(call mb_os_assign,$(mb_rep_dollar)([char]27),\033))
#	$(eval cmd = $(call mb_powershell,Write-Output ('{0}{1} {2}' -f 'ts'$(mb_comma)'project'$(mb_comma)'printf tests passed'))))
#	$(info cmd: $(cmd))
#	$(eval bla := $(shell $(cmd)))
#	$(info bla: $(bla))

######################################################################################################################
######################################################################################################################


# TODO: Find way to test mb_ask_user and mb_user_confirm
define __test_core_functions_mb_ask_user
	$(eval $0_saved_cmd := $(mb_ask_user_linux_mac_cmd))
	$(eval mb_ask_user_linux_mac_cmd := read)
	$(info Bla: $(call mb_ask_user,What is your name?))
	$(info Result: $($0_result))

	$(eval mb_ask_user_linux_mac_cmd := $($0_saved_cmd))
endef
#
#test/core/functions/mb_ask_user_test:
#	$(eval data := $(call mb_ask_user,What is your name?))
#	$(info $(data))
#
#test/core/functions/test_mb_ask_user_timeout:
#	$(eval data := $(call mb_ask_user,What is your name?,5))
#	$(info $(data))
#
#test/core/functions/test_mb_ask_user_default_text:
#	$(eval data := $(call mb_ask_user,What is your name?,,Manel))
#	$(info $(data))


######################################################################################################################
######################################################################################################################
#
#test/core/functions/test_mb_user_confirm:
#	$(eval value := $(call mb_user_confirm,Are you sure???? [y/n]))
#	$(info $(if $(value),You confirmed,You didnt confirm))
#
#test/core/functions/test_mb_user_confirm_auto_accept:
#	$(eval mb_user_confirm_auto_accept:= 1)
#	$(eval value := $(call mb_user_confirm,Are you sure???? [y/n]))
#	$(info $(if $(value),You confirmed,You didnt confirm))
