

include $(mb_test_path)/../core/util.mk

tests/core/util/mb_is_tests:
	$(call mb_assert,$(call mb_is_eq,1,1),"mb_is_eq failed")
	$(call mb_assert,$(call mb_is_neq,1,2),"mb_is_neq failed")
	$(call mb_assert,$(call mb_is_on,1),"mb_is_on failed")
	$(call mb_assert,$(call mb_is_off,0),"mb_is_off failed")
	$(call mb_assert,$(call mb_is_empty,),"mb_is_empty failed")
	$(call mb_assert,$(call mb_is_false,),"mb_is_false failed")
	$(call mb_assert,$(call mb_is_true,1),"mb_is_true failed")
	echo "mb_is tests passed"
