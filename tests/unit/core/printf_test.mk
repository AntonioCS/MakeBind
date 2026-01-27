#####################################################################################
# Project: MakeBind
# File: tests/unit/core/printf_test.mk
# Description: Tests for mb_printf functions
# Author: AntonioCS
# License: MIT License
#####################################################################################

include $(mb_core_path)/functions.mk

define test_printf_info_format_specifier_defined
	$(call mb_assert,$(value mb_printf_info_format_specifier),mb_printf_info_format_specifier should be defined)
endef

define test_printf_warn_format_specifier_defined
	$(call mb_assert,$(value mb_printf_warn_format_specifier),mb_printf_warn_format_specifier should be defined)
endef

define test_printf_error_format_specifier_defined
	$(call mb_assert,$(value mb_printf_error_format_specifier),mb_printf_error_format_specifier should be defined)
endef

define test_printf_debug_format_specifier_defined
	$(call mb_assert,$(value mb_printf_debug_format_specifier),mb_printf_debug_format_specifier should be defined)
endef

define test_printf_ts_format_defined
	$(call mb_assert,$(value mb_printf_ts_format),mb_printf_ts_format should be defined)
endef

define test_printf_info_format_uses_printf_syntax
	$(call mb_assert,$(findstring %s,$(mb_printf_info_format_specifier)),Format should use printf %s syntax)
endef

define test_printf_ts_format_uses_date_syntax
	$(call mb_assert,$(findstring %,$(mb_printf_ts_format)),Timestamp format should use date % syntax)
endef

define test_normalizer_escapes_quotes
	$(eval $0_result := $(call mb_normalizer,Hello "world"))
	$(call mb_assert,$(findstring \",$($0_result)),Normalizer should escape double quotes)
endef

define test_normalizer_escapes_backticks
	$(eval $0_result := $(call mb_normalizer,Hello `world`))
	$(call mb_assert,$(findstring \`,$($0_result)),Normalizer should escape backticks)
endef

define test_printf_statement_display_guard
	$(eval $0_result := $(call mb_printf_statement_display_guard,TEST))
	$(call mb_assert_eq,[TEST],$($0_result),Display guard should wrap text in brackets)
endef
