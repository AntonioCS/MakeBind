
include $(mb_makebind_path)/core/util.mk



# Expect result to be empty (no match)
define test_mb_is_regex_match_no_match
	$(eval text_to_check = hello world)
	$(eval regex_pattern = ^world)
	$(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert_empty,$(result))
endef
#
#
# Expect result to have 1 (match)
define test_mb_is_regex_match_simple_exact_match
    $(eval text_to_check = hello world)
    $(eval regex_pattern = hello world)
    $(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
    $(call mb_assert,$(result))
endef

# Expect result to have 1 (match)
define test_mb_is_regex_match_partial_match_start
    $(eval text_to_check = hello world)
    $(eval regex_pattern = ^hello)
    $(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
    $(call mb_assert,$(result))
endef

# Expect result to have 1 (match)
define test_mb_is_regex_match_partial_match_end
    $(eval text_to_check = hello world)
    $(eval regex_pattern = world$(mb_dollar))
    $(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
    $(call mb_assert,$(result))
endef

# Expect result to have 1 (match)
define test_mb_is_regex_match_match_any_word
    $(eval text_to_check = hello world)
    $(eval regex_pattern = world)
    $(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
    $(call mb_assert,$(result))
endef

# Expect result to be empty (no match)
define test_mb_is_regex_match_no_match
    $(eval text_to_check = hello world)
    $(eval regex_pattern = ^world)
    $(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
    $(call mb_assert_empty,$(result))
endef

# Expect result to have 1 (match)
define test_mb_is_regex_match_match_special_characters
    $(eval text_to_check = file123.txt)
    $(eval regex_pattern = ^file[0-9]+\.txt$$)
    $(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
    $(call mb_assert,$(result))
endef

# Expect result to be empty (no match)
define test_mb_is_regex_match_case_sensitive_match
    $(eval text_to_check = Hello World)
    $(eval regex_pattern = ^hello)
    $(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
    $(call mb_assert_empty,$(result))
endef

# Expect result to have 1 (match)
define test_mb_is_regex_match_match_whitespace
    $(eval text_to_check =    hello world   )
    $(eval regex_pattern = ^\s*hello\s+world\s*$$)
    $(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
    $(call mb_assert,$(result))
endef

# Expect result to have 1 (match)
define test_mb_is_regex_match_match_optional_characters
    $(eval text_to_check = color)
    $(eval regex_pattern = colou?r)
    $(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
    $(call mb_assert,$(result))
endef

# Expect result to have 1 (match)
define test_mb_is_regex_match_match_number
    $(eval text_to_check = 12345)
    $(eval regex_pattern = ^[0-9]+$$)
    $(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
    $(call mb_assert,$(result))
endef

# Expect result to be empty (no match)
define test_mb_is_regex_match_no_match_empty_string
    $(eval text_to_check = )
    $(eval regex_pattern = ^hello)
    $(eval result = $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
    $(call mb_assert_empty,$(result))
endef
