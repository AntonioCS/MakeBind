

include $(mb_test_path)/../core/util.mk


define mb_cache_write_test_data
cache_write_test := $(cache_write_test)
endef
mb_debug_cache := $(mb_off)

tests/core/util/cache: tests/core/util/cache_write_and_read
tests/core/util/cache: tests/core/util/cache_write_ttl
tests/core/util/cache:


tests/core/util/cache_write_and_read:
	$(eval cache_write_test := $(call mb_random))
	$(eval cache_hold_value := $(cache_write_test))
	$(call mb_cache_write,cache_write_test,$(mb_cache_write_test_data))
	$(call mb_assert_exists,$(mb_cache_folder_path)/cache_write_test.$(mb_cache_file_extension))
	$(eval undefine cache_write_test)
	$(call mb_assert,$(call mb_cache_read,cache_write_test))
#$(info cache_hold_value: $(cache_hold_value))
	$(call mb_assert_eq,$(cache_write_test),$(cache_hold_value))


tests/core/util/cache_write_ttl:
	$(eval cache_write_test := $(call mb_random))
	$(eval cache_hold_value := $(cache_write_test))
	$(call mb_cache_write,cache_write_test_ttl,$(mb_cache_write_test_data),5)
	$(call mb_assert_exists,$(mb_cache_folder_path)/cache_write_test_ttl.$(mb_cache_file_extension))
	$(call mb_assert_exists,$(mb_cache_folder_path)/cache_write_test_ttl.$(mb_cache_ttl_extension))


tests/core/util/cache_read_ttl: tests/core/util/cache_write_ttl
	$(eval mb_debug_cache := $(mb_on))
	$(eval cache_hold_value := $(cache_write_test))
	$(call mb_assert,$(call mb_cache_read,cache_write_test_ttl))
	$(info cache_hold_value: $(cache_hold_value))
	$(call mb_assert_eq,$(cache_write_test),$(cache_hold_value))