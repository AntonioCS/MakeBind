

include $(mb_test_path)/../core/util.mk
include $(mb_test_path)/core/util/os_detection_test.mk

tests/core/util/mb_is_tests:
	$(call mb_assert,$(call mb_is_eq,1,1),"mb_is_eq failed")
	$(call mb_assert,$(call mb_is_neq,1,2),"mb_is_neq failed")
	$(call mb_assert,$(call mb_is_on,1),"mb_is_on failed")
	$(call mb_assert,$(call mb_is_off,0),"mb_is_off failed")
	$(call mb_assert,$(call mb_is_empty,),"mb_is_empty failed")
	$(call mb_assert,$(call mb_is_false,),"mb_is_false failed")
	$(call mb_assert,$(call mb_is_true,1),"mb_is_true failed")

tests/core/util/mb_timestamp:
	$(info Should return ts: $(call mb_timestamp))

tests/core/util/mb_random:
	$(info Should return random number: $(call mb_random) -- $(call mb_random))

tests/core/util/mb_expression:
	$(call mb_assert_eq,2,$(call mb_expression,1+1))
	$(call mb_assert_eq,2,$(call mb_add,1,1))
	$(call mb_assert_eq,5,$(call mb_dec,10,5))
	$(call mb_assert_eq,25,$(call mb_mul,5,5))
	$(call mb_assert_eq,1,$(call mb_div,5,5))


tests/core/util/mb_add_big_values:
	$(call mb_assert_eq,1719841777,$(call mb_add,1719841772,5))