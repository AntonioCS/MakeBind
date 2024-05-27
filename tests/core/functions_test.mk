
include $(mb_test_path)/../core/functions.mk


tests/core/functions/test_mb_invoke:
	$(call mb_invoke,echo "mb_invoke tests passed")

tests/core/functions/test_mb_invoke_info_msg:
	$(eval mb_info_msg := This is a test)
	$(call mb_invoke,echo "mb_invoke tests passed")

tests/core/functions/test_mb_invoke_info_mgs_call_1_with_message: mb_info_msg := This is test 1
tests/core/functions/test_mb_invoke_info_mgs_call_1_with_message:
	$(call mb_invoke,echo "mb_invoke with info msg 1")

tests/core/functions/test_mb_invoke_info_mgs_call_2_no_message:
	$(call mb_invoke,echo "mb_invoke with no msg")

tests/core/functions/test_mb_invoke_info_mgs_call_3_with_message: mb_info_msg := This is test 3
tests/core/functions/test_mb_invoke_info_mgs_call_3_with_message:
	$(call mb_invoke,echo "mb_invoke with info msg 3")

tests/core/functions/test_mb_invoke_info_mgs_multiple_calls: tests/core/functions/test_mb_invoke_info_mgs_call_1_with_message
tests/core/functions/test_mb_invoke_info_mgs_multiple_calls: tests/core/functions/test_mb_invoke_info_mgs_call_2_no_message
tests/core/functions/test_mb_invoke_info_mgs_multiple_calls: tests/core/functions/test_mb_invoke_info_mgs_call_3_with_message
tests/core/functions/test_mb_invoke_info_mgs_multiple_calls:





######################################################################################################################
######################################################################################################################


tests/core/functions/test_mb_printf:
	$(call mb_printf,printf tests passed,$(mb_printf_info_format_specifier))
	$(call mb_printf,printf tests passed,$(mb_printf_warn_format_specifier))
	$(call mb_printf,printf tests passed,$(mb_printf_error_format_specifier))

tests/core/functions/test_mb_printf_funcs:
	$(call mb_printf_info,printf tests passed)
	$(info Test1223)
	$(call mb_printf_info,printf tests passed)
	$(call mb_printf_warn,print tests passed)
	$(call mb_printf_warn,print tests passed)
	$(call mb_printf_error,print tests passed)
	$(call mb_printf_error,print tests passed)

######################################################################################################################
######################################################################################################################

tests/core/functions/mb_ask_user_test:
	$(eval data := $(call mb_ask_user,What is your name?))
	$(info $(data))

tests/core/functions/test_mb_ask_user_timeout:
	$(eval data := $(call mb_ask_user,What is your name?,5))
	$(info $(data))

tests/core/functions/test_mb_ask_user_default_text:
	$(eval data := $(call mb_ask_user,What is your name?,,Manel))
	$(info $(data))


######################################################################################################################
######################################################################################################################

tests/core/functions/test_mb_user_confirm:
	$(eval value := $(call mb_user_confirm,Are you sure???? [y/n]))
	$(info $(if $(value),You confirmed,You didnt confirm))

tests/core/functions/test_mb_user_confirm_auto_accept:
	$(eval mb_user_confirm_auto_accept:= 1)
	$(eval value := $(call mb_user_confirm,Are you sure???? [y/n]))
	$(info $(if $(value),You confirmed,You didnt confirm))
