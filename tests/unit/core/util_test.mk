
include $(mb_makebind_path)/core/util.mk

define test_core_util_mb_is
	$(call mb_assert,$(call mb_is_eq,1,1),"mb_is_eq failed")
	$(call mb_assert,$(call mb_is_neq,1,2),"mb_is_neq failed")
	$(call mb_assert,$(call mb_is_on,1),"mb_is_on failed")
	$(call mb_assert,$(call mb_is_off,0),"mb_is_off failed")
	$(call mb_assert,$(call mb_is_empty,),"mb_is_empty failed")
	$(call mb_assert,$(call mb_is_false,),"mb_is_false failed")
	$(call mb_assert,$(call mb_is_true,1),"mb_is_true failed")
endef

define test_core_util_mb_expression
	$(call mb_assert_eq,2,$(call mb_expression,1+1), "mb_expression failed")
	$(call mb_assert_eq,2,$(call mb_add,1,1), "mb_add failed")
	$(call mb_assert_eq,5,$(call mb_sub,10,5), "mb_dec failed")
	$(call mb_assert_eq,25,$(call mb_mul,5,5), "mb_mul failed")
	$(call mb_assert_eq,1,$(call mb_div,5,5), "mb_div failed")
endef

define test_core_util_increment_decrement
	$(eval test_var := 1)
	$(call mb_inc,test_var)
	$(call mb_assert_eq,2,$(test_var), "mb_inc failed")
	$(call mb_dec,test_var)
	$(call mb_assert_eq,1,$(test_var), "mb_dec failed")
endef

define test_core_util_mb_add_big_values
	$(call mb_assert_eq,1719841777,$(call mb_add,1719841772,5))
endef

# WIP
define _test_core_util_mb_array_from_file
	$(eval $0_test_file := $(mb_test_path_data)/test_core_util_mb_array_from_file.txt)
	$(info Test file: $($0_test_file))
	$(eval test_array := $(call mb_array_from_file,$($0_test_file),$0_array))
endef








######################################################################################
# mb_is_regex_match tests
######################################################################################

define test_mb_is_regex_match_no_match
	$(eval text_to_check := hello world)
	$(eval regex_pattern := ^world)
	$(eval result := $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert_empty,$(result))
endef

define test_mb_is_regex_match_simple_exact_match
	$(eval text_to_check := hello world)
	$(eval regex_pattern := hello world)
	$(eval result := $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert,$(result))
endef

define test_mb_is_regex_match_partial_match_start
	$(eval text_to_check := hello world)
	$(eval regex_pattern := ^hello)
	$(eval result := $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert,$(result))
endef

define test_mb_is_regex_match_partial_match_end
	$(eval text_to_check := hello world)
	$(eval regex_pattern := world)
	$(eval result := $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert,$(result))
endef

define test_mb_is_regex_match_match_any_word
	$(eval text_to_check := hello world)
	$(eval regex_pattern := world)
	$(eval result := $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert,$(result))
endef

define test_mb_is_regex_match_match_special_characters
	$(eval text_to_check := file123.txt)
	$(eval regex_pattern := ^file[0-9]+\.txt)
	$(eval result := $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert,$(result))
endef

define test_mb_is_regex_match_case_sensitive
	$(eval text_to_check := Hello World)
	$(eval regex_pattern := ^hello)
	$(eval result := $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert_empty,$(result))
endef

define test_mb_is_regex_match_whitespace
	$(eval text_to_check :=    hello world   )
	$(eval regex_pattern := ^\s*hello\s+world\s*)
	$(eval result := $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert,$(result))
endef

define test_mb_is_regex_match_optional_characters
	$(eval text_to_check := color)
	$(eval regex_pattern := colou?r)
	$(eval result := $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert,$(result))
endef

define test_mb_is_regex_match_number
	$(eval text_to_check := 12345)
	$(eval regex_pattern := ^[0-9]+)
	$(eval result := $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert,$(result))
endef

define test_mb_is_regex_match_empty_string
	$(eval text_to_check :=)
	$(eval regex_pattern := ^hello)
	$(eval result := $(call mb_is_regex_match,$(text_to_check),$(regex_pattern)))
	$(call mb_assert_empty,$(result))
endef
