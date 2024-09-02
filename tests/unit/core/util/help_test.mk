
## NOTE: Try to see if I can build documentation automatically when given a function name
## All setting variables are normally <function_name>_setting so I can search for those and then in all the
## included files I can search for the ones that have ## in front of them and then I can build the documentation automatically

help_expected := % - help
define test_core_util_help
	$(eval data := $(shell $(call mock_prj_call,mb/help mb_printf_display_ts=0 mb_printf_display_project_name=0)))
	$(call mb_assert_filter,$(help_expected),$(data))
endef
