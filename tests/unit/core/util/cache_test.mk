

include $(mb_makebind_path)/core/util.mk

mb_debug_cache := $(mb_off)
mb_project_prefix := testprj

$(if $(wildcard $(mb_cache_folder_path)),,$(shell mkdir -p $(mb_cache_folder_path)))

define test_core_util_cache_write_and_read
	$(eval cache_write_test := $(call mb_random))
	$(eval cache_hold_value := $(cache_write_test))
	$(call mb_cache_write,cache_write_test,$(cache_write_test))
	$(call mb_cache_read,cache_write_test,value_read)
	$(call mb_assert_eq,$(value_read),$(cache_write_test))
endef

#define test_core_util_cache_write_and_read_ttl
#	$(eval cache_write_test := My Value)
#	$(call mb_cache_write,cache_write_test_ttl,$(mb_cache_write_test_data),5)
#	$(call mb_assert_exists,$(mb_cache_folder_path)/cache_write_test_ttl.$(mb_cache_file_extension))
#	$(call mb_assert_exists,$(mb_cache_folder_path)/cache_write_test_ttl.$(mb_cache_ttl_extension))
############ Second part of the test ###########
#	$(eval cache_hold_value := $(cache_write_test))
#	$(call mb_assert,$(call mb_cache_read,cache_write_test_ttl))
#	$(call mb_assert_eq,$(cache_write_test),$(cache_hold_value))
#endef
